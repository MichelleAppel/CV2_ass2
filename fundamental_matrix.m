function [ fund_matrix ] = fundamental_matrix(im1, im2)

run('./vlfeat-0.9.21/toolbox/vl_setup')

if nargin < 1
    im1 = imread('Data/House/frame00000001.png');
end
if nargin < 2
    im2 = imread('Data/House/frame00000002.png');
end

% Get the matching points
[ ~, inliers_im1, inliers_im2 ] = RANSAC(im1, im2);

% Get the columns to create A
x1 = inliers_im1(1, :)';
y1 = inliers_im1(2, :)';
x2 = inliers_im2(1, :)';
y2 = inliers_im2(2, :)';

% Create the A matrix
A(:, 1) = x1 .* x2; 
A(:, 2) = x1 .* y2; 
A(:, 3) = x1; 
A(:, 4) = y1 .* x2; 
A(:, 5) = y1 .* y2; 
A(:, 6) = y1; 
A(:, 7) = x2; 
A(:, 8) = y2; 
A(:, 9) = ones(size(inliers_im1, 2), 1); 

% Compute V and take the last column
% (corresponding to smallest singular values)
[ ~, ~, V ] = svd(A);
F = V(:, end);
F = reshape(F, 3, 3);

% Get the singular values of F and set smallest to 0
[ U, D, V ] = svd(F);
D(end, end) = 0;

% Recreate F
F = U * D * V.';



end