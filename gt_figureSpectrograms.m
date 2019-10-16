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
ops.rangeSpkBin = .001; %binsize for extra occurring before or after juxta
ops.timWinWavespec = 250; %ms
ops.doSave = 0;
ops.freqRange = [1 500];
ops.numFreqs = 100;%ops.freqRange(end)-ops.freqRange(1);
ops.bltimvec = 10*501-1+250;

basepath = 'E:\Data\GroundTruth';
basepathJuxta = 'E:\Data\GroundTruth\juxta_cell_output';
basepathExtra = 'E:\Data\GroundTruth\juxta_cell_output';
%%
%    pathInfo
for iSess = 1%:length(sessions)
    
    
    pathInfo.JuxtaPath = [basepathJuxta sessions{iSess}];
    pathInfo.Extrapath =  [basepathExtra sessions{iSess}];
    pathInfo.Recpath =  [basepath sessions{iSess}];
    
    
    %%
    [JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr,  lfp_juxta, lfp_extra] = gt_LoadJuxtaCorrExtra(pathInfo);
    %
    [~,cco_indexvector] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra, ops);
    %
    [~, ~, normdata]=gt_calcSpectrograms(pathInfo,lfp_extra, cco_indexvector,ops);
    %
    gt_plotSpectrograms(ops,normdata)
end
