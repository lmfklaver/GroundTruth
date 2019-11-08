%% This script is gets the spectrogram figures out

% Lianne's adaptation of Reagan's script

% addpaths
addpath(genpath('C:\Users\lklaver\Documents\GitHub\buzcode'))
addpath(genpath('E:\Dropbox\Code\GroundTruth\'))

% % fix this:
% pathInfo.excelPath       = fullfile(['E:\ReaganB\R_Bullins\Excel_Info_Docs\', excelDoc]); % %read the excel doc into a struct

% Go into kilosort folder for juxtacellular data
% pathInfo.JuxtaPath = fullfile(['E:\ReaganB\GT_Recorded_Cells\' RecordingNum '\' Cell '\' BZ '\' recordingsGT(iRec).kiloJuxta]);
% pathInfo.ExtraPath = fullfile(['E:\ReaganB\GT_Recorded_Cells\' RecordingNum '\' Cell '\' BZ '\' recordingsGT(iRec).kiloExtra]);
% pathInfo.Recpath    = fullfile(['E:\ReaganB\GT_Recorded_Cells\' RecordingNum '\' Cell '\' BZ]);
%
% pathInfo.JuxtaPath = 'E:\ReaganB\GT_Recorded_Cells\Dan Hippo Cell\1_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
% pathInfo.ExtraPath = 'E:\ReaganB\GT_Recorded_Cells\Dan Hippo Cell\1_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
% pathInfo.Recpath = 'E:\ReaganB\GT_Recorded_Cells\Dan Hippo Cell\1_190315_152315';

% excelDoc  = 'GT_cells.xlsx';
% idxInExcelDoc = 9;

sessions = {'m14_190326_155432',...
    'm14_190326_160710_cell1',...
    'm15_190315_142052_cell1',...
    'm15_190315_145422',...
    'm15_190315_150831_cell1',...
    'm15_190315_152315_cell1',...
    'm52_190731_145204_cell3'};

areas = {'hpc','hpc','cx','hpc','hpc','hpc','th'};


%   Options
opts.rangeSpkBin = .001; %binsize for extra occurring before or after juxta % maybe a bit wider for james' irc2 output?
opts.timWinWavespec = 250; %ms
opts.doSave = 0;
opts.freqRange = [1 500];
opts.numFreqs = 100;%ops.freqRange(end)-ops.freqRange(1);
opts.bltimvec = 10*501-1+250;

basepath = 'D:\Data\GroundTruth\';
pathJuxtaExtra.JuxtaPath = 'D:\Data\GroundTruth\juxta_cell_output\';
pathJuxtaExtra.ExtraPath = 'D:\Data\GroundTruth\juxta_cell_output\';

params.Probe0idx = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
params.Probeflip = flip(params.Probe0idx);
params.Probeflip(1) = []; % rm juxta
%%
%    pathInfo
for iSess = 6:length(sessions)
    
    
    pathInfo.JuxtaPath =  [pathJuxtaExtra.JuxtaPath sessions{iSess}];
    pathInfo.ExtraPath =  [pathJuxtaExtra.ExtraPath sessions{iSess}];
    pathInfo.RecPath =  [basepath sessions{iSess}];
    
    %%
    [highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes] = gt_LoadJuxtaCorrExtra(pathInfo,params);
    %
    [cco_timevector, cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra,lfp_juxta, opts);
%    [~,cco_indexvector] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra, ops);
    %
    [~, ~, normdata]=gt_calcSpectrograms(pathInfo,lfp_extra, cco_indexvector,opts);
    %
    gt_plotSpectrograms(opts,normdata)
end
