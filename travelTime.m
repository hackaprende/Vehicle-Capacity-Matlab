function [tvp,tvpant] = travelTime(rate,framesAct,tvpant,totalCars)
    tvp = ((((framesAct(2)- framesAct(1)))/rate)+tvpant)/totalCars;
    tvpant = tvp;
end