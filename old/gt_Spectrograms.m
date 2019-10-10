function [spikesJCEC, lfp_juxta, lfp_extra, lfp_juxta_error, lfp_extra_error, extra_spike_Datadur, omission_Datadur, commission_Datadur, matches, omission_error_num, commission_error_num, wavespec_avg_tot_spikes,wavespec_avg_tot_omission, wavespec_avg_tot_commission] = gt_Spectrograms(mainPath, RecPath, ExtraPath, JuxtaPath)
%% Load in General Info on LFP & define some variables
%
%    %find the excel doc
% excelPath = fullfile(['C:\Users\Englishlab\Documents\R_Neur\', excelDoc]);
% %read the excel doc into a struct
% recordingsGT = table2struct(readtable(excelPath));
%     iRec = numberMouse;
%     RecordingNum = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)];
%     Cell = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)]; % add '_cell' num2str(recordingsGT(iRec).cell)
%
%     %Go into recording folder
%    RecPath = fullfile(['C:\Data\' RecordingNum '\' Cell]);
cd(RecPath);

%Go into kilosort folder for juxtacellular data
%     JuxtaPath = fullfile(['C:\Data\' RecordingNum '\' Cell '\' recordingsGT(iRec).kiloJuxta]);
cd(JuxtaPath);

%Define JuxtaSpikes with buzcode function get spikes
JuxtaSpikes = bz_GetSpikes;
JuxtaCorr = find(JuxtaSpikes.shankID == 2);
JuxtaSpikesTimes = JuxtaSpikes.times{JuxtaCorr};

%JuxtaSpikesTimes = resample(JuxtaSpikes.times(1, JuxtaCorr),30000,24);

%Go back to main recording folder
%     cd(RecPath);
%Go into kilosort folder for extracellular data
%     ExtraPath = fullfile(['C:\Data\' RecordingNum '\' Cell '\' recordingsGT(iRec).kiloExtra]);
cd(ExtraPath);
%Define extra spikes with buz code function
ExtraSpikes = bz_GetSpikes;
ExtraCorr = find(ExtraSpikes.shankID == 1);
ExtraSpikesTimes = ExtraSpikes.times(ExtraCorr);

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
spikesJCEC.UID(end+1) = JuxtaSpikes.UID(JCind);
spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);
spikesJCEC.shankID(end+1) = JuxtaSpikes.shankID(JCind);
spikesJCEC.cluID(end+1) = JuxtaSpikes.cluID(JCind);
spikesJCEC.rawWaveform(end+1) = JuxtaSpikes.rawWaveform(JCind);
spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);
spikesJCEC.region(end+1) = JuxtaSpikes.region(JCind);

[ccg,~] = CCG(spikesJCEC.times,[],'norm','counts');

JuxtaChan = length(spikesJCEC.shankID); % Last dimension needs to be the JuxtaChannel for this to work.
checkCorrs = squeeze(ccg(:,:,JuxtaChan));

maxCC = max(max(checkCorrs)); % gives you EC cluster with highest correlation to JC
[~,c] = find(checkCorrs == maxCC);

% by looking at all the times (101) of the ccg matrix for all different clusters, you can get the counts for the other EC correlation occurences out
highestClusterCorr = spikesJCEC.cluID(c); % clusterID in neuroscope of indexed column
highestChannelCorr = spikesJCEC.maxWaveformCh(c); % channel on which waveform is highest

% timesMatch = spikesJCEC.times{highestClusterCorr};

%% Find highest correlation neuron, doing by eye

%load in lfp file for the extracellular channel that correlates the most,
%given in input

lfp_juxta = bz_GetLFP(0); % recorded juxta channel
lfp_extra = bz_GetLFP(highestChannelCorr); % matching extracellular channel


%% For loop for threshold and 250 +- makes 501X(x columns)
%This will use the timestamps of the juxtacellular as the center to base the
%timestamps for the extracellular one

matches = 0;
omission_error_num = 0;
commission_error_num = 0;

rangeSpkBin = .001; %binsize for extra occurring before or after juxta
timWinWavespec = 250; %ms
%%
%Loop through each Juxta Timestamp
for iSpikeJuxta = 1:length(JuxtaSpikesTimes) %4
    %   Loop through spikes of the best correlated neuron
    matchCount = 0;
    selectedJuxtaSpike = JuxtaSpikesTimes(iSpikeJuxta);
    
    for iSpikeExtra = 1:length(ExtraSpikes.times{highestChannelCorr}) %8599
        selectedExtraSpike = ExtraSpikes.times{highestChannelCorr}(iSpikeExtra);
        
        %collecting correlated values % match centered on Juxta
        %rangeSpike allows for a millisecond of delay in the extracellular
        %recording
        
        if selectedExtraSpike >= selectedJuxtaSpike-rangeSpkBin && selectedExtraSpike <= selectedJuxtaSpike+rangeSpkBin
            matches = matches + 1;
            matchCount = matchCount + 1;
            [~,indexInExtraTimestamps] = min(abs(lfp_extra.timestamps-selectedExtraSpike)); %find closest number in lfp to spike time, because of
            %downsampling, by finding the minimum of the absolute
            %difference (resulting in a number very close to zero for the  matching spike, which gives you an index to compare it to)
            
             max_idx = length(lfp_extra.timestamps) - timWinWavespec;
            %lastInclSpikeTimeEx = selectedExtraSpike - timWinWavespec; %
            %figure out later ^
            
            %Extract lfptimestamps and data around juxta spike that has an
            %extracellular match
            if indexInExtraTimestamps <= max_idx
                extra_spike_dur(:,iSpikeJuxta) = lfp_extra.timestamps(indexInExtraTimestamps-timWinWavespec:indexInExtraTimestamps+timWinWavespec); % for timestamps part of structure
                extra_spike_Datadur(:,iSpikeJuxta) = lfp_extra.data(indexInExtraTimestamps-timWinWavespec:indexInExtraTimestamps+timWinWavespec); % for data part of structure
            end
            break
        end
    end
    %collecting omission errors (spiking on juxta but not extracellular)
    % JUST Extracellular lfp Centered around juxta
    
    if matchCount == 0
        omission_error_num = omission_error_num + 1;
        selected_omission_pt = selectedJuxtaSpike;
        
        [~,indexInJuxtaTimestamps] = min(abs(lfp_juxta.timestamps-selected_omission_pt));
        %selected_omission_pt = MaxRangeSpike
        %get the index of the selected ommission point on the
        %juxtatimestamps
        %ommission_idx = find(lfp_juxta.timestamps == selected_omission_pt)
        max_idx_pt = length(lfp_juxta.timestamps) - timWinWavespec; % because you cannot take the lfp beyond your last timestamp (it doesn't exist)
%         lastInclSpikeTimeJux = selectedJuxtaSpike - timWinWavespec;
               
        if indexInJuxtaTimestamps < max_idx_pt
            omission_dur(:,iSpikeJuxta) = lfp_juxta.timestamps(indexInJuxtaTimestamps-timWinWavespec:indexInJuxtaTimestamps+timWinWavespec);
            omission_Datadur(:,iSpikeJuxta) = lfp_extra.data(indexInJuxtaTimestamps-timWinWavespec:indexInJuxtaTimestamps+timWinWavespec);
        end
    end
end

fprintf('done\n')
%%
% Getting the spikes that are only on the extracellular
for iExtraspike = 1:length(ExtraSpikes.times{highestChannelCorr})
    match_count = 0;
    for iJuxtaspike = 1:length(JuxtaSpikesTimes)
        selectedExtraSpike = ExtraSpikes.times{highestChannelCorr}(iExtraspike);
        selectedJuxtaSpike = JuxtaSpikesTimes(iJuxtaspike);
        
        % MaxRangeSpike = selectedJuxtaSpike + rangeSpkBin;
        
        if selectedExtraSpike >= selectedJuxtaSpike - rangeSpkBin && selectedExtraSpike <= selectedJuxtaSpike + rangeSpkBin
            match_count = match_count + 1;
            
        end
    end
    
    %     %collecting commission errors(spiking on extra but not juxta)
    %     %JUST Extra lfp, centered on extra spike
    if match_count == 0   %if extra does not appear on juxta
        commission_error_num = commission_error_num + 1;
        selected_commission_pt = selectedExtraSpike;
        
        [~,indexInExtraTimestamps_Com] = min(abs(lfp_extra.timestamps-selected_commission_pt));
        
        max_idx_com = length(lfp_extra.timestamps) - 250;
        %             lastInclSpikeTimeExOnly = selectedExtraSpike - timWinWavespec;
        
        if indexInExtraTimestamps_Com < max_idx_com
            commission_dur(:,iJuxtaspike) = lfp_extra.timestamps(indexInExtraTimestamps_Com-250:indexInExtraTimestamps_Com+250);
            commission_Datadur(:,iJuxtaspike) = lfp_extra.data(indexInExtraTimestamps_Com-250:indexInExtraTimestamps_Com+250);
        end
    end
end

%     % collecting commission errors(spiking on extra but not juxta)
%     % JUST Extra lfp, centered on extra spike
%
%     if match_count == 0   %if extra does not appear on juxta
%         commission_error_num = commission_error_num + 1;
%         selected_commission_pt = selectedExtraSpike;
%
%         [~,indexInExtraTimestamps_Com] = min(abs(lfp_extra.timestamps-selected_commission_pt));
%
%         max_idx_com = length(lfp_extra.timestamps) - 250;
%
%         if indexInExtraTimestamps_Com < max_idx_com
%
%             commission_dur(:,iJuxtaspike) = lfp_extra.timestamps(indexInExtraTimestamps_Com-250:indexInExtraTimestamps_Com+250);
%             commission_Datadur(:,iJuxtaspike) = lfp_extra.data(indexInExtraTimestamps_Com-250:indexInExtraTimestamps_Com+250);
%         end
%     end
%
% end
fprintf('done\n')

matches, omission_error_num, 
commission_error_num

%% Replace .data and .timestamps of channel lfp
%make copies of big files so can manipulate them seperately
%cd(RecPath);
lfp_extra.timestamps = extra_spike_dur;
lfp_extra.data = extra_spike_Datadur; % extra channel

lfp_extra_error = lfp_extra; % is now your lfp_extra with replaced timestamps 
lfp_juxta_error = lfp_juxta;

lfp_juxta_error.timestamps = omission_dur;
lfp_juxta_error.data = omission_Datadur; % extra channel

lfp_extra_error.timestamps = commission_dur;
lfp_extra_error.data = commission_Datadur; % extra channel

fprintf('done\n')
%% Loop wavespec over the columns(spikes) for each cell
freqRange= [1 300];
numFreqs = 60;%freqRange(end)-freqRange(1);
%%
% to run through each event set and run wavespec on it(assuming each collumn is a time stamp and each row is one of 501 time/data stamps)
[wavespec_tot_spikes] = getWavespecMatch(lfp_extra,freqRange, numFreqs);
save wavespec_tot_spikes wavespec_tot_spikes
[wavespec_tot_spikes_omission] = getWaveSpecOm(lfp_juxta_error,freqRange, numFreqs);
save wavespec_tot_spikes_omission wavespec_tot_spikes_omission
[wavespec_tot_spikes_commission] = getWaveSpecCom(lfp_extra_error,freqRange, numFreqs);
save wavespec_tot_spikes_commission wavespec_tot_spikes_commission
%% concatenating in the 3rd dimension and then averaging in the 3rd dimension
% numWavespecs = 10000; %select only 10000 matches for hpc 

%matches
wavespec_avg_tot_spikes = mean(cat(3,wavespec_tot_spikes.data),3);
%omission error
wavespec_avg_tot_omission = mean(cat(3,wavespec_tot_spikes_omission.data),3);
%commission error
wavespec_avg_tot_commission = mean(cat(3,wavespec_tot_spikes_commission.data),3);

end


function [wavespec_tot_spikes] = getWavespecMatch(lfp_extra,freqRange, numFreqs)
for iEvents = 1:length(lfp_extra.timestamps)
    %     sanity = sanity +1
    lfp_extra_temp = lfp_extra;
    lfp_extra_temp.data = lfp_extra.data(:,iEvents);
    lfp_extra_temp.timestamps = lfp_extra.timestamps(:,iEvents);
    wavespec_event_temp = bz_WaveSpec(lfp_extra_temp,'frange',freqRange,'nfreqs',numFreqs);
    wavespec_event_temp.data = abs(wavespec_event_temp.data);
    wavespec_tot_spikes(iEvents) = wavespec_event_temp; % change to be an input of animal
end
fprintf('done 1\n')
end
%Run for omission error

% includes all events, but sets undesired ones to 0 %might change to speed
% up
function [wavespec_tot_spikes_omission] = getWaveSpecOm(lfp_juxta_error, freqRange, numFreqs)
for iEvents = 1:length(lfp_juxta_error.timestamps)
    lfp_juxta_temp_omission = lfp_juxta_error;
    lfp_juxta_temp_omission.data = lfp_juxta_error.data(:,iEvents);
    lfp_juxta_temp_omission.timestamps = lfp_juxta_error.timestamps(:,iEvents);
    wavespec_omission_temp = bz_WaveSpec(lfp_juxta_temp_omission,'frange',freqRange,'nfreqs',numFreqs);
    wavespec_omission_temp.data = abs(wavespec_omission_temp.data);
    wavespec_tot_spikes_omission(iEvents) = wavespec_omission_temp;
end
fprintf('done 2\n')
end

function [wavespec_tot_spikes_commission] = getWaveSpecCom(lfp_extra_error, freqRange, numFreqs)
%Run for commission error
for iEvents = 1:length(lfp_extra_error.timestamps)
    lfp_extra_temp_commission = lfp_extra_error;
    lfp_extra_temp_commission.data = lfp_extra_error.data(:,iEvents);
    lfp_extra_temp_commission.timestamps = lfp_extra_error.timestamps(:,iEvents);
    wavespec_commission_temp = bz_WaveSpec(lfp_extra_temp_commission,'frange',freqRange,'nfreqs',numFreqs);
    wavespec_commission_temp.data = abs(wavespec_commission_temp.data);
    wavespec_tot_spikes_commission(iEvents) = wavespec_commission_temp; % change to be an input of animal
end

fprintf('done final\n')
end
