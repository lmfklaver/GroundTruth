function [highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes] = gt_LoadJuxtaCorrExtra(pathInfo,params) 
%% Load in General Info on LFP & define some variables

[spikesJCEC, JuxtaSpikesTimes, ExtraSpikesTimes] = GetSpikesJuxtaExtra(pathInfo,params);
% Calculate correlation over spikeTimes
% See if you can specify that it should only calculate correlations with
% Juxta? Now over whole matrix

[ccg,~] = CCG(spikesJCEC.times',[],'norm','counts'); 

JuxtaChan = length(spikesJCEC.shankID); % Last dimension needs to be the JuxtaChannel for this to work.
checkCorrs = squeeze(ccg(:,:,JuxtaChan));
maxCC = max(max(checkCorrs)); % gives you EC cluster with highest correlation to JC
[~,c] = find(checkCorrs == maxCC);

% by looking at all the times (101) of the ccg matrix for all different clusters, you can get the counts for the other EC correlation occurences out
highestChannelCorr = spikesJCEC.maxWaveformCh(c); % channel on which waveform is highest

%cd(pathInfo.Recpath)
cd(pathInfo.RecPath)

lfp_juxta = bz_GetLFP(0); % recorded juxta channel
lfp_extra = bz_GetLFP(highestChannelCorr); % matching extracellular channel

disp('done')