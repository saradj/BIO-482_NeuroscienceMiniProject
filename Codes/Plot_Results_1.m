clc
clear all
close all

if ispc
    FileloadPath=['C:\Users\Sara\Desktop\MASTER\Neuroscience\BIO482_MiniProject\BIO482_MiniProject\Result' '\']; % path to load the Result structure
    FigureSavePath=['C:\Users\Sara\Desktop\MASTER\Neuroscience\BIO482_MiniProject\BIO482_MiniProject\Figures' '\']; % path to save the figures
    
elseif ismac
    FileloadPath=['D:/BIO482_MiniProject/Result' '/']; % path to load the Result structure
    FigureSavePath=['D:/BIO482_MiniProject/Figures' '/']; % path to save the figures
end 

disp('LOADING DATA STRUCTURE')
pause(0.5)

StructureName='Result'; 
load([FileloadPath StructureName]);


disp('DATA STRUCTURE LOADED')
pause(0.5)
%% Parameters

TimeWindow=2;
FreqBandLim= [1 10 30 90]; % Low- and High-frequency Band limits
SR_Vm=40000;
Trial_Type='free whisking'; % or 'active touch'


%% Make figure

figure
plot(Result.Firing_Rate, 'o', 'color', '[0 0 0]')

ax = gca;
ax.TickDir = 'out';
xlim([0 21])
ylim([0 50])
Graph_Title=['Mean Firing Rate - ', Trial_Type];
title(Graph_Title) % write the tittle of the graph
xlabel('Cell #') % label the x axis
ylabel('Duration (s)') % label the y axis

%% SAVE THE RESULT FIGURES

disp('Saving Figure')
pause(0.5)

Expression=[FigureSavePath 'Figure 1'];

print('-painters', '-depsc', Expression)
print('-painters', '-djpeg', Expression)

disp('DONE')
pause(0.5)

%% Make Result table for each cell

Result_Table=[];

Result_Table=table(Result.Cell_Name, Result.Cell_Type, Result.Firing_Rate, ...
        'VariableNames',{'Cell_Name', 'Cell_Type', 'Firing_Rate'})
    
Expression=[FigureSavePath 'Result_Table.xls'];
writetable(Result_Table,Expression)

%% Make a table for average across cell class

CellClassMeans=[];
Mean_Table=[];

Cell_Class_List={'EXC', 'PV', 'SST', 'VIP'};

for i=1:4
    CellClassMeans.Cell_Class{i,1}=Result.Cell_Type{(strcmp(Result.Cell_Type, Cell_Class_List{i}))};
    CellClassMeans.Firing_Rate(i,1)=mean(Result.Firing_Rate((strcmp(Result.Cell_Type, Cell_Class_List{i}))));
    CellClassMeans.Firing_Rate(i,2)=std(Result.Firing_Rate((strcmp(Result.Cell_Type, Cell_Class_List{i}))));
end

Mean_Table=table(CellClassMeans.Cell_Class, CellClassMeans.Firing_Rate, ...  
'VariableNames',{'Cell_Class', 'Firing_Rate'})
Expression=[FigureSavePath 'Mean_Table.xls'];
writetable(Mean_Table, Expression)

%% Conpare mean Firing Rates across cells
Tobeplotted=[];
Tobeplotted=Result.Firing_Rate;

figure

plot([1 1 1 1 1], Tobeplotted(1:5,1), 'O', 'Color', '[0 0 0]')
hold on
plot([1.5 1.5 1.5 1.5 1.5], Tobeplotted(6:10,1), 'O', 'Color', '[1 0 0]')
hold on
plot([2 2 2 2 2], Tobeplotted(11:15,1), 'O', 'Color', '[1 0.5 0]')
hold on
plot([2.5 2.5 2.5 2.5 2.5], Tobeplotted(16:20,1), 'O', 'Color', '[0 0 1]')
hold on
errorbar([1.2 1.7 2.2 2.7], CellClassMeans.Firing_Rate(:,1), CellClassMeans.Firing_Rate(:,2),'O' , 'MarkerSize', 10,'Color', '[0 0 0]')

ax = gca;
ax.TickDir = 'out';
ax.XTick=[1, 1.5, 2, 2.5];
ax.XTickLabels={'EXC', 'PV', 'SST', 'VIP'};
xlim([0.8 3])
ylim([-1 40])
Graph_Title=['Mean Firing Rate - ', Trial_Type];
title(Graph_Title) % write the tittle of the graph
xlabel('Cell Class') % label the x axis
ylabel('FR (Hz)') % label the y axis

%% SAVE THE RESULT FIGURES

disp('Saving Figure')
pause(0.5)

Expression=[FigureSavePath '1_Mean_Firing_Rate'];

print('-painters', '-depsc', Expression)
print('-painters', '-djpeg', Expression)

disp('DONE')
pause(0.5)
