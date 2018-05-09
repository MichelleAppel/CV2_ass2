function [ d ] = sampson_dist(inliers_im1, inliers_im2, F)

inliers_im1(3, :) = ones(size(inliers_im1, 2), 1);
inliers_im2(3, :) = ones(size(inliers_im2, 2), 1);

for i = 1:size(inliers_im1, 2)
    toppie = (inliers_im1(:, i).' * F * inliers_im1(:, i))^2;
    
    Fp11 = F * inliers_im1;
    Fp11 = Fp11(1, i)^2;

    Fp12 = F * inliers_im1;
    Fp12 = Fp12(2, i)^2;

    Fp21 = F.' * inliers_im2;
    Fp21 = Fp21(1, i)^2;

    Fp22 = F.' * inliers_im2;
    Fp22 = Fp22(2, i)^2;
    
    d(i) = toppie / (Fp11 + Fp12 + Fp21 + Fp22);
end

end

