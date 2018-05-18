function structure_from_motion(point_view_matrix, ...
    num_images, aff_ambig_removal, visualize)

close all;

if nargin < 1
    point_view_matrix = load('PointViewMatrix.txt');

end
if nargin < 2
    num_images = 4;
end
if nargin < 3
    aff_ambig_removal = false;
end
if nargin < 4
    visualize = true;
end

all_points = [];
prev_points = [];
for i = 1:50%size(point_view_matrix, 1)/2-num_images
   
    % Select a dense block from the point-view matrix
    pvm = point_view_matrix(i:i+2*num_images, :);

    % Normalize the point coordinates
    pvm(1:2:end, :) = pvm(1:2:end, :) - mean(point_view_matrix(1:2:end, :));
    pvm(2:2:end, :) = pvm(2:2:end, :) - mean(point_view_matrix(2:2:end, :));

    % Factorize D using SVD
    [ U, W, V ] = svd(pvm);

    % Derive the structure and motion matrices from the SVD
    U3 = U(:, 1:3);
    V3 = V(:, 1:3);
    W3 = W(1:3, 1:3);
    M = U3 * sqrt(W3); % motion
    S = sqrt(W3) * V3.'; % structure
    
    % Remove outliers in the Z direction
    %outliers = isoutlier(S(3, :));
    %S = S(:, ~outliers);

    if size(all_points, 1) > 0
        %if size(S, 2) > size(prev_points, 2)
        %   S = S(:, 1:size(prev_points, 2));
        %end
        %if size(prev_points, 2) > size(S, 2)
        %   prev_points = prev_points(:, 1:size(S, 2));
        %end
        [~, transformed, ~] = procrustes(prev_points.', S.');
        all_points = [all_points transformed.'];
        prev_points = transformed.';
    else
        all_points = S;
        prev_points = S;
    end

    % Eliminate affine ambiguity
    if aff_ambig_removal
        %TODO!
        %M   Motion      A
        %S   Structure   X
        % ...............
        %C = ...
        %L = C * C.';
        %M = M * C;
        %S = C \ S;
    end
end

% Visualize results
if visualize
    %disp('Size of structure matrix:')
    size(all_points)
    %disp('Size of motion matrix')
    size(M)
    figure, scatter3(all_points(1, :), all_points(2, :), all_points(3, :), 4.269, 'red'), title('3D points (structure)')
    %hold on
    %scatter3(outlier_coords(1, :), outlier_coords(2, :), outlier_coords(3, :), 4.269, 'blue')
end

end

