function [spikesJCEC, JuxtaSpikesTimes, ExtraSpikesTimes] = GetSpikesJuxtaExtra(pathInfo,params)


%%%%%% WORK IN PROGRESS,LOADING IN JAMES' SPIKSE %%%%%%%%
% Better to only overwrite times + cluID? 
%Hard code for mouse 15

cd(pathInfo.JuxtaPath);

juxtafile = readmda('firings_true.mda');

[j_maxWaveformCh, j_times, j_cluID] = deal(juxtafile(1,:), juxtafile(2,:), juxtafile(3,:));
for iClu = 1:max(j_cluID)
    JuxtaSpikes.times{iClu} = j_times(j_cluID == iClu)';
    JuxtaSpikes.times{iClu} = JuxtaSpikes.times{iClu}/30000; % if this becomes an array, how to divide every element in array?
    %JuxtaSpikes.maxWaveformCh{iClu} = j_maxWaveformCh(j_cluID == iClu);
end
    JuxtaSpikes.shankID = repmat(2,1,max(j_cluID));
     %(1:numel(JuxtaSpikes.times))
    JuxtaSpikes.cluID = 1:max(j_cluID);
    JuxtaSpikes.cluID = JuxtaSpikes.cluID + 1;
    JuxtaSpikes.sampleRate = 30000;
    JuxtaSpikes.region = {'HPC'};
    %Change WITH JAMES
    JChanID = 1;
    JuxtaSpikes.maxWaveformCh = repmat(JChanID,1,max(j_cluID));
    
cd(pathInfo.ExtraPath);

extrafile = readmda('firings.mda');

[e_maxWaveformCh ,e_times, e_cluID] = deal(extrafile(1,:),extrafile(2,:), extrafile(3,:));
for iClu = 1:max(e_cluID)
    ExtraSpikes.times{iClu} = e_times(e_cluID == iClu)';
    ExtraSpikes.times{iClu} = ExtraSpikes.times{iClu}/30000;
    %ExtraSpikes.maxWaveformCh{iClu} = e_maxWaveformCh(e_cluID == iClu);
end
    ExtraSpikes.shankID = repmat(1,1,max(e_cluID));
    ExtraSpikes.cluID = 1:max(e_cluID)
    ExtraSpikes.cluID = ExtraSpikes.cluID + 1;
    ExtraSpikes.sampleRate  = 30000;
    ExtraSpikes.region = {'HPC'};
    
    S_score1 = load('raw_geom_score.mat');
    % set the ground truth unit index
iGt1 = 1;

% Find the peak channel (which has the most negative peak)
iChan_max = S_score1.viSite_gt(iGt1); 

   EChanID = params.Probeflip(iChan_max);
    ExtraSpikes.maxWaveformCh = repmat(EChanID,1,max(e_cluID)); 
    
    
% % %%%%%% BELOW IS ORIGINAL CODE %%%%%%%
% % 
% % pathInfo.JuxtaPath =
% 'D:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
% % pathInfo.ExtraPath =
% 'D:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
% % %Define JuxtaSpikes with buzcode function get spikes
% % JuxtaSpikes         = bz_GetSpikes;
% % JuxtaCorr           = find(JuxtaSpikes.shankID == 2);
JuxtaSpikesTimes    = JuxtaSpikes.times{1};
% % %JuxtaSpikesTimes       = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);
% %
% % %Define extra spikes with buz code function
% % cd(pathInfo.ExtraPath);
% % ExtraSpikes         = bz_GetSpikes;
% % ExtraCorr           = find(ExtraSpikes.shankID == 1);
 ExtraSpikesTimes    = ExtraSpikes.times;

% ExtraSpikesTimes =round(ExtraSpikesTemp{ExtraCorr}.times,30000, 24);
%  %%%%%% FOR TESTING %%%%%%%
% JuxtaPath = 'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
% ExtraPath = 'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
%  %Define JuxtaSpikes with buzcode function get spikes
% cd(JuxtaPath)
% JuxtaSpikesComp         = bz_GetSpikes('noPrompts' , true);
% JuxtaCorrComp          = find(JuxtaSpikesComp.shankID == 2);
% JuxtaSpikesTimesComp    = JuxtaSpikesComp.times{JuxtaCorrComp};
% 
% %JuxtaSpikesTimes       = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);
% 
% %Define extra spikes with buz code function
% cd(ExtraPath);
% ExtraSpikesComp         = bz_GetSpikes('noPrompts' , true);
% ExtraCorrComp           = find(ExtraSpikesComp.shankID == 1);
% ExtraSpikesTimesComp    = ExtraSpikesComp.times{ExtraCorrComp};

%% Make 1 struct of JC and EC


spikesJCEC.sampleRate   = 30000;
%spikesJCEC.UID          = ExtraSpikes.UID(ECind);
spikesJCEC.times        = ExtraSpikes.times;
spikesJCEC.shankID      = ExtraSpikes.shankID;
spikesJCEC.cluID        = ExtraSpikes.cluID;
%spikesJCEC.rawWaveform  = ExtraSpikes.rawWaveform(ECind);
spikesJCEC.maxWaveformCh = ExtraSpikes.maxWaveformCh;
%spikesJCEC.region       = ExtraSpikes.region(ECind);
%spikesJCEC.sessionName  = ExtraSpikes.sessionName;
%spikesJCEC.numcells     = ExtraSpikes.numcells;
%spikesJCEC.spindices    = ExtraSpikes.spindices;


%spikesJCEC.UID(end+1)           = JuxtaSpikes.UID(JCind);
spikesJCEC.times(end+1)         = JuxtaSpikes.times;
spikesJCEC.shankID(end+1)       = JuxtaSpikes.shankID;
spikesJCEC.cluID(end+1)         = JuxtaSpikes.cluID;
%spikesJCEC.rawWaveform(end+1)   = JuxtaSpikes.rawWaveform;
 spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh;
%spikesJCEC.region(end+1)        = JuxtaSpikes.region(JCind);
end
