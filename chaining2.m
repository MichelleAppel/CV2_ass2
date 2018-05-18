function [] = chaining2(threshold)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
clc
if nargin < 1
    threshold = 0.1;
end

path = './Data/House/';
file_names = get_file_names(path);

descriptors_dictionary = []; 

for file_no = 1:length(file_names)
    im1 = imread(file_names(file_no, :));
    im2 = imread(file_names(file_no+1, :));
    
    [ inliers_im1, descriptors, ~, ~ ] = norm_8pt_alg(im1, im2);
    

    if size(descriptors_dictionary, 1) > 0 
        [ LIA, LOCB ] = ismembertol(double(descriptors).', double(descriptors_dictionary).', threshold, 'ByRows', true);

        % Mathing points
        point_view_matrix(file_no*2-1:file_no*2, LOCB(LIA)) = inliers_im1(:, LIA.');
        point_view_matrix(point_view_matrix == 0) = NaN;
        
        match_descriptors = descriptors(:, LIA.');
        match_descriptors_dict = descriptors_dictionary(:, LOCB(LIA));
        
%         disp(match_descriptors(1:20, 1:25))
%         disp(match_descriptors_dict(1:20, 1:25))       
        
        non_matching_descr = descriptors(:, ~LIA.');
        descriptors_dictionary = [ descriptors_dictionary non_matching_descr ];
        
        % New points in point view matrix
        point_view_matrix(:, end:end+size(~LIA(~LIA==1), 1)) = NaN;
        point_view_matrix(file_no*2-1:file_no*2, end-(size(~LIA(~LIA==1), 1))+1:end) = inliers_im1(:, ~LIA.');

    else
        descriptors_dictionary = descriptors;
        point_view_matrix = inliers_im1;
    end
    
    disp(point_view_matrix)

    descriptors_dictionary(:, 192)
    %disp(descriptors(192, :))

    %disp(point_view_matrix)
    % point_view_matrix
    % size(point_view_matrix)
end
    
end

