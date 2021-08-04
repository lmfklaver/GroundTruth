function [spikesJCEC, JuxtaSpikesTimes, ExtraSpikesTimes] = GetSpikesJuxtaExtraOld(pathInfo,params)



JuxtaPath = pathInfo.JuxtaPath;%'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
ExtraPath = pathInfo.ExtraPath;%'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';


%Define JuxtaSpikes with buzcode function get spikes
cd(JuxtaPath)
%JuxtaSpikes         = bz_GetSpikes('noPrompts' , true);
JuxtaSpikes         = bz_GetSpikes;
JuxtaCorr          = find(JuxtaSpikes.shankID == 2);
JuxtaSpikesTimes    = JuxtaSpikes.times{JuxtaCorr};

%JuxtaSpikesTimes       = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);

%Define extra spikes with buz code function
cd(ExtraPath);
%ExtraSpikes         = bz_GetSpikes('noPrompts' , true);
ExtraSpikes         = bz_GetSpikes;
ExtraCorr           = find(ExtraSpikes.shankID == 1);
ExtraSpikesTimes    = ExtraSpikes.times(ExtraCorr);

%ExtraSpikesTimes =round(ExtraSpikesTemp{ExtraCorr}.times,30000, 24);


%% Make 1 struct of JC and EC
ECind = ExtraSpikes.shankID == 1;
spikesJCEC.sampleRate = 30000;
spikesJCEC.UID = ExtraSpikes.UID(ECind);
spikesJCEC.times = ExtraSpikes.times(ECind);
spikesJCEC.shankID = ExtraSpikes.shankID(ECind);
spikesJCEC.cluID = ExtraSpikes.cluID(ECind);

spikesJCEC.rawWaveform = ExtraSpikes.rawWaveform(ECind);
spikesJCEC.maxWaveformCh = ExtraSpikes.maxWaveformCh(ECind);
spikesJCEC.region = ExtraSpikes.region(ECind);
spikesJCEC.sessionName = ExtraSpikes.sessionName;
spikesJCEC.numcells = ExtraSpikes.numcells;
spikesJCEC.spindices = ExtraSpikes.spindices;

JCind = JuxtaSpikes.shankID == 2;
spikesJCEC.UID(end+1) = JuxtaSpikes.UID(JCind);
spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);
spikesJCEC.shankID(end+1) = JuxtaSpikes.shankID(JCind);
spikesJCEC.cluID(end+1) = JuxtaSpikes.cluID(JCind);
spikesJCEC.rawWaveform(end+1) = JuxtaSpikes.rawWaveform(JCind);
spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);
spikesJCEC.region(end+1) = JuxtaSpikes.region(JCind);

end
