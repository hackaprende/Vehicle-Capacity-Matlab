function [contxcar] = conteoCarril(contxcar,bbox)
    
    cx = bbox(1,1) + bbox(1,3)/2;
    colores = {'r','g','b','k','y'};
    if (cx>0 && cx<=100)
        contxcar(1,1) = contxcar(1,1)+1;
    elseif (cx>100 && cx<=280)
        contxcar(1,2) = contxcar(1,2)+1;
    elseif (cx>280 && cx<=400)
        contxcar(1,3) = contxcar(1,3)+1;
    elseif (cx>400 && cx<=515)
        contxcar(1,4) = contxcar(1,4)+1;
    elseif (cx>515 && cx<=640)
        contxcar(1,5) = contxcar(1,5)+1;
    end
    
    sz = get(0,'ScreenSize');
    w = sz(3);
    h = sz(4);
    set (figure(2),'OuterPosition',[w/2, (2*h)/3, w/4, h/3]);
    nombreCarril = {'C1','C2','C3','C4' 'C5'};
    set(gca,'XGrid','off','YGrid','on');
    H = contxcar;
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
    ylim([0 20]); 
    ypos = -max(ylim)/50;
    text(1:N,repmat(ypos,N,1),xlabetxt','horizontalalignment','center','verticalalignment','top','FontSize',12);
    ylabel('Número de Vehículos','FontSize',12);
    title('Conteo de Vehículos por Carril','FontSize',12);
end