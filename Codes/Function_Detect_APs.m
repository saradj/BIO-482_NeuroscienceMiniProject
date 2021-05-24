
function [AP_Index, AP_Peak_Vm, Rec_Dur]=Function_Detect_APs(MembranePotential, SR_Vm, Threshold_Detect, Min_Amplitude)

    AP_Index=[];
    AP_Peak_Vm=[];
    Rec_Dur=[];

    [AP_Peak_Vm, AP_Index] = findpeaks(MembranePotential, 'MinPeakHeight', Threshold_Detect, 'MinPeakProminence',Min_Amplitude);
%     
    Rec_Dur =length(MembranePotential)/SR_Vm;

    
end
