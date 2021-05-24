function  [APs_Mtrx]=Function_Event_Triggered_AP_Numb(AP_Index, SR_Vm, Event_Times, Pre_Window, Post_Window, Min_Event_Dur, Min_ITI)

APs_Mtrx=[];
cnt=1;

pre_ind=floor(-Pre_Window*SR_Vm); % lower limit for the AP indices
post_ind=floor(Post_Window*SR_Vm); % upper limit for the AP indices

for i=1:size(Event_Times, 1)
    
    Event_Dur=[];
    ITI=[];
    %compute the duration of the event
    Event_Dur=Event_Times(i,2)-Event_Times(i,1);
    
    % compute the ITI (ITI = onset time for the first event)
    if i==1
        ITI=Event_Times(i,1);
    else
        ITI=Event_Times(i,1)- Event_Times(i-1,2);
    end
    
    
    
    if Event_Dur> Min_Event_Dur && ITI>Min_ITI
        pt0=floor(Event_Times(i,1)*SR_Vm); % Index of the event time
        pt1=floor((Event_Times(i,1)-Pre_Window)*SR_Vm); % Index of event time - Pre_window
        
        if pt1>0
            AP_Index_t0=[];
            AP_Index_t0=AP_Index-pt0;  
            APs_Mtrx{cnt,1}=AP_Index_t0(AP_Index_t0>pre_ind& AP_Index_t0<post_ind); % Take all the APs indices within the range of interest
            
            cnt=cnt+1;
        end
    end
    
end

end