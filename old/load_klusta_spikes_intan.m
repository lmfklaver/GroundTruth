function [spike] = load_klusta_spikes_intan(sessionID)


% This function is meant to load spikes clustered in klusta
%
% Dependencies:
%   get_spikes_from_kwik.m
%   get_waveforms_from_kwik.m
%
% Updated by:
%   07-2019 Copied from load_klusta_spikes 



fileName    =   [sessionID '.kwik'];
samples     =   hdf5read(fileName, '/channel_groups/0/spikes/time_samples');
clusters    =   hdf5read(fileName, '/channel_groups/0/spikes/clusters/main');
sampleRate  = double(h5readatt(fileName, '/recordings/0', 'sample_rate'));
FirstTimeStamp = double(h5readatt(fileName, '/recordings/0', 'start_time'));
% Load in the clusters, in microsec
maxClus = max(clusters);
neuronCount = 1;

for iClus = 1:maxClus
    
    if isempty(find(clusters == iClus))
        continue
    else
        spike.cluster_group{neuronCount} = hdf5read(fileName, ['/channel_groups/0/clusters/main/' num2str(iClus)], 'cluster_group');
        if spike.cluster_group{neuronCount} == 0 % Noise cluster_group
            continue
        elseif isempty(spike.cluster_group{neuronCount})
            continue
        else
            [spike.timestamp{neuronCount}, spike.samples{neuronCount}, spike.indiv_waves{neuronCount}, spike.waveforms{neuronCount}, spike.channel{neuronCount}] = get_spikes_from_kwik_intan(fileName,iClus,sampleRate);
            spike.timestamp{neuronCount} = spike.timestamp{neuronCount} ;% milliseconds %.*10^3 gives you .timestamp in seconds .*10^3? %because 1000 timestamps per second from computer
            spike.timestamp{neuronCount} = spike.timestamp{neuronCount} + double(FirstTimeStamp); % to match them with events etc
            spike.label{neuronCount} = [sessionID '_U' num2str(iClus)] ;
        end
        neuronCount = neuronCount + 1;
    end
    
    % Convert Units for Hybrid fieldtrip way
    
%     for iUnit = 1:length(spike.timestamp)
%         for iTs = 1:length(spike.timestamp{iUnit})
%             spike.unit{iUnit}(iTs) = iUnit;
%         end
%     end
end
end
