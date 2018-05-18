function epipolar_lines(im1, im2, n_samples, method)

if nargin < 1
    im1 = imread('Data/House/frame00000001.png');
end
if nargin < 2
    im2 = imread('Data/House/frame00000020.png');
end
if nargin < 4
   n_samples = 8; 
end
if nargin < 4
    method = 'RANSAC';
end

if strcmp(method, '8point')
    % F using standard eight-point algorithm
    [ F, inliers_im1, inliers_im2, ~, ~ ] = fundamental_matrix(im1, im2, false, n_samples);
elseif strcmp(method, 'norm8point')
    % F using standard normalized eight-point algorithm
    [ F, inliers_im1, inliers_im2, ~, ~ ] = fundamental_matrix(im1, im2, true, n_samples);
else
    % F using standard normalized eight-point algorithm with RANSAC
    [ inliers_im1, inliers_im2, ~, ~, F ] = norm_8pt_alg(im1, im2);
end

% Add ones to the inliers
inliers_im1(3, :) = ones(size(inliers_im1, 2), 1);
inliers_im2(3, :) = ones(size(inliers_im2, 2), 1);

% Find epipolar lines
epi_lines2 = F * inliers_im1;
epi_lines1 = F.' * inliers_im2;

% Remove ones
inliers_im1 = inliers_im1(1:2, :);
inliers_im2 = inliers_im2(1:2, :);
epi_lines2 = epi_lines2(1:2, :);
epi_lines1 = epi_lines1(1:2, :);

% Visualize the images and epipolar lines
figure, imshow(im1) % title('Epipolar lines in image 1.')
hold on
scatter(inliers_im1(1, :), inliers_im1(2, :), 4, 'red');
scatter(epi_lines1(1, :), epi_lines1(2, :), 4, 'yellow');
for i=1:size(inliers_im1, 2)
    plot([inliers_im1(1, i) epi_lines1(1, i)], [inliers_im1(2, i) epi_lines1(2, i)])
end

figure, imshow(im2) % title('Epipolar lines in image 2.')
hold on
scatter(inliers_im2(1, :), inliers_im2(2, :), 4, 'red');
scatter(epi_lines2(1, :), epi_lines2(2, :), 4, 'yellow');
for i=1:size(inliers_im2, 2)
    plot([inliers_im2(1, i) epi_lines2(1, i)], [inliers_im2(2, i) epi_lines2(2, i)])
end

end

