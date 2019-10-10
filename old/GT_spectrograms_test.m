function GT_spectrograms_test(numberMouse, excelDoc)
%% Load in General Info on LFP & define some variables

%find the excel doc
excelPath = fullfile(['C:\Users\Englishlab\Documents\R_Neur\', excelDoc]);
%read the excel doc into a struct
recordingsGT = table2struct(readtable(excelPath));
iRec = numberMouse;
RecordingNum = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)];
Cell = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)]; % add '_cell' num2str(recordingsGT(iRec).cell)

%Go into recording folder
RecPath = fullfile(['C:\Data\' RecordingNum '\' Cell]);
cd(RecPath);

%Go into kilosort folder for juxtacellular data
JuxtaPath = fullfile(['C:\Data\' RecordingNum '\' Cell '\' recordingsGT(iRec).kiloJuxta]);
cd(JuxtaPath);
%Define JuxtaSpikes with buzcode function get spikes
JuxtaSpikes = bz_GetSpikes;
JuxtaCorr = find(JuxtaSpikes.shankID == 2);
JuxtaSpikesTimes = JuxtaSpikes.times{JuxtaCorr};

%JuxtaSpikesTimes = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);

%Go back to main recording folder
cd(RecPath);
%Go into kilosort folder for extracellular data
ExtraPath = fullfile(['C:\Data\' RecordingNum '\' Cell '\' recordingsGT(iRec).kiloExtra]);
cd(ExtraPath);
%Define extra spikes with buz code function
ExtraSpikes = bz_GetSpikes;
ExtraCorr = find(ExtraSpikes.shankID == 1);
ExtraSpikesTimes = ExtraSpikes.times{ExtraCorr};

%ExtraSpikesTimes =round(ExtraSpikesTemp{ExtraCorr}.times,30000, 24);

%Go back to main recording folder
cd(RecPath);


%% Get highest correlating neuron
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
%spikesJCEC.sampleRate = 30000;
spikesJCEC.UID(end+1) = JuxtaSpikes.UID(JCind);
spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);
spikesJCEC.shankID(end+1) = JuxtaSpikes.shankID(JCind);
spikesJCEC.cluID(end+1) = JuxtaSpikes.cluID(JCind);
spikesJCEC.rawWaveform(end+1) = JuxtaSpikes.rawWaveform(JCind);
spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);
spikesJCEC.region(end+1) = JuxtaSpikes.region(JCind);

[ccg,~] = CCG(spikesJCEC.times,[],'norm','counts');

%checkCorrs = squeeze(ccg(:,:,[highestClusterCorr]));

NeuronNum = length(spikesJCEC.shankID);

checkCorrs = squeeze(ccg(:,:,NeuronNum));

maxCC = max(max(checkCorrs)); % gives you EC cluster with highest correlation to JC
[~,c] = find(checkCorrs ==maxCC);

% by looking at all the times (101) of the ccg matrix for all different clusters, you can get the counts for the other EC correlation occurences out

highestClusterCorr = spikesJCEC.cluID(c); % clusterID in neuroscope of indexed column
highestChannelCorr = spikesJCEC.maxWaveformCh(c); % channel on which waveform is highest

timesMatch = spikesJCEC.times{highestClusterCorr};



%% Find highest correlation neuron, doing by eye

%load in lfp file for the extracellular channel that correlates the most,
%given in input
lfp_juxta = bz_GetLFP(0);
lfp_extra = bz_GetLFP([highestChannelCorr]);


%% For loop for threshold and 250 +- makes 501X(x columns)
%This will use the timestamps of the juxtcelllar as the center to base the
%timestamps for the extracellular on
matches = 0;
omission_error_num = 0;
commission_error_num = 0;

%Loop through each Juxta Timestamp
for ithreshold_idx = 1:length(JuxtaSpikesTimes)
    %Loop through spikes of the best correlated neuron
    matchCount = 0;
    selectedJuxtaSpike = JuxtaSpikesTimes(ithreshold_idx);
    for ispikeExtra = 1:length(ExtraSpikes.times{[highestChannelCorr]})
        selectedExtraSpike = ExtraSpikes.times{[highestChannelCorr]}(ispikeExtra);
        
        %collecting correlated values % match centered on Juxta
        %rangeSpike allows for a millisecond of delay in the extracellular
        %recording
        
        
        MaxRangeSpike = selectedJuxtaSpike + .001;
        
        if selectedExtraSpike <= MaxRangeSpike && selectedExtraSpike >= selectedJuxtaSpike
            matches = matches + 1;
            selected_point = JuxtaSpikesTimes(ithreshold_idx); % uses value for each peak then pulls values -250:250 samples around each peak
            
            [difference,indexInExtraTimestamps] = min(abs(lfp_extra.timestamps-selected_point));
            
            max_idx = length(lfp_extra.timestamps) - 250;
            
            if indexInExtraTimestamps < max_idx
                extra_spike_dur(:,ithreshold_idx) = lfp_extra.timestamps(indexInExtraTimestamps-250:indexInExtraTimestamps+250); % for timestamps part of structure
                extra_spike_Datadur(:,ithreshold_idx) = lfp_extra.data(indexInExtraTimestamps-250:indexInExtraTimestamps+250); % for data part of structur
                matchCount = matchCount + 1;
            end
        end
        
        
    end
    
    %collecting omission errors (spiking on juxta but not
    %extracellular)
    % JUST Extra lfp
    % Centered around juxta
    % LK: Wavespec needs to be on extracellular trace
    
    if matchCount == 0 %if juxta does not appear on the extra
        omission_error_num = omission_error_num + 1;
        selected_omission_pt = selectedJuxtaSpike;
        
        [difference_Om,indexInJuxtaTimestamps] = min(abs(lfp_juxta.timestamps-selected_omission_pt));
        %selected_omission_pt = MaxRangeSpike
        %get the index of the selected ommission point on the
        %juxtatimestamps
        %ommission_idx = find(lfp_juxta.timestamps == selected_omission_pt)
        max_idx_pt = length(lfp_juxta.timestamps) - 250;
        
        if indexInJuxtaTimestamps < max_idx_pt
            omission_dur(:,ithreshold_idx) = lfp_juxta.timestamps(indexInJuxtaTimestamps-250:indexInJuxtaTimestamps+250);
            omission_Datadur(:,ithreshold_idx) = lfp_extra.data(indexInJuxtaTimestamps-250:indexInJuxtaTimestamps+250);
        end
    end
end
'done'

%% Getting the spikes that are only on the extracellular
for iExtraspike = 1:length(ExtraSpikes.times{highestChannelCorr})
    match_count = 0;
    for iJuxtaspike = 1:length(JuxtaSpikesTimes)
        selectedExtraspike = ExtraSpikes.times{highestChannelCorr}(iExtraspike);
        selectedJuxtaspike = JuxtaSpikesTimes(iJuxtaspike);
        
        
        MaxRangeSpike = selectedJuxtaSpike + .001;
        
        if selectedExtraSpike <= MaxRangeSpike && selectedExtraSpike >= selectedJuxtaSpike
            match_count = count + 1;
        end
    end
    %collecting commission errors(spiking on extra but not juxta)
    %JUST Extra lfp, centered on extra spike
    
    if match_count == 0   %if extra does not appear on juxta
        commission_error_num = commission_error_num + 1;
        selected_commission_pt = selectedExtraspike;
        
        [difference_com,indexInExtraTimestamps_Com] = min(abs(lfp_extra.timestamps-selected_commission_pt));
        
        max_idx_com = length(lfp_extra.timestamps) - 250;
        
        if indexInExtraTimestamps_Com < max_idx_com
            
            commission_dur(:,iJuxtaspike) = lfp_extra.timestamps(indexInExtraTimestamps_Com-250:indexInExtraTimestamps_Com+250);
            commission_Datadur(:,iJuxtaspike) = lfp_extra.data(indexInExtraTimestamps_Com-250:indexInExtraTimestamps_Com+250);
        end
    end
    
end
'done'

%% Replace .data and .timestamps of channel lfp
%make copies of big files so can manipulate them seperately
%cd(RecPath);
lfp_extra_error = lfp_extra;
lfp_juxta_error = lfp_juxta;

lfp_extra.timestamps = extra_spike_dur;
lfp_extra.data = extra_spike_Datadur; % extra channel

lfp_extra_error.timestamps = commission_dur;
lfp_extra_error.data = commission_Datadur; % extra channel

lfp_juxta_error.timestamps = omission_dur;
lfp_juxta_error.data = omission_Datadur; % extra channel

'done'
%% Loop wavespec over the columns(spikes) for each cell

% to run through each event set and run wavespec on it(assuming each collumn is a time stamp and each row is one of 501 time/data stamps)
eventcols = matches;

% lfp_extra.timestamps = lfp_extra.timestamps( :, ~any(~lfp_extra.timestamps,1) );
% lfp_extra.data = lfp_extra.data( :, ~any(~lfp_extra.data,1));
% sanity = 0;
for iEvents = 1:length(lfp_extra.timestamps)
    %     sanity = sanity +1
    lfp_extra_temp = lfp_extra;
    lfp_extra_temp.data = lfp_extra.data(:,iEvents);
    lfp_extra_temp.timestamps = lfp_extra.timestamps(:,iEvents);
    wavespec_event_temp = bz_WaveSpec(lfp_extra_temp,'frange',[1 150],'nfreqs',149);
    wavespec_event_temp.data = abs(wavespec_event_temp.data);
    wavespec_tot_spikes(iEvents) = wavespec_event_temp; % change to be an input of animal
end
'done 1'
%Run for omission error

% includes all events, but sets undesired ones to 0 %might change to speed
% up
for iEvents = 1:length(lfp_juxta_error.timestamps)
    lfp_juxta_temp_omission = lfp_juxta_error;
    lfp_juxta_temp_omission.data = lfp_juxta_error.data(:,iEvents);
    lfp_juxta_temp_omission.timestamps = lfp_juxta_error.timestamps(:,iEvents);
    wavespec_omission_temp = bz_WaveSpec(lfp_juxta_temp_omission,'frange',[1 150],'nfreqs',149);
    wavespec_omission_temp.data = abs(wavespec_omission_temp.data);
    wavespec_tot_spikes_omission(iEvents) = wavespec_omission_temp;
end
'done 2'
%Run for commission error
for iEvents = 1:length(lfp_extra_error.timestamps)
    lfp_extra_temp_commission = lfp_extra_error;
    lfp_extra_temp_commission.data = lfp_extra_error.data(:,iEvents);
    lfp_extra_temp_commission.timestamps = lfp_extra_error.timestamps(:,iEvents);
    wavespec_commission_temp = bz_WaveSpec(lfp_extra_temp_commission,'frange',[1 150],'nfreqs',149);
    wavespec_commission_temp.data = abs(wavespec_commission_temp.data);
    wavespec_tot_spikes_commission(iEvents) = wavespec_commission_temp; % change to be an input of animal
end

'done final'
%% concatenating in the 3rd dimension and then averaging in the 3rd dimension
%matches
wavespec_avg_tot_spikes = mean(cat(3,wavespec_tot_spikes.data),3);
%omission error
wavespec_avg_tot_omission = mean(cat(3,wavespec_tot_spikes_omission.data),3);
%commission error
wavespec_avg_tot_commission = mean(cat(3,wavespec_tot_spikes_commission.data),3);

%% Plotting Higly Correlated Graph
hold on
figure('Name','Highly Correlated Extracellular to Juxtacellular Spikes')

% help gca

subplot(1,3,1)
imagesc(wavespec_avg_tot_spikes')
title('Highly Correlated Extracellular to Juxtacellular Spikes')
xlabel('Time(ms)')
ylabel('Frequency(Hz)')
% caxis([0 700])
set(gca, 'YDir', 'normal') % Flips figure on y-axis to go from low-high frequency bottom-top respectively
set(gca, 'YTick', [1 51 81 100 130 150 200 230]) % Sets the indices along the y-axis that you want to label (indices corespond to the 'nfreqs' input to wavespec)
set(gca, 'YTickLabel', {0 50 100 150 200 250 300 350}) % changes the labels of the selected indices in 'YTick' above
set(gca, 'XTick', [1 125 251 376 501])
set(gca, 'XTickLabel', {-200 -100 0 100 200})
box 'off';
set(gca, 'TickDir', 'out');
colorbar
hold off
%% Plotting Omission Error
hold on
% figure('Name','Omission Error Between Extracellular and Juxtacellular Spikes')

% help gca

subplot(1,3,2)
imagesc(wavespec_avg_tot_omission')
title('Omission Error Between Extracellular and Juxtacellular Spikes')
xlabel('Time(ms)')
ylabel('Frequency(Hz)')
% caxis([0 700])
set(gca, 'YDir', 'normal') % Flips figure on y-axis to go from low-high frequency bottom-top respectively
set(gca, 'YTick', [1 51 81 100 130 150 200 230]) % Sets the indices along the y-axis that you want to label (indices corespond to the 'nfreqs' input to wavespec)
set(gca, 'YTickLabel', {0 50 100 150 200 250 300 350}) % changes the labels of the selected indices in 'YTick' above
set(gca, 'XTick', [1 125 251 376 501])
set(gca, 'XTickLabel', {-200 -100 0 100 200})
box 'off';
set(gca, 'TickDir', 'out');
colorbar
hold off
%% Plotting Commission Error
hold on
% figure('Name','Commission Error Between Extracellular and Juxtacellular Spikes')

% help gca

subplot(1,3,3)
imagesc(wavespec_avg_tot_commission')
title('Commission Error Between Extracellular and Juxtacellular Spikes')
xlabel('Time(ms)')
ylabel('Frequency(Hz)')
% caxis([0 500])
set(gca, 'YDir', 'normal') % Flips figure on y-axis to go from low-high frequency bottom-top respectively
set(gca, 'YTick', [1 51 81 100 130 150 200 230]) % Sets the indices along the y-axis that you want to label (indices corespond to the 'nfreqs' input to wavespec)
set(gca, 'YTickLabel', {0 50 100 150 200 250 300 350}) % changes the labels of the selected indices in 'YTick' above
set(gca, 'XTick', [1 125 251 376 501])
set(gca, 'XTickLabel', {-200 -100 0 100 200})
box 'off';
set(gca, 'TickDir', 'out');
colorbar
hold off
end

% Unable to perform assignment because the size of the left side is 1-by-1 and the size of the
% right side is 1-by-13111.
%
% Error in bz_WaveSpec (line 157)
%         tspec(:,f_i) = FConv(wavelet',data(:,cidx));
%
% Error in GT_spectrograms_test (line 183)
%     wavespec_event_temp = bz_WaveSpec(lfp_extra_temp,'frange',[70 300],'nfreqs',230);
%
% Your MATLAB session has timed out.  All license keys have been returned.


% Out of memory. Type HELP MEMORY for your options.



