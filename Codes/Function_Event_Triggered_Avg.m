function [Vm_Mtrx]=Function_Event_Triggered_Avg(Vm_Sub, SR_Vm, Event_Times, Pre_Window, Post_Window, Min_Event_Dur, Min_ITI)
Vm_Mtrx=[];
cnt=1;

for i=1:size(Event_Times, 1)
    
    Event_Dur=[];
    ITI=[];
    % compute the event duration
    Event_Dur=Event_Times(i,2)-Event_Times(i,1);
    % compute the ITI (ITI = event time for the 1st event)
    if i==1
        ITI=Event_Times(i,1);
    else
        ITI=Event_Times(i,1)- Event_Times(i-1,2);
    end
    
    if Event_Dur> Min_Event_Dur && ITI>Min_ITI
       
        pt1=floor((Event_Times(i,1)-Pre_Window)*SR_Vm); 
        pt2=pt1+floor((Pre_Window+Post_Window)*SR_Vm)-1;
        
        if pt1>0 && pt2<length(Vm_Sub)
            
            Vm_Mtrx(:,cnt)=Vm_Sub(pt1:pt2,1); % cut the Vm around the event time
            
            cnt=cnt+1;
        end
    end
    
end



end