function getTrafficComposition( carDataset,numCars,type )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if(strcmp(type,'totals'))
    area = zeros(numCars,1);
    for i=1:numCars
        area(i) = carDataset{i,4};
    end
    l = [0 1961 5991 7230 10795];
    % Create data for the traffic composition
    aData = zeros(1,4);
    for i=1:4
        if(any(area>l(i) & area<=l(i+1)))
            aData(i) = sum(area>l(i) & area<=l(i+1));
        end
    end
    
    sz = get(0,'ScreenSize');
    w = sz(3);
    h = sz(4);
    set(figure(5),'OuterPosition',[(3*w)/4,(2*h)/3,w/4,h/3]);    
    %{'Moto','Veh. peq','Veh. med','Veh. gra'}
    h = pie(aData,[0 1 0 0]);
    title('Composición de tráfico','FontSize',12);
    % The pie chart's labels are text graphics objects. To modifythe text 
    % strings and their positions, first get the objects' stringsand extents. 
    textObjs = findobj(h,'Type','text');
    oldStr = get(textObjs,{'String'});
    val = get(textObjs,{'Extent'});
    oldExt = cat(1,val{:});
    % Create the new strings, and set the text objects' String propertiesto 
    % the new strings:
    NamesAux = {'Moto: ';'Peq: ';'Med: ';'Gra: '};
    ind = find(aData); Names = cell(numel(ind),1);
    for i=1:numel(ind)
        Names{i} = NamesAux{ind(i)};
    end
    newStr = strcat(Names,oldStr);
    set(textObjs,{'String'},newStr)
    % Find the difference between the widths of the new and old textstrings
    % and change the values of the Position properties:
    val1 = get(textObjs, {'Extent'});
    newExt = cat(1, val1{:});
    offset = sign(oldExt(:,1)).*(newExt(:,3)-oldExt(:,3))/2;
    pos = get(textObjs, {'Position'});
    textPos =  cat(1, pos{:});
    textPos(:,1) = textPos(:,1)+offset;
    set(textObjs,{'Position'},num2cell(textPos,[3,2]))

elseif(strcmp(type,'lanes'))
end
end

