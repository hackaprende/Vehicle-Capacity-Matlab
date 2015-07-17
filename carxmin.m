function [vT,vTant,tCant,tiempoAnt] = carxmin(tiempo,timepoAnt,vTant,totalCars,tCant)
     vT = totalCars-tCant;
     tCant = totalCars;
     sz = get(0,'ScreenSize');
     w = sz(1,3);
     h = sz(1,4);
     set(figure(6),'OuterPosition',[(3*w)/4,h/3,w/4,h/3]);
     hold on;
     grid on;
     title('Volumen de Tráfico','FontSize',12);
     xlabel('Tiempo (Segundos)','FontSize',12);
     ylabel('Vehículos por Segundo','FontSize',12);
     axis([0 70 0 15]);
     drawLine([timepoAnt,vTant], [tiempo,vT],'-ob');
     hold off;
     
     tiempoAnt = tiempo;
     vTant = vT;
     
end