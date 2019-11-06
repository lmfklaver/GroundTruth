function [EMG_move_num_CorrComOm, EMG_rest_num_CorrComOm] = gt_EMG_CorrComOm(EMG_info,juxtaSpikes)
%Dependencies
%   gt_LFP_hfArtifacts -- relies on juxta sorter
%   GetJuxtaSpikes -- some juxta spike function
%   GetExtraSpikes -- some extra spike function
%   
%Code Start Date: October 11 2019
%
%% Define options
ops.rangeSpkBin = .001; %binsize for extra occurring before or after juxta
ops.timWinWavespec = 250; %ms
ops.doSave = 0;
ops.freqRange = [1 500];
ops.numFreqs = 100;%ops.freqRange(end)-ops.freqRange(1);
ops.bltimvec = 10*501-1+250;
%% Juxta Sorter Spikes
%Use juxta sorter to get juxta spikes

%% Get EMG movement timestamps and rest timestamps
% [EMG_info] = gt_LFP_hfArtifacts(juxtaSpikes)

%% Highest Correlation channel
% pathInfo.excelPath = fullfile(['D:\ReaganB\R_Bullins\Excel_Info_Docs\', excelDoc]); % %read the excel doc into a struct
% 
% recordingsGT    = table2struct(readtable(pathInfo.excelPath));
% iRec            = idxInExcelDoc;
% RecordingNum    = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)];
% Cell            = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session) '_cell' num2str(recordingsGT(iRec).cell)];
% BZ              = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session) '_bz'];

pathInfo.JuxtaPath = 'D:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
pathInfo.ExtraPath = 'D:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
pathInfo.Recpath = 'D:\Data\GroundTruth\m15_190315_152315';


[JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr,  lfp_juxta, lfp_extra] = gt_LoadJuxtaCorrExtra(pathInfo);
  

%% Get Correlations, Commissions, and Omissions with no muscle movement (rest)
   % THOUGHT for future: EMG gives correlations, so there are 2 less
   % datapoints than on the LFP (may not matter)
   
   %Create Vectors for start times and stop times
   rest_start = []; % rest = Non-EMG activity, EMGcorr<threshold - now set at .8
   rest_stop = [];
   start_idx = 0;
   stop_idx = 0;
   sanity = 0;
   
   %Go through each rest timestamp -- will be comparing each timestamp to
   %before and after timestamps to see how long each rest interval is
   for rest_idx = 1:(length(EMG_info.rest_timestamps)-1) %FIGURE out how to account for last timestamp
       % Define current timestamp index   
          rest_time = EMG_info.rest_timestamps(rest_idx);
       % Define comparison after timestamp 
          comp_idx_after = rest_idx + 1;
          comparison_time_after = EMG_info.rest_timestamps(comp_idx_after);
       % Define Interval between current and after timestamps
          comp_interval_after = round((comparison_time_after - rest_time),4); %rounding difference to 4 decimals
      
      % Account for 1st timestamp
      if (rest_idx == 1) && (comp_interval_after == .0008)
          rest_start(1) = EMG_info.rest_timestamps(1);
      end

      % Account for rest of timestamps
      if (rest_idx > 1) && (rest_idx < length(EMG_info.rest_timestamps)) %staying within bounds
         % Define comparison before timestamp
              comp_idx_before = rest_idx - 1;
              comparison_time_before = EMG_info.rest_timestamps(comp_idx_before);
         % Define Interval between current and before timestamps
              comp_interval_before = round((rest_time - comparison_time_before),4);
         % Define Start timestamps (begginning of rest period)     
              if (comp_interval_after == .0008) && (comp_interval_before ~= .0008) %before it was changing and after is not, this is a start time
                  start_idx = start_idx + 1;
                  rest_start(start_idx) = EMG_info.rest_timestamps(rest_idx);
              end
         % Define Stop timestamps (end of rest period)
              if (comp_interval_before == .0008) && (comp_interval_after ~= .0008)
                  stop_idx = stop_idx + 1;
                  rest_stop(stop_idx) = EMG_info.rest_timestamps(rest_idx);
              end
      end
      sanity = sanity + 1
       
   end
   % Check length of start and stop time vectos
      length_start = length(rest_start)
      length_stop = length(rest_stop)
      if length_start ~= length_stop
          disp('Start and Stop Time vectors are different lengths')  
      end
      
      
  %Combine Start and Stop time vectors into a matrix
      rest_start_stop = [rest_start(:), rest_stop(:)];
   
      %[rest_start;rest_stop] gives you the bounds in which the
      %match/comm/om timestamp can be
  
 %% Get CorrCommOm of timestamp vectors 
 [cco_timevector,cco_indexvector, num_Corr_ComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra, ops);
    
%% Get matches, commission, and omission errors for rest time periods
 [pt_CorrComOm] = gt_CorrComOm_BiologicalVariable (rest_start_stop, cco_timevector.match, cco_timevector.om, cco_timevector.com)






