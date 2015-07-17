function createDataTable( carDataset,numCars )
%carDataset,numCars
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
data = cell(numCars,5);
for i=1:numCars
    x = carDataset{i,2}(1);
    inOut = carDataset{i,3};
    area = carDataset{i,4};
    % Obtaining vehicle size and lane
    type = {'Moto','Pequeño','Mediano','Grande'};
    l = [0 1961 5991 7230 10795];
    for j=1:4
        if(area>l(j) && area<=l(j+1))
            size = j;
        end
    end    
    l = [0 100 280 400 515 640];
    for j=1:5
        if(x>l(j) && x<=l(j+1))
            lane = j;
        end
    end
    % Get the travel time
    time = diff(inOut,1,2)*(1/25);
    % Calculate the velocity
    vel = (10./(diff(inOut,1,2)*(1/25)))*(3.6);
    data{i,1} = num2str(i);
    data{i,2} = type{size};
    data{i,3} = num2str(lane);
    data{i,4} = [num2str(time),' seg'];
    data{i,5} = [num2str(vel),' km/hr'];
end

f = figure(1);

sz = get(0,'ScreenSize');
w = sz(3);
h = sz(4);
set(f,'OuterPosition',[1,1,w/2,300]);
cnames = {'Número de vehículo','Tamaño de vehículo','Número de carril','Tiempo de viaje','Velocidad'};
t = uitable('Parent',f,'Data',data,'ColumnName',cnames,'Position',[20,20,w/2-60,220],'RowName',[],'ColumnWidth',{116});
end

