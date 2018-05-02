function t_image = transform(image, trans)
    % Transformation matrix
    M = [[trans(1) -trans(2)]
         [-trans(3) trans(4)]];
    % Translation matrix
    translation = [trans(5), trans(6)]';

    [ h, w, c ] = size(image);
    if c == 3
        image = rgb2gray(image);
    end
    
    t_11 = M * [ 1; 1 ] + translation; % The transformed coordinates of the upper left corner
    t_1w = M * [ 1; w ] + translation; % The transformed coordinates of the upper right corner
    t_h1 = M * [ h; 1 ] + translation; % The transformed coordinates of the lower left corner
    t_hw = M * [ h; w ] + translation; % The transformed coordinates of the lower right corner
    
    t_ymin = min([ t_11(1), t_1w(1), t_h1(1), t_hw(1) ]); % Minimum y
    t_xmin = min([ t_11(2), t_1w(2), t_h1(2), t_hw(2) ]); % Minimum x

    t_h = max([ t_11(1), t_1w(1), t_h1(1), t_hw(1) ]) - t_ymin; % Height of the transformation
    t_w = max([ t_11(2), t_1w(2), t_h1(2), t_hw(2) ]) - t_xmin; % Width of the transformation

    t_image = zeros(ceil(t_h), ceil(t_w)); % Create empty matrix for transformation
    
    for y_t = 1:t_h
        for x_t = 1:t_w
            
            % Get the coordinates of the original image that correspond
            % with the transformed image
            im1_c = round(inv(M) * ([ y_t; x_t ] - translation + [ t_ymin; t_xmin ]));
            
            % When inside the original image, get pixel intensity
            if im1_c(1) > 0 && im1_c(1) < h && im1_c(2) > 0 && im1_c(2) < w
                t_image(y_t, x_t) = image(im1_c(1), im1_c(2));

            % Black otherwise
            else
                t_image(y_t, x_t) = 0;
            end
        end
    end
    
%     t_image_map = zeros(h, w, 3);    
%     for y = 1:h
%         for x = 1:w
%            coords = [y, x]';
%            translated_point = M * coords + translation;
%            t_y = round(translated_point(1));
%            t_x = round(translated_point(2));
%            t_image_map(y, x, 1) = t_y;
%            t_image_map(y, x, 2) = t_x;
%            t_image_map(y, x, 3) = image(y, x);
%         end
%     end
%     
%     t_image_map(:, :, 1) = t_image_map(:, :, 1) ...
%         - min(min(t_image_map(:, :, 1))) + 1;
%     t_image_map(:, :, 2) = t_image_map(:, :, 2) ...
%         - min(min(t_image_map(:, :, 2))) + 1;
%     
%     max_y = max(max(t_image_map(:, :, 1)));
%     max_x = max(max(t_image_map(:, :, 2)));
%     
%     image_trans = zeros(max_y, max_x);
%     figure, imshow(image_trans)
%     for y = 1:h
%         for x = 1:w
%             t_y = t_image_map(y, x, 1);
%             t_x = t_image_map(y, x, 2);
%             i   = t_image_map(y, x, 3);
%             image_trans(t_y, t_x) = i;
%         end
%     end
    %figure, imshow(mat2gray(t_image))
end