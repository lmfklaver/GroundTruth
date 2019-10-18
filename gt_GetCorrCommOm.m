function  [cco_timevector,cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra, ops)

% working on this: %if possible: split num matches, commissions and ommissions and time
% vectors from obtaining the lfp matrices

matches                 = 0;
omission_error_num      = 0;
commission_error_num    = 0;

rangeSpkBin         = ops.rangeSpkBin; %binsize for extra occurring before or after juxta (% rangeSpike is the allowed delay in the extracellular recording)
timWinWavespec      = ops.timWinWavespec; %ms
%%
%Loop through each Juxta Timestamp
cco_timevector.match  = [];
cco_timevector.om     = [];

for iSpikeJuxta = 1:length(JuxtaSpikesTimes) %4
    
    %   Loop through spikes of the best correlated Extracellular neuron
    matchCount = 0;
    selectedJuxtaSpike = JuxtaSpikesTimes(iSpikeJuxta);
    
    for iSpikeExtra = 1:length({highestChannelCorr})
        selectedExtraSpike = ExtraSpikesTimes{highestChannelCorr}(iSpikeExtra);
        
        % Find Matches (Juxta V, Extra V) Extracellular lfp timestamp centered on Juxtaspike
        
        if selectedExtraSpike >= selectedJuxtaSpike-rangeSpkBin && selectedExtraSpike <= selectedJuxtaSpike+rangeSpkBin
            % Find closest number in lfp to spike time, because of downsampling, by finding the minimum of the absolute difference 
            % (resulting in a number very close to zero for the  matching spike, which gives you an index to compare it to)
            
            [~,indexInJuxtaTimestamps] = min(abs(lfp_extra.timestamps-selectedJuxtaSpike)); %% CHANGED THIS TO SELJUXTASPK iso selectedExtraSpike
            %idxinjuxtats?
            max_idx = length(lfp_extra.timestamps) - timWinWavespec;
            %lastInclSpikeTimeEx = selectedExtraSpike - timWinWavespec; %figure out later ^
            
            %Extract lfp timestamps and data around juxta spike that has an extracellular match
            if indexInJuxtaTimestamps <= max_idx
                matches     = matches + 1;
                matchCount  = matchCount + 1; % to skip looking for extracellular when a match is found
                
                cco_timevector.match(1, matches)    = selectedJuxtaSpike;
                cco_indexvector.match(1, matches)   = indexInJuxtaTimestamps;
            end
        end
    end
    
    % Find Omission errors (Juxta V, Extra X) - Extracellular lfp timestamp centered around juxta
    
    if matchCount == 0
        selected_omission_pt = selectedJuxtaSpike; % spiketime (s) of selected juxta spike
        
        [~,indexInJuxtaTimestamps_Om] = min(abs(lfp_extra.timestamps-selected_omission_pt)); % corresponding index of juxta spike in LFP trace
        % selected_omission_pt = MaxRangeSpike
        % get the index of the selected ommission point on the juxtatimestamps
        
        % ommission_idx = find(lfp_juxta.timestamps == selected_omission_pt)
        max_idx_pt = length(lfp_extra.timestamps) - timWinWavespec; % because you cannot take the lfp beyond your last timestamp (it doesn't exist)
        
        if indexInJuxtaTimestamps_Om < max_idx_pt
            omission_error_num = omission_error_num + 1;

            cco_timevector.om(1, omission_error_num)    = selected_omission_pt;
            cco_indexvector.om(1, omission_error_num)   = indexInJuxtaTimestamps_Om; 
           
        end
    end
end

%%
% Loop through each Extracellular timestamp

matchesForSanity        = 0;
cco_timevector.com      = [];

for iExtraspike = 1:length(ExtraSpikesTimes{highestChannelCorr})
    match_count = 0;
    selectedExtraSpike = ExtraSpikesTimes{highestChannelCorr}(iExtraspike);
    
    for iJuxtaspike = 1:length(JuxtaSpikesTimes)
        selectedJuxtaSpike = JuxtaSpikesTimes(iJuxtaspike);
        
        if selectedExtraSpike >= selectedJuxtaSpike - rangeSpkBin && selectedExtraSpike <= selectedJuxtaSpike + rangeSpkBin
            %used juxta this time: matches should still be same as when using extra-- this is a troubleshooting check/backup
            [~,indexInJuxtaTimestamps_2] = min(abs(lfp_extra.timestamps-selectedJuxtaSpike));
            max_range_idx = length(lfp_extra.timestamps) - timWinWavespec;
            
            if indexInJuxtaTimestamps_2 <= max_range_idx
                matchesForSanity = matchesForSanity + 1;
                match_count = match_count + 1;
            end
        end
    end
    
    % Collecting commission errors(Extra V Juxta X)
    
    if match_count == 0   %if extra does not appear on juxta
        
        selected_commission_pt = selectedExtraSpike;
        [~,indexInExtraTimestamps_Com] = min(abs(lfp_extra.timestamps-selected_commission_pt));
        
        max_idx_com = length(lfp_extra.timestamps) - 250;
        %             lastInclSpikeTimeExOnly = selectedExtraSpike - timWinWavespec;
        
        if indexInExtraTimestamps_Com < max_idx_com
            commission_error_num = commission_error_num + 1;
            cco_timevector.com(1, commission_error_num) = selected_commission_pt;
            cco_indexvector.com(1, commission_error_num) = indexInExtraTimestamps_Com;
        end
    end
end

num_CorrComOm.matches = matches;
num_CorrComOm.omission = omission_error_num;
num_CorrComOm.commission = commission_error_num;

fprintf('Done calculating cco_timevector and cco_indexvector\n')

disp(['# Matches is ' num2str(matches)])
disp(['# Matches for Sanity is ' num2str(matchesForSanity)])
disp(['# Omissions is ' num2str(omission_error_num)])
disp(['# Commissions is ' num2str(commission_error_num)])
