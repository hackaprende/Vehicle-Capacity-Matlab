%% Object detection using background subtraction
clc; clear all; close all; 

%% 
% Create System objects to display the original video, background 
% subtraction video, the thresholded video and the results.
sz = get(0,'ScreenSize'); bx = 10; by = 115;
x = bx; y = sz(4)-(480); w = sz(3)/2-2*bx; h = sz(4)/2;
pos = [x y w h];
hVideo1 = vision.VideoPlayer('Name','Results','Position',pos);

%%
% Create a blob analysis system object to segment cars in the video.
hblob = vision.BlobAnalysis( ...
                    'AreaOutputPort', true, ...
                    'CentroidOutputPort', true, ...
                    'BoundingBoxOutputPort', true, ...
                    'OutputDataType', 'double');
                
%% 
% Create and configure a system objects that insert shapes, for drawing the
% bounding box around the cars. 
shape1 = vision.ShapeInserter( ...
                    'BorderColor', 'Custom', ...
                    'CustomBorderColor', [1 1 0]);
shape2 = vision.ShapeInserter( ...
                    'BorderColor', 'Custom', ...
                    'CustomBorderColor', [1 1 1]);
lane1 = vision.ShapeInserter( ...
                    'Shape','Polygons', ...
                    'Fill', true, ...
                    'FillColor', 'Custom', ...
                    'CustomFillColor', [255 0 0], ...
                    'Opacity', 0.0005);
lane2 = vision.ShapeInserter( ...
                    'Shape','Polygons', ...
                    'Fill', true, ...
                    'FillColor', 'Custom', ...
                    'CustomFillColor', [0 255 0], ...
                    'Opacity', 0.0005);
lane3 = vision.ShapeInserter( ...
                    'Shape','Polygons', ...
                    'Fill', true, ...
                    'FillColor', 'Custom', ...
                    'CustomFillColor', [0 0 255], ...
                    'Opacity', 0.0005);
lane4 = vision.ShapeInserter( ...
                    'Shape','Polygons', ...
                    'Fill', true, ...
                    'FillColor', 'Custom', ...
                    'CustomFillColor', [0 0 0], ...
                    'Opacity', 0.0005);
lane5 = vision.ShapeInserter( ...
                    'Shape','Polygons', ...
                    'Fill', true, ...
                    'FillColor', 'Custom', ...
                    'CustomFillColor', [255 255 0], ...
                    'Opacity', 0.0005);
                
%% Stream Processing Loop
% Read sample video
video = VideoReader('video.avi');
% Read background model
load background;
load borders;
bg = medfilt2(uint8(background));
borders=bwmorph(im2bw(borders,0.2),'dilate',3);
% Get details
nFrames = video.NumberOfFrames;
rate = video.FrameRate;
% Program variables
lastIn = 0; numCarsStored=0; 
carStoredCell = cell(3,2);
counterCarsTotal = 0;
coefCorr = zeros(1,3);
carDataSet = cell(46,4);
% process frames 
% Variable initialization
contxcar = zeros(1,5);
tCant = 0;
vT = 0;
vTant = 0;
tiempoAnt = 0;
dt = 5;

for i=1:nFrames
    % Capturing a frame
    f = read(video,i);
    % Gray scaling
    g = rgb2gray(f);    
    % Smoothing
    s = medfilt2(g);  
    % Frame difference
    d = imabsdiff(s,bg); 
    % Difference binarized
    b = im2bw(d,0.20);
    % remove small objects
    b = bwareaopen(b&not(borders), 20, 8);
    % Dilation 
    dil = bwmorph(b,'dilate',5);
    % Erosion
    ero = bwmorph(dil,'erode');
    ero = bwareaopen(ero, 450, 8);
    % Objects bounding boxes
    [area,cent,bbox] = step(hblob, ero);
    numObj = size(bbox,1);
    
    % Drawing analysis regions: [y1,x1,y2,x2,...,yL,xL].
    % out = step(shape2, im2double(f),[1,100,640,130]);
    out = step(lane1, im2double(f),[140,100,210,100,100,230,1,230]);
    out = step(lane2, out,[210,100,330,100,280,230,100,230]);
    out = step(lane3, out,[330,100,410,100,400,230,280,230]);
    out = step(lane4, out,[410,100,490,100,513,230,400,230]);
    out = step(lane5, out,[100,490,100,565,230,620,230,513]);
    out = step(lane5, out,[490,100,565,100,620,230,513,230]);
    
    % Identifying cars in analysis region
     in = cent(:,2)>=100 & cent(:,2)<=230;
     deltaIn = sum(in) - lastIn;
     
    % If there are cars in analysis region
    if(any(in))
        bbox = bbox(in,:);
        area = area(in);
        numCarsIn = sum(in);
        out = step(shape1, out, bbox);
        if(numCarsStored==0)
            % Save the first cars
            for j=1:numCarsIn
                temp = getTemplate(s,bbox(j,:));
                numCarsStored = numCarsStored + 1;
                counterCarsTotal = counterCarsTotal + 1;
                carStoredCell{numCarsStored,1} = temp;
                carStoredCell{numCarsStored,2} = counterCarsTotal;
                carDataSet{counterCarsTotal,1} = temp; 
                carDataSet{counterCarsTotal,2} = bbox(j,:);
                carDataSet{counterCarsTotal,3} = [i,0];
                carDataSet{counterCarsTotal,4} = area(j);              
                % Counting by lane and traffic composition plots
                contxcar = conteoCarril(contxcar,bbox(j,:));
                getTrafficComposition(carDataSet,counterCarsTotal,'totals');
                showDetectedCar(temp);
            end
        else
            % Removing cars that out of the analysis region 
            if(deltaIn<0)
                aux = cell(3,2);
                for j=1:numCarsIn
                    temp = getTemplate(s,bbox(j,:));
                    coefCorr = zeros(1,3);
                    for k=1:numCarsStored
                        car = carStoredCell{k,1};
                        coefCorr(k) = compareImages(temp,car);
                    end
                    [~,ind] = max(coefCorr);
                    aux(j,:) = carStoredCell(ind,:);
                end
                indCarStored = cell2mat(carStoredCell(:,2));
                indCarIn = cell2mat(aux(:,2));
                indCarOut = setdiff(indCarStored,indCarIn);
                carDataSet{indCarOut,3}(1,2) = i; 
                carStoredCell = aux;
                numCarsStored = numCarsStored + deltaIn;
                % Velocities and travel times by lane plots
                getVelocities(carDataSet,counterCarsTotal,'lanes');
                getTravelTimes(carDataSet,counterCarsTotal,'lanes');
                % Data table creation
                createDataTable(carDataSet,counterCarsTotal-numCarsIn);
            end
            % Storing or update template of the cars in analysis region
            if(deltaIn>=0)
                for j=1:numCarsIn
                    temp = getTemplate(s,bbox(j,:));
                    coefCorr = zeros(1,3);
                    for k=1:numCarsStored
                        car = carStoredCell{k,1};
                        coefCorr(k) = compareImages(temp,car);
                    end
                    if(deltaIn==0)
                        [~,ind] = max(coefCorr);
                        carStoredCell{ind,1} = temp;
                    else
                        if(sum(coefCorr>0.65)==0)
                            numCarsStored = numCarsStored + 1;
                            counterCarsTotal = counterCarsTotal + 1;
                            carStoredCell{numCarsStored,1} = temp;
                            carStoredCell{numCarsStored,2} = counterCarsTotal;
                            carDataSet{counterCarsTotal,1} = temp; 
                            carDataSet{counterCarsTotal,2} = bbox(j,:);
                            carDataSet{counterCarsTotal,3} = [i,0];
                            carDataSet{counterCarsTotal,4} = area(j);
                            % Counting by lane and traffic composition plots
                            contxcar = conteoCarril(contxcar,bbox(j,:));
                            getTrafficComposition(carDataSet,counterCarsTotal,'totals');
                            showDetectedCar(temp);
                        end
                    end
                end
            end 
        end
    else
        if(deltaIn<0)
            indCarOut = cell2mat(carStoredCell(:,2));
            for j=1:numCarsStored
                carDataSet{indCarOut(j),3}(1,2) = i;
            end
            carStoredCell = cell(3,2);
            numCarsStored = 0;
            % Velocities and travel times by lane plots
            getVelocities(carDataSet,counterCarsTotal,'lanes');
            getTravelTimes(carDataSet,counterCarsTotal,'lanes');
            % Data table creation
            createDataTable(carDataSet,counterCarsTotal);
        end
    end    
    if (mod((i/rate),dt)==0)
        tiempo = (i/rate);
        [vT,vTant,tCant,tiempoAnt] = carxmin(tiempo,tiempoAnt,vTant,counterCarsTotal,tCant);
    end
    lastIn=sum(in);
    step(hVideo1, out);         % Display video with bounding boxes
end
tvpant = 0;
tvp = zeros(size(carDataSet,1),1);
for i=1:(size(carDataSet,1)-1)
    framesAct = carDataSet{i,3};
    [tvp(i),tvpant] = travelTime(rate,framesAct,tvpant,i);
end