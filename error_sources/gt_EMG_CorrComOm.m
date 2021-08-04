function [rest_start_stop] = gt_EMG_CorrComOm(EMG_info,params)
%Dependencies
%   gt_LFP_hfArtifacts -- relies on juxta sorter
%   GetJuxtaSpikes -- some juxta spike function
%   GetExtraSpikes -- some extra spike function
%   
%Code Start Date: October 11 2019
%Lianne adaptations Oct 16 (made this functions to only get the values we
%want out.
%% Get Juxta Spikes (outside this function)
%% Get EMG movement timestamps and rest timestamps (outside this function)
%% Highest Correlation channel(outside this function)
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
      %sanity = sanity + 1
       
   end
   % Check length of start and stop time vectos
      length_start = length(rest_start);
      length_stop = length(rest_stop);
      if length_start ~= length_stop
          disp('Start and Stop Time vectors are different lengths')  
      end
      
      
  %Combine Start and Stop time vectors into a matrix
      rest_start_stop = [rest_start(:), rest_stop(:)];
   
      %[rest_start;rest_stop] gives you the bounds in which the
      %match/comm/om timestamp can be
  
 %% Get CorrCommOm of timestamp vectors 
% outside of this function    
%% Get matches, commission, and omission errors for rest time periods
% outside of this function




end
