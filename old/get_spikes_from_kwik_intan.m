function [spikeTime, spikeSamples, spikeWaves, meanWave, channelLabel] = get_spikes_from_kwik_intan(fileName,cluster, sampleRate)
%% get_spikes_from_kwik: return spike timestamps array of kwik file

% Return the spike timestamps in the kwikfile specified by fileName input
% argument and the cluster (ie cell/unit) (use 'all' instead of cluster nr
% to return all spiketimes.) Returns spike timestamps in
% seconds in an array.

fileNameKWX = [fileName(1:end-4) 'kwx'];

time_samples = hdf5read(fileName, '/channel_groups/0/spikes/time_samples');
featuresMasks = hdf5read(fileNameKWX, '/channel_groups/0/features_masks');
belongsToCluster = hdf5read(fileName, '/channel_groups/0/spikes/clusters/main');



if ischar(cluster) && strcmp(cluster,'all')
    spikeSamples = time_samples;
    spikeFeaturesMasks = featuresMasks;
    
else
    spikeSamples = time_samples(belongsToCluster == cluster);
    features = squeeze(featuresMasks(1,:,:)); %
    singleSpikeFeature = features(1:3:end,:);
    selFeatures = singleSpikeFeature(:, belongsToCluster == cluster);
    meanFeatures = mean(selFeatures, 2);
    
    channelNumbers = 1:length(meanFeatures)';
    
    spikeChannel = channelNumbers(find(abs(meanFeatures)==max(abs(meanFeatures)),1));
    channelLabel = num2str(spikeChannel);
    
    try
        spikeWaves = get_waveforms_from_kwik_intan(fileName, spikeSamples, spikeChannel, length(meanFeatures), sampleRate);
        meanWave = (nanmean(spikeWaves,3));
    catch ME
        spikeWaves = NaN;
        meanWave = NaN;
    end
    
    
%     if str2num(fileName(end-5)) == 2
%         channelNumbers = channelNumbers + length(meanFeatures);
%     elseif str2num(fileName(end-5)) == 3
%         channelNumbers = channelNumbers + length(meanFeatures)*2;
%     elseif str2num(fileName(end-5)) == 4
%         channelNumbers = channelNumbers + length(meanFeatures)*3;
%     end
%     
%     spikeChannel = channelNumbers(find(abs(meanFeatures)==max(abs(meanFeatures)),1));
%     channelLabel = num2str(spikeChannel);
  
end

spikeTime = double(spikeSamples)/sampleRate;
spikeTime = spikeTime'; % Return a horizontal vector








%singleSpikeDepth = sum(channelNumbers.*spikeFeatures)/sum(spikeFeatures);



end
