
function [Mean_Vm, SD_Vm]=Function_SubThrsVm(MembranePotential, SR_Vm, TimeWindow)

Numb_Wind=floor((length(MembranePotential)/SR_Vm)/TimeWindow);

for window=1:Numb_Wind-1
    
    pt1=1+TimeWindow*SR_Vm*window;
    pt2=pt1+TimeWindow*SR_Vm-1;
    
    Mean_Vm(window,1)=mean(MembranePotential(pt1:pt2,1));
    SD_Vm(window,1)=std(MembranePotential(pt1:pt2,1));
        
end


end
