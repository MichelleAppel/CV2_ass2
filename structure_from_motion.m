function structure_from_motion()

% Select a dense block from the point-view matrix
point_view_matrix = load('PointViewMatrix.txt');
pvm = point_view_matrix(1:8, :);

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
%TODO

size(S)
size(M)
%scatter3(S(1, :), S(2, :), S(3, :))

end

