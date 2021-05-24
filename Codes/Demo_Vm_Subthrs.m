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

%% Parameters
AP_Detection=-20;
AP_Min_Amplitude=10;
AP_Vm_Deriv_Thrs=25; % Threshold to detect the AP threshold (V/s)

TimeWindow=2; % time window to compute, mean, SD and FFTs from the Vm
FreqBandLim= [1 10 30 90]; % Low- and High-frequency Band limits (Hz)

%%%%%

Trial_Type='free whisking'; % or 'active touch'
Trial=36;
% Trial=1;
%%

MembranePotential=[];
SR_Vm=[];
AP_Index=[];
AP_Peak_Vm=[];
Rec_Dur=[];
AP_Thrs_Index=[];
AP_Thrs_Vm=[];
AP_Duration=[];

Mean_Vm=[];
Vm_SD=[];
FFT_Mtrx=[];

MembranePotential=data.Trial_MembranePotential{Trial};
SR_Vm=data.Trial_MembranePotential_SamplingRate{Trial};

figure
plot(MembranePotential)

%%

[AP_Index, AP_Peak_Vm, Rec_Dur]=Function_Detect_APs(MembranePotential, SR_Vm, AP_Detection, AP_Min_Amplitude);

[AP_Thrs_Index, AP_Thrs_Vm, AP_Duration]=Function_AP_Features(MembranePotential, SR_Vm, AP_Index, AP_Peak_Vm, AP_Vm_Deriv_Thrs);


figure
plot(MembranePotential, 'Color', '[0 0 0]')
hold on
plot(AP_Index,AP_Peak_Vm, 'o', 'Color', '[1 0 0]' )
hold on
plot(AP_Thrs_Index, AP_Thrs_Vm, 'o', 'Color', '[0 0 1]')
%%

Vm_Sub=[];
[Vm_Sub]=Function_CutAPs(MembranePotential, SR_Vm, AP_Index, AP_Thrs_Index, AP_Thrs_Vm);

figure
plot(MembranePotential, 'Color', '[0 0 0]');
hold on
plot(Vm_Sub, 'Color', '[0 0 1]');

%%

Mean_Vm=[];
Vm_SD=[];
[Mean_Vm, Vm_SD]=Function_SubThrsVm(Vm_Sub, SR_Vm, TimeWindow);

%%

FFT_Mtrx=[];
[FFT_Mtrx]=Function_Compute_FFTs(Vm_Sub, SR_Vm, TimeWindow);

%%

AVG_FFT=mean(FFT_Mtrx,2);


Step=TimeWindow*SR_Vm;
nfft = 2^nextpow2(Step); % numb of point to compute the FFT
f = SR_Vm*(0:(nfft/2))/nfft; % make the frequency vector for the FFT
disp('f');
%disp(f)
disp('nf');
%disp((0:(nfft/2)));

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

