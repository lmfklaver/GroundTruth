%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                            %%%
%%% Hi Reagan, Let's make this script for the Biological Comm/Om/Match figure! %%%
%%% A script is basically the story with the collection of functions we
%%% need for something, like a figure!  
%%%                                                                            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
sessions = {'m15_190315_152315'};

%%
plotRasters = 0;

for iSess = 1%1:length(sessions)
    
    %KS1
    % Juxta and ExtraPath are now hardcoded: softcode this for future!!
    % (same in gt_LFP_hfArtifacts)
    
    pathInfo.JuxtaPath  = 'D:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC'; 
    pathInfo.ExtraPath  = 'D:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
    
    %pathInfo.JuxtaPath = 'E:\Data\GroundTruth\juxta_cell_output\m15_190315_152315_cell1';
    %pathInfo.ExtraPath = 'E:\Data\GroundTruth\juxta_cell_output\m15_190315_152315_cell1';
    
    pathInfo.RecPath    = ['D:\Data\GroundTruth\', sessions{iSess}];
    cd(pathInfo.RecPath);
    
    selecSession = sessions{iSess};
    datfileName = [sessions{iSess} '.dat'];

    
    disp(['Currently evaluating session:' sessions{iSess}])
   
   %Define specific session params
    sessionInfo = bz_getSessionInfo(cd);
      %sessionInfo.region = areas{iSess}
    params.nChans       = sessionInfo.nChannels;
    params.sampFreq     = sessionInfo.rates.wideband;
    %params.Probe0idx    = sessionInfo.channels; listed in startup code
   
    
    %% Get Juxta and or Extra spikes
    % gt_LoadJuxtaCorrExtraOld does the thing with Kilosort1 output (so with
    % the indexing in spikesJCEC correctly formatted
    
    % gt_LoadJuxtaCorrExtra is made for James data - try KS1 first
    %[highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes] = gt_LoadJuxtaCorrExtraOld(pathInfo,params);
    [highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes] = gt_LoadJuxtaCorrExtra(pathInfo,params) 

    % get matches, commissions , omissions
    [cco_timevector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra, lfp_juxta, opts);

     %% Get LFP data for sanity checks! I suggest checking them with raw data. 
    lfp         = bz_GetLFP('all','basename', selecSession); %
    %% Get Ripple Data
    % Find Ripples % ONLY HPC AND RSC Recordings
    chan    = bz_GetBestRippleChan(lfp);
    %ripples = bz_FindRipples(lfp.data(:,chan),lfp.timestamps,'thresholds',[2 5]);
    ripples = bz_FindRipples(lfp.data(:,chan),lfp.timestamps,'thresholds',[2 5],'restrict', [600 1000])
    % check the raw data (and plot the blocks? See gt_LFP_hfArtifacts.m)
    % if the ripple detection is not working well, play around with the
    % threshods per session (default = [2 5])
    
    % ripples.timestamps(1) and ripples.timestamps(2) are the start and
    % stop times of the ripples
    
       %% Get raw data for sanity checks! I suggest checking them with raw data. 
    rawdata     = bz_LoadBinary(datfileName,'frequency',params.sampFreq,'nChannels',33,'channels',chan);

    %% Calc EMG
    cd(pathInfo.RecPath)
    
    EMGFromLFP = bz_EMGFromLFP(cd,'overwrite',true,'rejectChannels', 0,'samplingFrequency', 1250,'noPrompts',true); % 0 is juxtachan
    smoothEMG    = movmean(EMGFromLFP.data,.25*1250); % 0.25 s sliding window, lfp-samprate is 1250
    
    %% Get timestamps of when there is movement
    
    EMG_info.idx_movement_datapoints    = find(smoothEMG > 0.8); % NB Arbitrarily set threshold, can change this
    EMG_info.idx_rest_datapoints        = find(smoothEMG <= 0.8); % NB Arbitrarily set threshold, can change this 
    EMG_info.movement_timestamps        = EMGFromLFP.timestamps(EMG_info.idx_movement_datapoints);
    EMG_info.rest_timestamps            = EMGFromLFP.timestamps(EMG_info.idx_rest_datapoints);
    
    [rest_start_stop]   = gt_EMG_StartStop(EMG_info,params);  % Used to be EMG_CorrCom-etc. split it up
    % check the raw data (and plot the blocks?) see gt_LFP_hfArtifacts.m
    
    %% Get matches, commission, and omission errors for rest time periods
    [pt_CorrComOm_EMG] = gt_CorrComOm_BiologicalVariable (rest_start_stop, cco_timevector.match, cco_timevector.om, cco_timevector.com);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% !!!! gt_CorrComOm_BiologicalVariable flips start and stop?
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Sanity check :)
    figure
    plot(EMGFromLFP.timestamps, smoothEMG, '.r');
    %hold on
    %plot(lfp.timestamps,rawdata)
    
    %% Same thing for Ripples -- TO IMPLEMENT
    
    [pt_CorrComOm_rip] = gt_CorrComOm_BiologicalVariable (ripples.timestamps, cco_timevector.match, cco_timevector.om, cco_timevector.com);

end

