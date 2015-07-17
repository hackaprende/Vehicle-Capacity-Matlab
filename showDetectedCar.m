function showDetectedCar( temp )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

sz = get(0,'ScreenSize');
w = sz(3);
h = sz(4);
set(figure(7),'OuterPosition',[(3*w)/4, 1, w/4,h/3]);
%imshow(imresize(uint8(temp),[240 305]),'Border','tight');
imagesc(imresize(uint8(temp),[155 143]));
colormap(gray);
axis off; title('Vehículo detectado','FontSize',12);
end

