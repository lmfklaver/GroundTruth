% Lianne's adaptation of Reagan's script

% addpaths
addpath(genpath('C:\Users\lklaver\Documents\GitHub\buzcode'))
addpath(genpath('E:\Dropbox\Code\GroundTruth\'))

% fix this:
excelDoc  = 'GT_cells.xlsx';
idxInExcelDoc = 9;

%    pathInfo
pathInfo.excelPath       = fullfile(['E:\ReaganB\R_Bullins\Excel_Info_Docs\', excelDoc]); % %read the excel doc into a struct

recordingsGT    = table2struct(readtable(pathInfo.excelPath));
iRec            = idxInExcelDoc;
RecordingNum    = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)];
Cell            = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session) '_cell' num2str(recordingsGT(iRec).cell)];
BZ              = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session) '_bz'];

% Go into kilosort folder for juxtacellular data
pathInfo.JuxtaPath = fullfile(['E:\ReaganB\GT_Recorded_Cells\' RecordingNum '\' Cell '\' BZ '\' recordingsGT(iRec).kiloJuxta]);
pathInfo.ExtraPath = fullfile(['E:\ReaganB\GT_Recorded_Cells\' RecordingNum '\' Cell '\' BZ '\' recordingsGT(iRec).kiloExtra]);
pathInfo.Recpath    = fullfile(['E:\ReaganB\GT_Recorded_Cells\' RecordingNum '\' Cell '\' BZ]);

pathInfo.JuxtaPath = 'E:\ReaganB\GT_Recorded_Cells\Dan Hippo Cell\1_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
pathInfo.ExtraPath = 'E:\ReaganB\GT_Recorded_Cells\Dan Hippo Cell\1_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
pathInfo.Recpath = 'E:\ReaganB\GT_Recorded_Cells\Dan Hippo Cell\1_190315_152315';

%   Options
ops.rangeSpkBin = .001; %binsize for extra occurring before or after juxta
ops.timWinWavespec = 250; %ms
ops.doSave = 0;
ops.freqRange = [1 500];
ops.numFreqs = 100;%ops.freqRange(end)-ops.freqRange(1);
ops.bltimvec = 10*501-1+250;
%%
[JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr,  lfp_juxta, lfp_extra] = gt_LoadJuxtaCorrExtra(pathInfo);
%
[~,cco_indexvector] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra, ops);
%
[~, ~, normdata]=gt_calcSpectrograms(pathInfo,lfp_extra, cco_indexvector,ops);
%
gt_plotSpectrograms(ops,normdata)