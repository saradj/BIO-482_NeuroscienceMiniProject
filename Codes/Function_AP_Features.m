function [AP_Thrs_Index, AP_Thrs_Vm, AP_Duration]=Function_AP_Features(MembranePotential, SR_Vm, AP_Index, AP_Peak_Vm, Vm_Deriv_Thrs)

AP_Thrs_Index=[];
AP_Thrs_Vm=[];
AP_Duration=[];

Vm_Deriv=diff(MembranePotential)*10^(-3)*SR_Vm;
AP_Thrs_Onset= diff((Vm_Deriv-Vm_Deriv_Thrs)./abs(Vm_Deriv-Vm_Deriv_Thrs));

for ap=1:size(AP_Index,1)
    Ind=[];
    pt2=AP_Index(ap);
    % we define a time window for the AP ...
    pt1=pt2-0.002*SR_Vm; % ... 2 ms before the peak ...
    pt3=pt2+0.003*SR_Vm; % ... and 3 ms after the peak.
    
    if pt1>0 && pt3<length(MembranePotential)
        
        [Max, Ind]=max(AP_Thrs_Onset(pt1:pt2,1)); % identify the index of the AP threshold / pt1
        AP_Thrs_Index(ap,1)=pt1+Ind-1; % index of the AP threshold / pt=1
        AP_Thrs_Vm(ap,1)=MembranePotential(pt1+Ind-1,1); % Vm at AP threshold
        
        AP_Amp=MembranePotential(pt2,1)-MembranePotential(pt1+Ind-1,1); % Amplitude of the AP
        Vm_HalfAmp=MembranePotential(pt1+Ind-1,1)+AP_Amp/2; % Vm at half amplitude
        
        sAP_Seg=MembranePotential(pt1:pt3,1); % cut a segment of the VM that contains the AP
        sAP_Seg=sAP_Seg-Vm_HalfAmp; % substract the Vm at half-amplitude
        sAP_OnOff=diff(sAP_Seg./abs(sAP_Seg)); % compute the binary signal
        
        [sAP_Max, sAP_Indmax]=max(sAP_OnOff); % identify index begening AP at half amplitude
        [sAP_Min, sAP_Indmin]=min(sAP_OnOff); % identify index end AP at half amplitude
        
        AP_Duration(ap,1)=((sAP_Indmin-sAP_Indmax)/SR_Vm)*1000; % compute duration at half-amplitude
        
        
    else
        AP_Thrs_Index(ap,1)=NaN;
        AP_Thrs_Vm(ap,1)=NaN;
        AP_Duration(ap,1)=NaN;
    end
    
end

end