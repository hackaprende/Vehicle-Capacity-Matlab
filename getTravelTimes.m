function getTravelTimes( carDataset,numCars,type )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if(strcmp(type,'totals'))
elseif(strcmp(type,'lanes'))
    cx = zeros(numCars,1);
    inOut = zeros(numCars,2);
    for i=1:numCars
        w = carDataset{i,2}(3);
        cx(i) = carDataset{i,2}(1) + w/2;
        inOut(i,:) = carDataset{i,3};
    end
    iz = find(inOut(:,2)==0);
    if(~isempty(iz))
        inOut = inOut(1:iz(1)-1,:);
        cx = cx(1:iz(1)-1);
    end
    t = diff(inOut,1,2)*(1/25);
    l = [0 100 280 400 515 640];
    % Create data for the travel times by lane
    tData = zeros(1,5);
    for i=1:5
        if(any(cx>l(i) & cx<=l(i+1)))
            tLane = t(cx>l(i) & cx<=l(i+1));
            tMean = mean(tLane);
            tData(i) = tMean; 
        end
    end 
    colores = {'r','g','b','k','y'};
    
    sz = get(0,'ScreenSize');
    w = sz(3);
    h = sz(4);
    set (figure(4),'OuterPosition',[w/2, 1 w/4 h/3]);
    nombreCarril = {'C1','C2','C3','C4' 'C5'};
    cla(gca);
    set(gca,'XGrid','off','YGrid','on');
    H = tData;
    N = numel(H);
    for i=1:N
      h = bar(i, H(i));
      if i == 1 
          hold on;
      end
      col = colores{i};
      set(h, 'FaceColor', col); 
    end
    set(gca, 'XTickLabel', '') ;  
    xlabetxt = nombreCarril([1 2 3 4 5]);
    ylim([0 1.2]); 
    ypos = -max(ylim)/50;
    text(1:N,repmat(ypos,N,1),xlabetxt','horizontalalignment','center','verticalalignment','top','FontSize',12);
    ylabel('Tiempo de viaje (seg)','FontSize',12);
    title('Tiempo de viaje por Carril','FontSize',12);
end 
end