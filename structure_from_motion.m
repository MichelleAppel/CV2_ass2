function structure_from_motion(point_view_matrix, num_images, ...
    aff_ambig_removal, visualize)

if nargin < 1
    point_view_matrix = load('PointViewMatrix.txt');

end
if nargin < 2
    num_images = 8;
end
if nargin < 3
    aff_ambig_removal = false;
end
if nargin < 4
    visualize = true;
end

% Select a dense block from the point-view matrix
pvm = point_view_matrix(1:num_images*2, :);

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

% Visualize results
if visualize
    disp('Size of structure matrix:')
    size(S)
    disp('Size of motion matrix')
    size(M)
    figure, scatter3(S(1, :), S(2, :), S(3, :)), title('3D points (structure)')
end

end

