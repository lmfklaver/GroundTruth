function [spikesJCEC, JuxtaSpikesTimes, ExtraSpikesTimes] = GetSpikesJuxtaExtra_new(basepath)
%%%%%% WORK IN PROGRESS,LOADING IN JAMES' SPIKSE %%%%%%%%
% Better to only overwrite times + cluID? 
%Hard code for mouse 15
% [JuxtaSpikes, JCind] = LoadJuxtaSpikes(pathInfo,params,opts); commented
% out - Erik 6_7_21


cd(basepath);
basename = bz_BasenameFromBasepath(basepath);

sessionInfo = bz_getSessionInfo(basepath);

%load juxta
load(fullfile(basepath,[basename,'.juxtaSpikes.mat']))
  
%load extra
% sorter dependent
load(fullfile(basepath,'ks2',[basename '_EC.spikes.cellinfo.mat']) )

cd(basepath)

%%   
JuxtaSpikesTimes    = juxtaSpikes.times{1};
ExtraSpikesTimes    = spikes.times; %provided this only has EC

%% Make 1 struct of JC and EC

spikesJCEC.sampleRate       = sessionInfo.rates.wideband;
spikesJCEC.times            = spikes.times;
spikesJCEC.shankID          = spikes.shankID;
% spikesJCEC.cluID            = spikes.cluID;
spikesJCEC.maxWaveformCh    = spikes.maxWaveformCh;

spikesJCEC.times(end+1)         = juxtaSpikes.times(1);
spikesJCEC.shankID(end+1)       = juxtaSpikes.shankID;
spikesJCEC.maxWaveformCh(end+1) = juxtaSpikes.maxWaveFormCh;

end
