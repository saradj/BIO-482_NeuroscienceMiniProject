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
    
    for trial=1:size(data1Cell.Trial_Counter)
        
        % Initialyze the variables for 1 trial
        Trial_Duration=[];
        MembranePotential=[];
        SR_Vm=[];
        AP_Index=[];
        AP_Peak_Vm=[];
        
        % *** Run the analysis for 1 Trial
        SR_Vm=data1Cell.Trial_MembranePotential_SamplingRate{trial,1};
        MembranePotential=data1Cell.Trial_MembranePotential{trial,1};
                
        [AP_Index, AP_Peak_Vm, Trial_Duration]=Function_Detect_APs(MembranePotential, SR_Vm, AP_Detection, AP_Min_Amplitude);
        Total_Recording_Duration=Total_Recording_Duration+Trial_Duration;
        Tot_Numb_APs=Tot_Numb_APs+length(AP_Index);
        
        figure
        plot(MembranePotential, 'Color', '[0 0 0]')
        hold on
        plot(AP_Index,AP_Peak_Vm, 'o', 'Color', '[1 0 0]' )
        
        % ***
    end
    
    % Fill the Result structure
    
    Result.Cell_Name{c,1}=data1Cell.Cell_ID{1};
    Result.Cell_Type{c,1}=data1Cell.Cell_Type{1};
    Result.Firing_Rate(c,1)=Tot_Numb_APs/Total_Recording_Duration;
    
end

disp('Data analyzed')
pause(0.5)

%% Sort the Result structure by Cell class


[T, Ix]=sort(Result.Cell_Type);

for i=1:size(Ix,1)
    
    Result_Sorted.Cell_Name{i,1}= Result.Cell_Name{Ix(i),1};
    Result_Sorted.Cell_Type{i,1}= Result.Cell_Type{Ix(i),1};
    Result_Sorted.Firing_Rate(i,1)= Result.Firing_Rate(Ix(i),1);
    
end

Result=[];
Result=Result_Sorted;

%% SAVE THE RESULT STRUCTURE

disp('SAVING RESULTS')

StructureName='Result';
save([ResultSavePath StructureName], 'Result','-v7.3');

disp('RESULT SAVED')








