function [] = chaining()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

path = './Data/House/';
file_names = get_file_names(path);

threshold = 0.001;

prev_F = 0;

for file_no = 1:length(file_names)
    im1 = imread(file_names(file_no, :));
    im2 = imread(file_names(file_no+1, :));
    
    [ inliers_im1, ~, F ] = norm_8pt_alg(im1, im2);
    
    if exist('point_view_matrix', 'var') == 0
        point_view_matrix(file_no*2-1:file_no*2, :) = inliers_im1;
    else
        prev_im_points = point_view_matrix(end-1:end, :);
        
        inliers_im1(3, :) = ones(1, size(inliers_im1, 2));
        prev_im_points(3, :) = ones(1, size(prev_im_points, 2));
        
        fund_result = inliers_im1.' * prev_F * prev_im_points;
        
        [ V, idx ] = min(abs(fund_result));
        disp(idx)
        histc = histcounts(idx, size(idx, 2));
        
        i = 1:length(histc);
        new_points_idx = i(histc < 1);
        
%         disp(max(new_points_idx))
%         size(inliers_im1)
        
        inliers_im1 = inliers_im1(1:2, :);
        V(V < threshold) = NaN;
        V(V >= threshold) = 1;
        
        point_view_matrix(file_no*2-1:file_no*2, :) = inliers_im1(:, idx).*V;
        
        new_points = inliers_im1(:, new_points_idx);
        point_view_matrix = [ point_view_matrix zeros(size(point_view_matrix, 1), size(new_points, 2)) ];
        
        point_view_matrix(file_no*2-1:file_no*2, end-size(new_points, 2)+1:end) = new_points;
        
%         disp(point_view_matrix)
        
    end
    
    prev_F = F;
        
end

