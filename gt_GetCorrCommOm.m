function  [cco_timevector, cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra,lfp_juxta, opts, sessions, iSess)

% working on this: %if possible: split num matches, commissions and ommissions and time
% vectors from obtaining the lfp matrices

matches                 = 0;
omission_error_num      = 0;
commission_error_num    = 0;

rangeSpkBin             = opts.rangeSpkBin; %binsize for extra occurring before or after juxta (% rangeSpike is the allowed delay in the extracellular recording)
timWinWavespec          = opts.timWinWavespec; %ms
%%
cco_timevector.matches  = [];
cco_timevector.om       = [];

cco_indexvector.matches = [];
cco_indexvector.om      = [];

%Loop through each Juxta Timestamp
for iSpikeJuxta = 1:length(JuxtaSpikesTimes) %4
    %   Loop through spikes of the best correlated neuron
    matchCount = 0;
    selectedJuxtaSpike = JuxtaSpikesTimes(iSpikeJuxta);
    
    for iSpikeExtra = 1:length(ExtraSpikesTimes{highestChannelCorr}) %8599
        selectedExtraSpike = ExtraSpikesTimes{highestChannelCorr}(iSpikeExtra);
        
        %collecting correlated values % match centered on Juxta
        %rangeSpike allows for a millisecond of delay in the extracellular
        %recording
        
        if selectedExtraSpike >= selectedJuxtaSpike-rangeSpkBin && selectedExtraSpike <= selectedJuxtaSpike+rangeSpkBin
            
            %difference (resulting in a number very close to zero for the  matching spike, which gives you an index to compare it to)
            [~,closestExtraLFPIdx] = min(abs(lfp_extra.timestamps-selectedExtraSpike)); 
    
            max_idx = length(lfp_extra.timestamps) - timWinWavespec;
            %lastInclSpikeTimeEx = selectedExtraSpike - timWinWavespec; %
            %figure out later ^
            
            %Extract lfptimestamps and data around juxta spike that has an
            %extracellular match
            if closestExtraLFPIdx <= max_idx
               
                matchCount = matchCount + 1;
                matches = matches + 1;
                cco_timevector.matches(1, matches)    = selectedJuxtaSpike;
                cco_indexvector.matches(1, matches)   = closestExtraLFPIdx;
                
            end
            % break % break terminates for loop
        end
        
    end
   
    %collecting omission errors (spiking on juxta but not extracellular)
    % JUST Extracellular lfp Centered around juxta
    
    if matchCount == 0
        selected_omission_pt = selectedJuxtaSpike;
       
       [~,closestJuxtaLFPIdx] = min(abs(lfp_juxta.timestamps-selected_omission_pt)); 
        
        max_idx_pt = length(lfp_juxta.timestamps) - timWinWavespec; % because you cannot take the lfp beyond your last timestamp (it doesn't exist)
%       
               
        if  closestJuxtaLFPIdx < max_idx_pt 
             
            omission_error_num = omission_error_num + 1;
        
             cco_timevector.om(1, omission_error_num)    = selected_omission_pt;
             cco_indexvector.om(1,  omission_error_num)  =  closestJuxtaLFPIdx;
        end
    end
end


   %print out number of matches
     matches
     omission_error_num
     
fprintf('done\n')
%%
% Getting the spikes that are only on the extracellular
matchesForSanity = 0;

cco_timevector.com      = [];
cco_indexvector.com     = [];

for iExtraSpike = 1:length(ExtraSpikesTimes{highestChannelCorr})
    match_count = 0;
    selectedExtraSpike = ExtraSpikesTimes{highestChannelCorr}(iExtraSpike);
    
    for iJuxtaspike = 1:length(JuxtaSpikesTimes)
        selectedJuxtaSpike = JuxtaSpikesTimes(iJuxtaspike);
       
        if selectedExtraSpike >= selectedJuxtaSpike - rangeSpkBin && selectedExtraSpike <= selectedJuxtaSpike + rangeSpkBin
             %used juxta this time: matches should still be same as when using
             %extra-- this is a troubleshooting check/backup
            [~,closestJuxta2LFPIdx] = min(abs(lfp_juxta.timestamps-selectedJuxtaSpike)); 
            
             max_range_idx = length(lfp_extra.timestamps) - timWinWavespec;
            
            if closestJuxta2LFPIdx <= max_range_idx
                matchesForSanity = matchesForSanity + 1;
                match_count = match_count + 1;
            end
            
        end
    end
    
    %     %collecting commission errors(spiking on extra but not juxta)
    %     %JUST Extra lfp, centered on extra spike
    if match_count == 0   %if extra does not appear on juxta
       
        selected_commission_pt = selectedExtraSpike;
        [~,closestExtra_Com] = min(abs(lfp_extra.timestamps-selected_commission_pt));
        
        max_idx_com = length(lfp_extra.timestamps) - 250;
        %             lastInclSpikeTimeExOnly = selectedExtraSpike - timWinWavespec;
        
        if closestExtra_Com < max_idx_com
           
            commission_error_num = commission_error_num + 1;
         
            cco_timevector.com(1, commission_error_num) = selected_commission_pt;
            cco_indexvector.com(1, commission_error_num) = closestExtra_Com;
          
        end
    end
end

fprintf('done\n')
%%

matches, matchesForSanity, omission_error_num, 
commission_error_num

num_CorrComOm.matches = matches;
num_CorrComOm.omission = omission_error_num;
num_CorrComOm.commission = commission_error_num;

fprintf('Done calculating cco_timevector and cco_indexvector\n')

disp(['Session ' sessions{iSess} ': Matches = ' num2str(matches)])
disp(['Session ' sessions{iSess} ': Matches for Sanity = ' num2str(matchesForSanity)])
disp(['Session ' sessions{iSess} ': Omissions = ' num2str(omission_error_num)])
disp(['Session ' sessions{iSess} ': Commissions = ' num2str(commission_error_num)])
