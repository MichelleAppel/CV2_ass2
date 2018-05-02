function [ fund_matrix ] = fundamental_matrix(im1, im2)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

run('./vlfeat-0.9.21/toolbox/vl_setup')


if nargin < 1
    im1 = imread('Data/House/frame00000001.png');
end
if nargin < 2
    im2 = imread('Data/House/frame00000002.png');
end

[ ~, inliers_im1, inliers_im2 ] = RANSAC(im1, im2);

disp(inliers_im1)
disp(inliers_im2)


end

