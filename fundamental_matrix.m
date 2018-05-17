function [ F, all_inliers_im1, all_inliers_im2, desc1, desc2 ] = fundamental_matrix(im1, im2, normalize, n_samples)

run('./vlfeat-0.9.21/toolbox/vl_setup')

if nargin < 1
    im1 = imread('Data/House/frame00000001.png');
end
if nargin < 2
    im2 = imread('Data/House/frame00000002.png');
end
if nargin < 3
   normalize = true; 
end
if nargin < 4
   n_samples = 8; 
end

% Get the matching points
[ ~, all_inliers_im1, all_inliers_im2, desc1, desc2 ] = RANSAC(im1, im2);
rndm = randperm(size(all_inliers_im1, 2));
idx = rndm(1:n_samples);
inliers_im1 = all_inliers_im1(:, idx);
inliers_im2 = all_inliers_im2(:, idx);

% Get the columns to create A
x1 = inliers_im1(1, :)';
y1 = inliers_im1(2, :)';
x2 = inliers_im2(1, :)';
y2 = inliers_im2(2, :)';

if normalize
    mx1 = sum(x1)/size(x1, 1);
    my1 = sum(y1)/size(y1, 1);
    mx2 = sum(x2)/size(x2, 1);
    my2 = sum(y2)/size(y2, 1);

    d1 = sum( sqrt( (x1 - mx1).^2 + (y1 - my1).^2 ) ) / size(x1, 1);
    d2 = sum( sqrt( (x2 - mx2).^2 + (y2 - my2).^2 ) ) / size(x2, 1);

    T1 = [sqrt(2)/d1, 0         , -mx1*sqrt(2)/d1;
          0         , sqrt(2)/d1, -my1*sqrt(2)/d1;
          0         , 0         , 1             ];

    T2 = [sqrt(2)/d2, 0         , -mx2*sqrt(2)/d2;
          0         , sqrt(2)/d2, -my2*sqrt(2)/d2;
          0         , 0         , 1             ];

    p1(1, :) = x1.';
    p1(2, :) = y1.';
    p1(3, :) = ones(size(x1, 1), 1);

    p2(1, :) = x2.';
    p2(2, :) = y2.';
    p2(3, :) = ones(size(x2, 1), 1);

    p1_hat = T1*p1;
    p1_hat = p1_hat(1:2, :).';
    p2_hat = T2*p2;
    p2_hat = p2_hat(1:2, :).';

    x1 = p1_hat(:, 1);
    y1 = p1_hat(:, 2);
    x2 = p2_hat(:, 1);
    y2 = p2_hat(:, 2);
end

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

% Denormalization
if normalize
    F = T1.' * F * T1;
end

end