function [ template ] = getTemplate( image,bbox )
    template = image(bbox(1,2):bbox(1,2)+bbox(1,4),...
                     bbox(1,1):bbox(1,1)+bbox(1,3));
end