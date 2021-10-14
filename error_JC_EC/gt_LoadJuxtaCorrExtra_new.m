function [highestChannelCorr,  lfp_juxta, lfp_extra, bestCluster,spikesJCEC] = gt_LoadJuxtaCorrExtra_new(basepath) 
%% Load in General Info on LFP & define some variables

% [spikesJCEC] = GetSpikesJuxtaExtra_new(basepath);
% or sorter thing
% Calculate correlation over spikeTimes
% See if you can specify that it should only calculate correlations with
% Juxta? Now over whole matrix
basepath = cd;
basename = bz_BasenameFromBasepath(basepath);

if ~isempty(dir('*.jSpkTimes*'))
   a = dir('*.jSpkTimes*');
   if length(a) == 1
       load(a.name)
   else 
       return
   end
   load([basename '.juxtaSpikes.mat']);
    juxtaSpikes.times = {jSpkTimes};
    juxtaSpikes.ts = {jSpkTimes/30000};
else
    load([basename '.juxtaSpikes.mat']);
end


spikesEC_KS2            = bz_LoadPhy('kilosort_path','ks2');
% spikesEC_Klusta        

%select which one
spikesEC = spikesEC_KS2;

spikesJCEC = struct;
spikesJCEC.times        = spikesEC.times;
spikesJCEC.times(end+1) = juxtaSpikes.times;

% [spikesJCEC]
[ccg,~] = CCG(spikesJCEC.times',[],'norm','counts'); 

% JuxtaChan = length(spikesJCEC.shankID); % Last dimension needs to be the JuxtaChannel for this to work.
checkCorrs = squeeze(ccg(:,:,end));
checkCorrs = checkCorrs(:,1:end-1); % to exclude juxtachan;
maxCC = max(max(checkCorrs)); % gives you EC cluster with highest correlation to JC
[~,c] = find(checkCorrs == maxCC);

% by looking at all the times (101) of the ccg matrix for all different clusters, you can get the counts for the other EC correlation occurences out
highestChannelCorr = spikesEC.maxWaveformCh(c); % channel on which waveform is highest
bestCluster = c;

cd(basepath)


%% Separate this from this code
lfp_juxta = bz_GetLFP(0); % recorded juxta channel
lfp_extra = bz_GetLFP(highestChannelCorr); % matching extracellular channel



disp('done')