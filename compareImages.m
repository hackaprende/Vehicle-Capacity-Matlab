function [ correlation ] = compareImages( image1,image2 )
% Se compara la imagen 1 contra la imagen 2
    image1 = imresize(image1,size(image2));
    correlation = corr2(image1,image2);
end

