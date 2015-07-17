function getVelocities( carDataset,numCars,type)
if(strcmp(type,'totals'))
    inOut = zeros(numCars,2);
    for i=1:numCars
        inOut(i,:) = carDataset{i,3};
    end
    iz = find(inOut(:,2)==0);
    if(~isempty(iz))
        inOut = inOut(1:iz(1)-1,:);
    end
    v = (10./(diff(inOut,1,2)*(1/25)))*(3.6);
    vMin = min(v); vMax = max(v); vMean = mean(v);
    % Create the data for the velocities
    velocities = [vMin,vMax,vMean];
    types = {'Vmín','Vmáx','Vprom'};
    % Plot the velocities on a vertical bar chart
    set(figure(3));
    bar(velocities);
    % Set the axis limits
    axis([0 4 0 50]);
    % Add a title and axis 
    title('Velocidades totales');
    ylabel('Magnitud en Km/h');
    % Change the X axis tick labels to use the types
    set(gca, 'XTickLabel', types);    
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
    v = (10./(diff(inOut,1,2)*(1/25)))*(3.6);
    l = [0 100 280 400 515 640];
    % Create data for the velocities by lane
    vData = zeros(1,5);
    for i=1:5
        if(any(cx>l(i) & cx<=l(i+1)))
            vLane = v(cx>l(i) & cx<=l(i+1));
            vMean = mean(vLane);
            vData(i) = vMean; 
        end
    end
    colores = {'r','g','b','k','y'};
    
    sz = get(0,'ScreenSize');
    w = sz(3);
    h = sz(4);
    set (figure(3),'OuterPosition',[w/2, h/3 ,w/4, h/3]);
    nombreCarril = {'C1','C2','C3','C4' 'C5'};
    cla(gca);
    set(gca,'XGrid','off','YGrid','on');
    H = vData;
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
    ylim([0 50]); 
    ypos = -max(ylim)/50;
    text(1:N,repmat(ypos,N,1),xlabetxt','horizontalalignment','center','verticalalignment','top','FontSize',12);
    ylabel('Velocidad en Km/h','FontSize',12);
    title('Velocidad promedio por carril','FontSize',12);
end
end