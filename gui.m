function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 25-Aug-2013 13:55:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
imshow('autopista_alpha.jpg');

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imshow('autopista.jpg');


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%
% Create a blob analysis system object to segment cars in the video.
hblob = vision.BlobAnalysis( ...
                    'AreaOutputPort', false, ...
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

%% Stream Processing Loop
% Read sample video
video = VideoReader('video.avi');
% Read background model
bg = load('background.mat', 'background'); 
background = bg.background; 
load borders;
bg = medfilt2(uint8(background));
borders=bwmorph(im2bw(borders,0.2),'dilate',3);
% Get details
nFrames = video.NumberOfFrames;
% Program variables
lastIn = 0; numCarsStored=0; 
carStoredCell = cell(1,3);
counterCarsTotal = 0;
coefCorr = zeros(1,3);
carDataSet = cell(46,3);
% process frames 
for i=1:100
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
    [cent,bbox] = step(hblob, ero);
    numObj = size(bbox,1);
    
    % Drawing analysis regions: [y1,x1,y2,x2,...,yL,xL].
    out = step(shape2, im2double(f),[1,100,640,130]);
    
    % Identifying cars in analysis region
     in = cent(:,2)>=100 & cent(:,2)<=230;
     deltaIn = sum(in) - lastIn;
     
    % If there are cars in analysis region
    if(any(in))
        bbox = bbox(in,:);
        numCarsIn = sum(in);
        out = step(shape1, out, bbox);
        if(numCarsStored==0)
            % Save the first cars
            for j=1:numCarsIn
                temp = getTemplate(s,bbox(j,:));
                carStoredCell{j} = temp;
                numCarsStored = numCarsStored + 1;
                counterCarsTotal = counterCarsTotal + 1;
                set(handles.text1,'String',num2str(counterCarsTotal));
                carDataSet{counterCarsTotal,1} = temp; 
                carDataSet{counterCarsTotal,2} = bbox(j,:);
                carDataSet{counterCarsTotal,3} = i;
            end
        else
            % Removing cars that out of the analysis region 
            if(deltaIn<0)
                carStoredCell = cell(1,3);
                for j=1:numCarsIn
                    temp = getTemplate(s,bbox(j,:));
                    carStoredCell{j} = temp;
                end
                numCarsStored = numCarsStored + deltaIn;
            end
            % Storing or update template of the cars in analysis region
            if(deltaIn>=0)
                for j=1:numCarsIn
                    temp = getTemplate(s,bbox(j,:));
                    coefCorr = zeros(1,3);
                    for k=1:numCarsStored
                        car = carStoredCell{k};
                        coefCorr(k) = compareImages(temp,car);
                    end
                    if(deltaIn==0)
                        [~,ind] = max(coefCorr);
                        carStoredCell{ind} = temp;
                    else
                        if(sum(coefCorr>0.65)==0)
                            carStoredCell{numCarsStored+1} = temp;
                            numCarsStored = numCarsStored + 1;
                            counterCarsTotal = counterCarsTotal + 1;
                            set(handles.text1,'String',num2str(counterCarsTotal));
                            carDataSet{counterCarsTotal,1} = temp; 
                            carDataSet{counterCarsTotal,2} = bbox(j,:);
                            carDataSet{counterCarsTotal,3} = i;
                        end
                    end
                end
            end 
        end
    else
        if(deltaIn<0)
            carStoredCell = cell(1,3);
            numCarsStored = 0;
        end
    end
    lastIn=sum(in);
    imshow(out);         % Display video with bounding boxes
end