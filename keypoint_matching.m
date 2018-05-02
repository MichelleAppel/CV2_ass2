function [ matches, f1, f2 ] = keypoint_matching(image1, image2, ...
    visualizePoints, visualization)
%KEYPOINT_MATCHING Find the keypoint matchings between two images.
% Input arguments:
%   image1, image2      Rgb or grayscale images.
%   visualizePoints     Amount of features (points) to display (default: 50).
%   visualization       Boolean for visualizing figures (default: true).

% DEPENDENCIES:
%%% VLFeat (see http://www.vlfeat.org/install-matlab.html)
%%% git clone git://github.com/vlfeat/vlfeat.git
run('vlfeat-0.9.21/toolbox/vl_setup')

close ALL % close all figures

% set default parameters
if nargin == 0
    image1 = imread('boat1.pgm');
    image2 = imread('boat2.pgm');
end
if nargin < 3
    visualizePoints = 50;
end
if nargin < 4
    visualization = true;
end

% transform to grayscale if necessary
image1_rgb = image1;
image2_rgb = image2;
if size(image1, 3) == 3
    image1 = rgb2gray(image1);
end
if size(image2, 3) == 3
    image2 = rgb2gray(image2);
end

% transform to single
s_image1 = single(image1);
s_image2 = single(image2);

% compute the SIFT frames (keypoints) and descriptors
% see http://www.vlfeat.org/overview/sift.html
[f1, d1] = vl_sift(s_image1);
[f2, d2] = vl_sift(s_image2);

% find matching features
[matches, ~] = vl_ubcmatch(d1, d2);

%%% Visualization %%%
% Take a random subset (with set size set to 50) of all matching points, 
% and plot on the image. Connect matching pairs with lines.

if visualization
    figure, imshowpair(image1_rgb, image2_rgb, 'montage') % init figure
    title('Matching features in both images')

    perm = randperm(size(matches, 2)); % shuffle indices randomly
    sel = perm(1:visualizePoints); % pick the first 50 (default) 

    % Draw the interest poins for image1
    sel1 = matches(1, sel);
    h1 = vl_plotframe(f1(:, sel1));
    h2 = vl_plotframe(f1(:, sel1));
    set(h1, 'color', 'k', 'linewidth', 3);
    set(h2, 'color', 'y', 'linewidth', 2);

    % Draw the interest poins for image2
    sel2 = matches(2, sel);
    f2(1, :) = f2(1, :) + size(image1, 2); % 850 pixels to the right, because image2 is next to image1
    h1 = vl_plotframe(f2(:, sel2));
    h2 = vl_plotframe(f2(:, sel2));
    set(h1, 'color', 'k', 'linewidth', 3);
    set(h2, 'color', 'y', 'linewidth', 2);

    hold on

    % Draw lines between each pair of points
    for i = 1:visualizePoints 
        x = [f1(1, sel1(i)) f2(1, sel2(i))];
        y = [f1(2, sel1(i)) f2(2, sel2(i))];
        line(x, y, 'Color', 'cyan', 'LineWidth', 1)
    end
end

end