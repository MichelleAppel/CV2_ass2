function structure_from_motion(point_view_matrix, num_images_db, ...
    max_images, aff_ambig_removal, visualize, iter_visualize)

close all;

if nargin < 1
    point_view_matrix = load('PointViewMatrix.txt');
end
if nargin < 2
    num_images_db = 3; %size(point_view_matrix, 1)/2-2;
end
if nargin < 3
    max_images = size(point_view_matrix, 1)/2-num_images_db;
end
if nargin < 4
    aff_ambig_removal = false;
end
if nargin < 5
    visualize = true;
end
if nargin < 6
    iter_visualize = false;
end

all_points = [];
prev_points = [];
for i = 1:max_images
   
    % Select a dense block from the point-view matrix
    pvm = point_view_matrix(i:i+2*num_images_db, :);

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
    S = S.';
    
    if size(all_points, 1) > 0
        [~, transformed, ~] = procrustes(prev_points, S);
        all_points = [all_points; transformed];
        prev_points = transformed;
        if iter_visualize
            figure, scatter3(transformed(:, 1), transformed(:, 2), transformed(:, 3), ...
                4, 'blue'), title(strcat('Iteration:', num2str(i)));
        end
    else
        all_points = S;
        prev_points = S;
    end

    % Eliminate affine ambiguity
    if aff_ambig_removal
        %TODO
        %M   Motion      A
        %S   Structure   X
        % ...............
        %C = ...
        %L = C * C.';
        %M = M * C;
        %S = C \ S;
    end
end

% If desired, remove outliers in the Z direction
%%outliers = isoutlier(S(3, :));
%%S = S(:, ~outliers);

% Visualize results
if visualize
    size(all_points)
    figure, scatter3(all_points(:, 1), all_points(:, 2), all_points(:, 3), ...
        4, 'red'), title('3D points (structure)');
end

end

