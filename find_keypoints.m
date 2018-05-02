function [ f, d ] = find_keypoints(image, color_space, sift_method, d_step_size)
% FIND_KEYPOINTS    Finds points of interest in an image.
% PARAMETERS:
%%% image           A rgb or grayscale image.
%%% color_space     The color space to tranform the image to:
%%%                 'RGB', 'rgb', 'opponent', or 'gray' (default).
%%% sift_method     The sift method used for finding keypoints:
%%%                 'sift' (default) or 'dsift' (dense estimation).
%%% d_step_size     The step size (in pixels) used by dense sift 
%%%                 to extract features (default: 10).

run('../Dependencies/vlfeat-0.9.21/toolbox/vl_setup')

% set default parameters if not initialized
if nargin < 2
   color_space = 'gray';
end
if nargin < 3
   sift_method = 'sift';
end
if nargin < 4
    d_step_size = 15;
end

if size(image, 3) == 3
    gray_image = rgb2gray(image); % transform to grayscale
    
    % transform to desired color space (if necessary)
    if strcmp(color_space, 'norm_rgb')      % 3 normalized RGB channels
        image = rgb2normedrgb(image);
    elseif strcmp(color_space, 'opponent')  % 3 opponent channels
        image = rgb2opponent(image);
    end
else
    gray_image = image; % image was already grayscale
    
    % if image is grayscale but color_space is not,
    % duplicate and concatenate channels 
    if not(strcmp(color_space, 'gray'))
        rimage(:, :, 1) = image;
        rimage(:, :, 2) = image;
        rimage(:, :, 3) = image;
        image = rimage;
    end
end
        
% dense SIFT
if strcmp(sift_method, 'dsift')
    % compute the descriptors using dense sift (without using keypoints)
    % see http://www.vlfeat.org/matlab/vl_phow.html
    if strcmp(color_space, 'norm_rgb')
        color_space = 'rgb';
    end
    [ f, d ] = vl_phow(single(image), 'Step', d_step_size, 'Color', lower(color_space));

% standard SIFT
else
    % compute the SIFT frames (keypoints)
    % see http://www.vlfeat.org/overview/sift.html
    [ f, d ] = vl_sift(single(gray_image));
        
    % if color_space is set to grayscale, these descriptors don't have
    % to be calculated again (use d above), 
    % otherwise, calculate d per color channel and concatenate
    if not(strcmp(color_space, 'gray'))        
        % compute the descriptors per color channel using keypoints (f)
        % and concatenate descriptors for multiple color channels into one d matrix
        [ h, w ] = size(d);
        d = zeros(3*h, w); % init (overwrite previous d)
        d(1:h, :)       = features2descriptors(f, image(:, :, 1)); % 1st channel descriptors
        d(h+1:2*h, :)   = features2descriptors(f, image(:, :, 2)); % 2nd channel descriptors
        d(2*h+1:3*h, :) = features2descriptors(f, image(:, :, 3)); % 3rd channel descriptors
    end
end

end

% calculate descriptors from features for one color channel
% implemented from http://www.vlfeat.org/matlab/vl_siftdescriptor.html
function [ d ] = features2descriptors(f, im_channel)
    I_       = vl_imsmooth(im2double(im_channel), sqrt(f(3)^2 - 0.5^2));
    [Ix, Iy] = vl_grad(I_);
    mod      = sqrt(Ix.^2 + Iy.^2);
    ang      = atan2(Iy, Ix);
    grd      = shiftdim(cat(3,mod,ang), 2);
    grd      = single(grd);
    d        = vl_siftdescriptor(grd, f);
end