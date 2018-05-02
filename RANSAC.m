function [ best_transformation, inliers_im1, inliers_im2 ] = RANSAC(...
    image1, image2, N, T, P, visualizeTemp, visualizeFinal, saveResults, dist_threshold)
%RANSAC Finds the best transformation between two images.
% Input parameters:
%   image1, image2      Rgb or grayscale images.
%   N                   Amount of iterations (default: 1).
%   T                   Total set of matches.
%   P                   Amount of (random) samples from T.
%   transformation      Method of transformation (default: 'nearest').
%   visualizeTemp       Boolean for visualizing results in every iteration (default: false).
%   visualizeFinal      Boolean for visualizing final results (default: true).
%   saveResults         Boolean for saving results (default: false).
close ALL % close all figures

% set default parameters
if nargin == 0
    image1 = imread('Data/House/frame00000001.png');
    image2 = imread('Data/House/frame00000002.png');
end
if nargin < 3
    N = 10;
end
if nargin < 4
    [ T, f1, f2 ] = keypoint_matching(image1, image2, 50, false);
end
if nargin < 5
    P = 10;
end
if nargin < 6
    transformation = 'nearest';
end
if nargin < 7
    visualizeTemp = false;
end
if nargin < 8
    visualizeFinal = false;
end
if nargin < 9
    saveResults = false;
end
if nargin < 10
    dist_threshold = 15;
end

matches_im1 = T(1, :);
matches_im2 = T(2, :);

largest_num_inliers = 0;
best_transformation = zeros(6, 1);

% Repeat N times
for n = 1:N
    
    % Pick P matches at random from the total set of matches T
    perm = randperm(size(T, 2)); % shuffle indices randomly
    sel = perm(1:P); % pick the first P indices
    sel_matches_im1 = T(1, sel); % take the corresponding pairs of T in image 1
    sel_matches_im2 = T(2, sel); % take the corresponding pairs of T in image 2
    
    % Using f1 and f2, get the coordinates of these points.
    % Currently P is set to ONE, so now it is for one point.
    % TODO: fix for multiple points (including solving Ax=b).
     x1 = f1(1, sel_matches_im1);
     y1 = f1(2, sel_matches_im1);
     x2 = f2(1, sel_matches_im2);
     y2 = f2(2, sel_matches_im2);

    % Construct a matrix A and vector b using the P pairs of points
    % and find transformation parameters (m1, m2, m3, m4, t1, t2) 
    % by solving the equation Ax = b.
    A = zeros(P*2, 6);
    
    A(1:2:end, 1) = x1;
    A(1:2:end, 2) = y1;
    A(2:2:end, 3) = x1;
    A(2:2:end, 4) = y1;    

    A(1:2:end, 5) = 1;
    A(2:2:end, 6) = 1;
    
    b = zeros(P*2, 1);
    b(1:2:end) = x2;
    b(2:2:end) = y2;    

    x =  pinv(A) * b; % Solve Ax = b  with  x = [ m1, m2, m3, m4, t1, t2 ]'
    
    % Using the transformation parameters, transform the locations of all T points in image1.
    % If the transformation is correct, they should lie close to their counterparts in image2. 
    % Plot the two images side by side with a line connecting the original T points in image1 
    % and transformed T points over image2.

    x1 = f1(1, matches_im1);
    y1 = f1(2, matches_im1); 
    
    A = zeros(length(x1)*2, 6);
    A(1:2:end, 5)  = 1;
    A(2:2:end, 6)  = 1;
    
    A(1:2:end, 1) = x1;
    A(1:2:end, 2) = y1;
    A(2:2:end, 3) = x1;
    A(2:2:end, 4) = y1;  
    
    b = A*x;

    trans_im1_feat_points = [ b(1:2:end), b(2:2:end) ]';
    OG_im2_feat_points = f2(1:2, matches_im2);
    
    % For visualization, show the transformations from image1 to image2 
    % and from image2 to image1.
     if visualizeTemp
         visualization(image1, image2, f1, trans_im1_feat_points)
     end
    
    distance = sqrt(...
    (trans_im1_feat_points(1, :) - OG_im2_feat_points(1, :)).^2 + ...
    (trans_im1_feat_points(2, :) - OG_im2_feat_points(2, :)).^2);

    num_inliers = length(trans_im1_feat_points(:, distance < dist_threshold));

    if num_inliers > largest_num_inliers
        largest_num_inliers = num_inliers;
        best_transformation = x;

        inliers_im1 = f1(1:2, matches_im1);
        inliers_im1 = inliers_im1(:, distance < dist_threshold);
        inliers_im2 = OG_im2_feat_points(:, distance < dist_threshold);
    end 

end

visualize_keypoints(image1, image2, inliers_im1, inliers_im2)

% Transform the image using the best transformation matrix and method
if strcmp(transformation, 'nearest') % nearest neighbour interpolation
    result = mat2gray(transform(image1, best_transformation));
elseif strcmp(transformation, 'affine2d') % affine2d with imwarp
    tform = affine2d([best_transformation(1) -best_transformation(2) 0; ...
    -best_transformation(3) best_transformation(4) 0; 0 0 1]);
    result = imwarp(image1, tform);
else % maketform with imtransform (not recommended)
    transformation = 'maketform';
    tform = maketform('affine', [best_transformation(1) -best_transformation(2) 0; ...
    -best_transformation(3) best_transformation(4) 0; 0 0 1]);
    result = imtransform(image1 ,tform);      
end

% Show transformation
if visualizeFinal
    titleDescription = strcat('Rotation using', {' '}, 'N=', int2str(N), ...
        ',', {' '}, 'P=', int2str(P), ',', {' '}, 'transformation=', transformation);
    figure, imshow(result), title(titleDescription);
end

% Save results
if saveResults == true
    fileName = strcat('results/im1_2_trans_', transformation, ...
        '_N_', int2str(N), '_P_', int2str(P), '.png');
    imwrite(result, fileName)
end

end

function visualize_keypoints(image1, image2, f1, f2)
    visualizePoints = size(f1, 2);
    figure, imshowpair(image1, image2, 'montage') % init figure
    title('Matching features in both images')
hold on
    vl_plotframe(f1);
    f2(1, :) = f2(1, :) + size(image1, 2); % 850 pixels to the right, because image2 is next to image1
    vl_plotframe(f2);
    hold on

    % Draw lines between each pair of points
    for i = 1:visualizePoints 
        x = [f1(1, i) f2(1, i)];
        y = [f1(2, i) f2(2, i)];
        line(x, y, 'Color', 'cyan', 'LineWidth', 1)
    end
end

function visualization(image1_rgb, image2_rgb, f1, f2)
figure, imshowpair(image1_rgb, image2_rgb, 'montage') % init figure
title('Matching features in both images')

[ ~, w, ~ ] = size(image1_rgb);

hold on

% Draw lines between each pair of points
for i = 1:50
    x = [f1(1, i) f2(1, i) + w];
    y = [f1(2, i) f2(2, i) ];
    line(x, y, 'Color', 'green', 'LineWidth', 1)
end

hold off

end

