function [Vm_Sub]=Function_CutAPs(MembranePotential, SR_Vm, AP_Index, AP_Thrs_Index, AP_Thrs_Vm);

Vm_Sub=MembranePotential;
Time_to_Cut=0.002 % time after the AP peak to cut the AP (s)

for Ind=1:length(AP_Index)
    
    if isnan(AP_Thrs_Index(Ind,1)) % If the AP threshold was not computed for this AP
        
        pt1=max(1, (AP_Index(Ind,1)-0.002*SR_Vm));
        pt2=min(length(MembranePotential), (AP_Index(Ind,1)+Time_to_Cut*SR_Vm));
        
        Vm_1=Vm_Sub(pt1,1);
        Val2=Vm_Sub(pt2,1);
        Set_Vm=min(Vm_1, Val2);
       
        Vm_Sub(pt1:pt2,1)=Set_Vm;
        
    else
        
        pt1=AP_Thrs_Index(Ind,1);
        pt2=AP_Index(Ind,1)+Time_to_Cut*SR_Vm;
        
        Vm_1=Vm_Sub(pt1,1);
        Vm_2=Vm_Sub(pt2,1);
        Delta_Vm=Vm_2-Vm_1;
        
        % make a segment 'in' between Vm(pt1) and Vm(pt2)
        
        in=0:1:pt2-pt1; % create a small vector starting at 0, with increment of 1, of (pt2-pt1) points
        in=(in./(pt2-pt1))*Delta_Vm; % create a segment of (pt2-pt1) points from 0 to Delta_Vm
        in=in+Vm_1; % add the Vm at pt1 to the segment in
        
        Vm_Sub(pt1:pt2,1)=in; % replace the Vm between pt1 and pt2 by the segment in
                
    end
    
end