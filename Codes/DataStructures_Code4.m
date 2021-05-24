clc
clear all
close all

disp('LOADING DATA STRUCTURE')
pause(0.5)

if ispc
    FileloadPath=['C:\Users\Sara\Desktop\MASTER\Neuroscience\BIO482_MiniProject\BIO482_MiniProject\Data' '\']; % path to load the data structure
    ResultSavePath=['C:\Users\Sara\Desktop\MASTER\Neuroscience\BIO482_MiniProject\BIO482_MiniProject\Result' '\']; % path to save the result structure
    FigureSavePath=['C:\Users\Sara\Desktop\MASTER\Neuroscience\BIO482_MiniProject\BIO482_MiniProject\Figures' '\']; % path to save the figures
    
    StructureName='MiniProjectData';
    load([FileloadPath StructureName]);
    
elseif ismac
    FileloadPath=['D:/BIO482_MiniProject/Data' '/']; % path to load the data structure
    ResultSavePath=['D:/BIO482_MiniProject/Result' '/']; % path to save the result structure
    FigureSavePath=['D:/BIO482_MiniProject/Figures' '/']; % path to save the figures
    
    StructureName='MiniProjectData';
    load([FileloadPath StructureName]);
    
end

disp('DATA STRUCTURE LOADED')
pause(0.5)
%% Parameters used for the analysis

disp('Set the parameters for analysis')
pause(0.5)

Trial_Type='free whisking'; % or 'active touch'
AP_Detection=-20; % Minimum Vm for AP detection (mV)
AP_Min_Amplitude=10; % Minimum amplitude for AP detection (mV)
%
AP_Vm_Deriv_Thrs=25; % Threshold to detect the AP threshold (V/s)
%
TimeWindow=2; % time window to compute, mean, SD and FFTs from the Vm
FreqBandLim= [1 10 30 90]; % Low- and High-frequency Band limits (Hz)


disp('Parameters set')
pause(0.5)

%% Select for 1 trial type

disp('Select for 1 Trial type')
pause(0.5)


myFields = fieldnames(data); % all the fields of the datastructure
% select for each field only the values for which the trial = Trial_Type
for thisField = 1:length(myFields)
    dataSelect.(cell2mat(myFields(thisField))) = data.(cell2mat(myFields(thisField)))(strcmp(data.Trial_Type, Trial_Type));
end

data=[];
data=dataSelect; % replace the datastructure data with the new one
clear dataSelect
disp('Done')
pause(0.5)


%% Create a Cell_ID field in the data structure

disp('Create Cell_ID field')
pause(0.5)

Cell_List=[];

for i=1:size(data.Mouse_Name,1)
    
    data.Cell_ID{i,1}=[data.Mouse_Name{i,1} '_' num2str(data.Cell_Counter(i,1))];
    
end

Cell_List=unique(data.Cell_ID); % generate the list of unique Cells

disp('Cell_ID created')
pause(0.5)

%% RUN THE ANALYSIS

disp('Analyze data')
pause(0.5)

% Initialyze the the output structure
Result=[];


for c=1:size(Cell_List,1) % loop across the different Cells
    disp('size');
    disp((size(Cell_List)));
    % initialyze the structure and variables
    data1Cell=[];% initialyze the structure for 1 Cell
    
    % make a new data structure for only 1 Cell
    
    Cell_Name=Cell_List{c,1}; % set the name of 1 Cell
    
    myFields = fieldnames(data);
    for thisField = 1:length(myFields)
        data1Cell.(cell2mat(myFields(thisField))) = data.(cell2mat(myFields(thisField)))(strcmp(data.Cell_ID, Cell_Name)==1);
    end
    
    % *** Run the analysis for 1 Cell ****
    
    % Initialyze the variables for 1 Cell
    Total_Recording_Duration=0;
    Tot_Numb_APs=0; 
    Tot_AP_Thrs=[]; %%% 
    Tot_AP_Dur=[]; %%%
    FFT_Mtrx=[];
    for trial=1:size(data1Cell.Trial_Counter)
        
        % Initialyze the variables for 1 trial
        Trial_Duration=[];
        MembranePotential=[];
        SR_Vm=[];
        AP_Index=[];
        AP_Peak_Vm=[];
        AP_Thrs_Index=[]; %%%
        AP_Thrs_Vm=[]; %%%
        AP_Duration=[]; %%%
        
        % *** Run the analysis for 1 Trial
        SR_Vm=data1Cell.Trial_MembranePotential_SamplingRate{trial,1};
        MembranePotential=data1Cell.Trial_MembranePotential{trial,1};
                
        [AP_Index, AP_Peak_Vm, Trial_Duration]=Function_Detect_APs(MembranePotential, SR_Vm, AP_Detection, AP_Min_Amplitude);
        Total_Recording_Duration=Total_Recording_Duration+Trial_Duration;
        Tot_Numb_APs=Tot_Numb_APs+length(AP_Index);
        
        [AP_Thrs_Index, AP_Thrs_Vm, AP_Duration]=Function_AP_Features(MembranePotential, SR_Vm, AP_Index, AP_Peak_Vm, AP_Vm_Deriv_Thrs);
       
        Tot_AP_Thrs=vertcat(Tot_AP_Thrs, AP_Thrs_Vm);
        Tot_AP_Dur=vertcat(Tot_AP_Dur, AP_Duration);
        
%         figure
%         plot(MembranePotential, 'Color', '[0 0 0]')
%         hold on
%         plot(AP_Index,AP_Peak_Vm, 'o', 'Color', '[1 0 0]' )
        
        % ***
        Vm_Sub=[];
        [Vm_Sub]=Function_CutAPs(MembranePotential, SR_Vm, AP_Index, AP_Thrs_Index, AP_Thrs_Vm);
        
        [FFT_New_Mtrx]=Function_Compute_FFTs(Vm_Sub, SR_Vm, TimeWindow);

        FFT_Mtrx= horzcat(FFT_Mtrx,FFT_New_Mtrx);

    AVG_FFT=mean(FFT_Mtrx,2);
    Step=TimeWindow*SR_Vm;
    nfft = 2^nextpow2(Step); % numb of point to compute the FFT
    f = SR_Vm*(0:(nfft/2))/nfft; % make the frequency vector for the FFT
    

    Freq=100; % set the frequency range to display the FFT
    Fpt=round((Freq*nfft)/SR_Vm); % compute the number of points to display
    figure

    semilogx(f(1:Fpt),AVG_FFT(1:Fpt),'Linewidth',1,'color', [0 0 0]) 
    %disp(f(1:3))
    ax=gca;
    ax.TickDir = 'out';
    xlim([0.5 100])
    ylim([0 3])
    Graph_Title=['FFT'];
    title(Graph_Title) % write the tittle of the graph
    xlabel('f (Hz)') % label the x axis
    ylabel('Amp (mV)') % label the y axis
    FreqBandppt=round((FreqBandLim*nfft)/SR_Vm)+1; % the resolution of the FFT (df) is 1/timewindow ...
    % ...but the timewindow used to compute the FFT is nfft/SR_Vm therefore
    % df=SR_Vm/nfft and the point of the FFT for a given frequency F is F/df =
    % F.nfft/SR_Vm
    Mean_LF_FFT=mean(AVG_FFT(FreqBandppt(1):FreqBandppt(2)));
    Mean_HF_FFT=mean(AVG_FFT(FreqBandppt(3):FreqBandppt(4)));

    end
    
    % Fill the Result structure
    
    Result.Cell_Name{c,1}=data1Cell.Cell_ID{1};
    Result.Cell_Type{c,1}=data1Cell.Cell_Type{1};
    Result.Firing_Rate(c,1)=Tot_Numb_APs/Total_Recording_Duration;
    Result.AP_Threshold(c,1)=mean(Tot_AP_Thrs, 'omitnan'); %%%
    Result.AP_Duration(c,1)=mean(Tot_AP_Dur, 'omitnan'); %%%
    
end

disp('Data analyzed')
pause(0.5)

%% Sort the Result structure by Cell class


[T, Ix]=sort(Result.Cell_Type);

for i=1:size(Ix,1)
    
    Result_Sorted.Cell_Name{i,1}= Result.Cell_Name{Ix(i),1};
    Result_Sorted.Cell_Type{i,1}= Result.Cell_Type{Ix(i),1};
    Result_Sorted.Firing_Rate(i,1)= Result.Firing_Rate(Ix(i),1);
    Result_Sorted.AP_Threshold(i,1)= Result.AP_Threshold(Ix(i),1);
    Result_Sorted.AP_Duration(i,1)= Result.AP_Duration(Ix(i),1);
end

Result=[];
Result=Result_Sorted;

%% SAVE THE RESULT STRUCTURE

disp('SAVING RESULTS')

StructureName='Result';
save([ResultSavePath StructureName], 'Result','-v7.3');

disp('RESULT SAVED')








