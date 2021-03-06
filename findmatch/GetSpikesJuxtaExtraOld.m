function [spikesJCEC, JuxtaSpikesTimes, ExtraSpikesTimes] = GetSpikesJuxtaExtraOld(basepath)

JCshank = 10;

JuxtaPath = basepath;%'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
ExtraPath = fullfile(basepath,'kilosort2\');%'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';

basename = bz_BasenameFromBasepath(basepath);

%Define JuxtaSpikes with buzcode function get spikes
cd(JuxtaPath)
%JuxtaSpikes         = bz_GetSpikes('noPrompts' , true);

load([basename '.juxtaSpikes.mat'])
JuxtaSpikes         = juxtaSpikes;
JuxtaCorr          = JuxtaSpikes.shankID == JCshank;
JuxtaSpikesTimes    = JuxtaSpikes.times{JuxtaCorr};

%JuxtaSpikesTimes       = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);

%Define extra spikes with buz code function
cd(ExtraPath);
%ExtraSpikes         = bz_GetSpikes('noPrompts' , true);
ExtraSpikes         = bz_LoadPhy;
ExtraCorr           = ExtraSpikes.shankID == 1;
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
% spikesJCEC.region = ExtraSpikes.region(ECind);
spikesJCEC.sessionName = ExtraSpikes.sessionName;
spikesJCEC.numcells = ExtraSpikes.numcells;
spikesJCEC.spindices = ExtraSpikes.spindices;

JCind = JuxtaSpikes.shankID == JCshank;
spikesJCEC.UID(end+1) = JuxtaSpikes.UID(JCind);
spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);
spikesJCEC.shankID(end+1) = JuxtaSpikes.shankID(JCind);

if isfield(JuxtaSpikes,'cluID')
    spikesJCEC.cluID(end+1) = JuxtaSpikes.cluID(JCind);
else
    spikesJCEC.cluID(end+1) = JuxtaSpikes.UID(JCind);
end

spikesJCEC.rawWaveform(end+1) = JuxtaSpikes.rawWaveform(JCind);

if isfield(JuxtaSpikes,'maxWaveformCh')
    
spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);

else
    spikesJCEC.maxWaveformCh(end+1) = 0;
end

% spikesJCEC.region(end+1) = JuxtaSpikes.region(JCind);

end
