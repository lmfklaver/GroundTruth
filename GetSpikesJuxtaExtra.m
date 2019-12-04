function [spikesJCEC, JuxtaSpikesTimes, ExtraSpikesTimes] = GetSpikesJuxtaExtra(pathInfo,params,opts)
%%%%%% WORK IN PROGRESS,LOADING IN JAMES' SPIKSE %%%%%%%%
% Better to only overwrite times + cluID? 
%Hard code for mouse 15
[JuxtaSpikes, JCind] = LoadJuxtaSpikes(pathInfo,params,opts);
[ExtraSpikes, ECind] = LoadExtraSpikes(pathInfo,params,opts);

cd(pathInfo.RecPath)

%%   
% % %%%%%% BELOW IS ORIGINAL CODE %%%%%%%

% % %Define JuxtaSpikes with buzcode function get spikes
% % JuxtaSpikes         = bz_GetSpikes;
% % JuxtaCorr           = find(JuxtaSpikes.shankID == 2);
JuxtaSpikesTimes    = JuxtaSpikes.times{JCind};
% % %JuxtaSpikesTimes       = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);
% %
% % %Define extra spikes with buz code function
% % cd(pathInfo.ExtraPath);
% % ExtraSpikes         = bz_GetSpikes;
% % ExtraCorr           = find(ExtraSpikes.shankID == 1);
 ExtraSpikesTimes    = ExtraSpikes.times(ECind);

% ExtraSpikesTimes =round(ExtraSpikesTemp{ExtraCorr}.times,30000, 24);
%% Make 1 struct of JC and EC

spikesJCEC.sampleRate   = opts.SampFreq;
%spikesJCEC.UID          = ExtraSpikes.UID(ECind);
spikesJCEC.times        = ExtraSpikes.times(ECind);
spikesJCEC.shankID      = ExtraSpikes.shankID(ECind);
spikesJCEC.cluID        = ExtraSpikes.cluID(ECind);
%spikesJCEC.rawWaveform  = ExtraSpikes.rawWaveform(ECind);
spikesJCEC.maxWaveformCh = ExtraSpikes.maxWaveformCh(ECind);
%spikesJCEC.region       = ExtraSpikes.region(ECind);
%spikesJCEC.sessionName  = ExtraSpikes.sessionName;
%spikesJCEC.numcells     = ExtraSpikes.numcells;
%spikesJCEC.spindices    = ExtraSpikes.spindices;
 
%spikesJCEC.UID(end+1)           = JuxtaSpikes.UID(JCind);
spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);

spikesJCEC.shankID(end+1)       = JuxtaSpikes.shankID(JCind);
spikesJCEC.cluID(end+1)         = JuxtaSpikes.cluID(JCind);
%spikesJCEC.rawWaveform(end+1)   = JuxtaSpikes.rawWaveform;
spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);
%spikesJCEC.region(end+1)        = JuxtaSpikes.region(JCind);
end
