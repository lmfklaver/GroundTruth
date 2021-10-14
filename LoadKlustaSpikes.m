function [spikes] = LoadKlustaSpikes(basepath,varargin)

%%building a .kwik to spikes-struct-compatible-with-buzcode
%% LoadKlustaSpikes: return spike timestamps array of kwik file

% Returns a spikes struct buzcode compatible, with timestamps in the kwikfile specified by basename input
% argument and the cluster (ie cell/unit) 

% to add :
% - spindices?
% - region
% - shankID
% - filtWaveform


%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);


p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'samplingRate',30000,@isnumeric);
addParameter(p,'saveAs','.spikesKlusta.mat',@isstr);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
Fs              = p.Results.samplingRate;
saveAs          = [basename p.Results.saveAs];


cd(basepath)
%%
spikes.sesssionPath      = basepath;
spikes.sessionName      = basename;
spikes.Fs               = Fs;

basenameKWX     = [basename '.kwx'];
basenameKWIK    = [basename '.kwik'];

%softcode channel groups (shanks)
%for iShank = 1:length(something)

shankID = 0;
time_samples        = hdf5read(basenameKWIK, ['/channel_groups/' num2str(shankID) '/spikes/time_samples']);
featuresMasks       = hdf5read(basenameKWX, ['/channel_groups/' num2str(shankID) '/features_masks']);
belongsToCluster    = hdf5read(basenameKWIK, ['/channel_groups/' num2str(shankID) '/spikes/clusters/main']);

%%
%     allFeatures % unsure what this was for again 
features            = squeeze(featuresMasks(1,:,:)); %
singleSpikeFeature  = features(1:3:end,:);


clusterIDs   = unique(belongsToCluster); % NB cluster 0 is noise, cluster 1 is MUA in Kwik.
cluCount    = 0;

% else
for iClus = 1:length(clusterIDs)
    if clusterIDs(iClus) ==0 || clusterIDs(iClus) ==1 %noise or MUA in Kwik
        continue
    end
    
    cluCount = cluCount +1;
    
    spikeSamples = time_samples(belongsToCluster == clusterIDs(iClus));
    %spikeFeaturesMasks = featuresMasks(belongsToCluster == cluster);
    %masks = squeeze(spikeFeaturesMasks(2,1:3:end,:)); %
    selFeatures     = singleSpikeFeature(:, belongsToCluster == clusterIDs(iClus));
    meanFeatures    = mean(selFeatures, 2);
    
    channelNumbers  = 1:length(meanFeatures)';
    
    
    spikeChannel = channelNumbers(find(abs(meanFeatures)==max(abs(meanFeatures)),1));
    channelLabel = num2str(spikeChannel);
    
    
    try
        spikeWaves = get_waveforms_from_kwik(basename, spikeSamples, spikeChannel, length(meanFeatures));
        
        meanWave = (nanmean(spikeWaves,3));
    catch ME
        spikeWaves = NaN;
        meanWave = NaN;
    end
        
    spikeChannel = channelNumbers(find(abs(meanFeatures)==max(abs(meanFeatures)),1));
    channelLabel = num2str(spikeChannel);
    
    
    spikeTime = double(spikeSamples)/Fs;
    spikeTime = spikeTime'; % Return a horizontal vector
    
    % write to spikes struct
   
    spikes.UID(cluCount)                = clusterIDs(iClus);% 1xlength double
    spikes.ts{cluCount}                 = spikeSamples;% {1xlength cell}
    spikes.times{cluCount}              = spikeTime;% {1xlength cell}
%     spikes.shankID(cluCount)          = ;% 1xlength double
    spikes.rawWaveform{cluCount}        = mean(squeeze(spikeWaves)');% {1xlength cell}
    spikes.allWaveforms{cluCount}       = squeeze(spikeWaves);
%     spikes.filtWaveform{cluCount}     = ;%{1xlength cell}
    spikes.maxWaveformCh(cluCount)      = spikeChannel;%1xlength double % check if this is 0 or 1 based
    spikes.numcells                     = length(spikes.UID);
    % spikes.region{cluCount}           = ; %{1xlength cell}
    % spikes.spindices    = % no idea
    
end

if saveMat
   fklusta = [basename saveAs];
    
    if exist(fklusta,'file')
        overwrite = input([basename, saveAs ' already exists. Overwrite? [Y/N] '],'s');
        switch overwrite
            case {'y','Y'}
                delete(fklusta)
            case {'n','N'}
                return
            otherwise
                error('Y or N please...')
        end
    end
    
    save([basename saveAs],'spikes')
end
end

function [waveforms] = get_waveforms_from_kwik(basename, spikeSamples, spikeChannel, nChans)

% Get Waveforms KlustaKwik
%
nRawChans = nChans;
nChansInDatFile = nChans;

DatFile = [basename '.dat'];


tBefore = 20; %samples after?
tAfter = 44; % samples before?


MyTimes = spikeSamples;% timestamps in samples, not in seconds
MyTimes = double(MyTimes);

FileInfo = dir(DatFile);

nSpikes = length(spikeSamples);
nTimeSamplesPerWaveform = tBefore + tAfter +1;


Source = memmapfile(DatFile, 'Format', {'int16', [nRawChans, (FileInfo.bytes/nChansInDatFile/2)], 'x'});

waveforms = zeros(1, nTimeSamplesPerWaveform, nSpikes);


for i=1:nSpikes
    try
        %waveforms(:,:,i) = Source.Data.x(1:nChansInDatFile,MyTimes(i)-tBefore:MyTimes(i)+tAfter);
        waveforms(1,:,i) = Source.Data.x(spikeChannel,MyTimes(i)-tBefore:MyTimes(i)+tAfter);
    catch ME
        fprintf(ME)
    end
end
end

