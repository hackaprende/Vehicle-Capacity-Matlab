function [t] = crearTabla(numFig,posFig,datos,cnames,rnames,posTab)
    f = figure(numFig);
    set(1,'Position',posFig);
    t = uitable('Parent',f,'Data',datos,'ColumnName',cnames,'RowName',rnames,'Position',posTab);   
end