function [ inliers_im1, desc1, max_inl, best_F ] = norm_8pt_alg(im1, im2, threshold, n_iter)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

run('./vlfeat-0.9.21/toolbox/vl_setup')

if nargin < 1
    im1 = imread('Data/House/frame00000001.png');
end
if nargin < 2
    im2 = imread('Data/House/frame00000002.png');
end
if nargin < 3
   threshold = 0.1;
end
if nargin < 4
   n_iter = 1; 
end
normalize = true;

max_inl = 0;

for iter = 1:n_iter
    [ F, inliers_im1, inliers_im2, desc1, ~ ] = fundamental_matrix(im1, im2, normalize);

    d = sampson_dist(inliers_im1, inliers_im2, F);

    n_inliers = length(d(d < threshold));
    
    if n_inliers > max_inl
        max_inl = n_inliers;
        best_F = F;
    end
    
end

end

