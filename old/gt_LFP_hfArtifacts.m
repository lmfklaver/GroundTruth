% Dependencies
%   JuxtaSorter() ... gives juxta spikes

%%
%For Future -- if had folder of only cut cells wanting to look at...
% sessions_extended = dir('D:\Data\GroundTruth\');
% sessions = {sessions_extended.name};


sessions = {'m14_190326_155432',...
    'm14_190326_160710_cell1',...
    'm15_190315_142052_cell1',...
    'm15_190315_145422',...
    'm15_190315_150831_cell1',...
    'm15_190315_152315_cell1',...
    'm52_190731_145204_cell3'};

areas = {'hpc','hpc','cx','hpc','hpc','hpc','th'};
%%

for iSess = 6%[1,6]%:length(sessions)
    
    basepath = ['E:\Data\GroundTruth\', sessions{iSess}];
    cd(basepath);
    selecSession = sessions{iSess};
    
    disp(['Currently evaluating session:' sessions{iSess}])
    sessionInfo = bz_getSessionInfo(cd);
    %sessionInfo.region = areas{iSess}
    
    
    params.nChans = sessionInfo.nChannels;
    params.sampFreq = sessionInfo.rates.wideband;
    params.Probe0idx = sessionInfo.channels;
    params.Probe = params.Probe0idx+1;
    params.juxtachan = 1
    %params.Probe0idx = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
    %params.Probe = params.Probe0idx +1;
    
    ops.intervals = [0 Inf]; %in sec - change to desired time (find via neuroscope) multiple intervals can be assigned to multiple rows
    ops.downsamplefactor = 1;
    ops.intervals = [0 Inf];%[480 Inf]; %sec
    ops.SNRthr = 10; % figure this one out per cell PARAM SEARCH
    ops.filter = 'butterworth';
    ops.hpfreq = 450;
    ops.buttorder = 1;
    ops.firorder = 256;
    ops.templateMatch = 1;
    ops.spikeSamps = [-40:60];
    ops.doPlots =0;
    
    plotops.plotRawTraces       = 1;
    plotops.plotRasters         = 1;
    
    %raw traces
    plotops.lfpTracesLowY   = -6.8*10^4;
    plotops.lfpstepY        = 1000;
    plotops.divisionFactorLFP = 1;
    % rasters
    plotops.rasterstepY = 500;
    
    % Make .lfp file ... only if lfp does not exist
    if any(size(dir([basepath '/*.lfp' ]),1)) == 0
        bz_LFPfromDat(cd);
    end
    % Load LFP
    datfileName = [sessions{iSess} '.dat'];
    lfp = bz_GetLFP('all','basename', selecSession,'noPrompts',true);
    
    % Get Juxta Spikes
    % Load juxta chan
    %'m52_190731_145204_cell3'; %.dat
    
%%% LOAD IN THE JUXTA AND CORRESPONDING EXTRA TIMES
%      
%     juxtadata = getJuxtaData(basepath, datfileName, ops, params);
%     %%
%     [juxtaSpikes,allJuxtas] = GetJuxtaSpikes(juxtadata, selecSession, ops,params);


%%% END
    %% Find Ripples %% ONLY HPC AND RSC!!
    chan = bz_GetBestRippleChan(lfp);
    
    [ripples] = bz_FindRipples(lfp.data(:,chan),lfp.timestamps,'thresholds', [1 3]); %may have to give date,  line 374
    %change the first one to detect better
    
    rawdata = bz_LoadBinary(datfileName,'frequency',30000,'nChannels',33,'channels',chan);

    
    sampFreq = lfp.samplingRate;
    dLfpData = double(lfp.data(:,chan));
    buttOrder = ops.buttorder;
    ripFreq = [80 150]; % Cut off frequency
    %[b,a] = butter(buttOrder,[ripFreq/(sampFreq/2)],'stop'); % Butterworth filter of order \
    [b,a] = fir1(256,ripFreq/(sampFreq/2),'stop');
    filtLfpData = filtfilt(b,a,dLfpData);
    % Gives you output of times (start stop) for all ripples
    % To determine: How do we select what channel we take as a reference?
    % Different # of ripples for different channels
    
    
    %% pseudo EMG from LFP
    [EMGFromLFP] = bz_EMGFromLFP(cd,'overwrite',true,'rejectChannels', 0,'samplingFrequency', 1250,'noPrompts',true); % 0 is juxtachan
    
    
    %% plot the things
    plotops.plotEMG = 1;
    plotops.plotRipple = 1;
    plotops.plotRawTraces = 1;
    plotops.plotRasters = 1;
    ops.intervals = [732 734];%[230 231];
    
    figure
    subplot(4,1,1)
    % plot(EMGFromLFP.timestamps, EMGFromLFP.data);
    smoothEMG = movmean(EMGFromLFP.data,.25*1250);
    plot(EMGFromLFP.timestamps,smoothEMG)
    hold on, plot(EMGFromLFP.timestamps, (smoothEMG>0.8)); % if zero-lag correlation > 0.9 (arbitrary), call it a movement epoch?
    %     figure,hold on, plot(EMGFromLFP.timestamps, (EMGFromLFP.data));
        ylim([0 1.2])
    xlim([ops.intervals(1) ops.intervals(2)])
    box off
    set(gca,'TickDir','out')
    
    subplot(4,1,2)
    plot(lfp.timestamps,filtLfpData)
    hold on, plot(ripples.peaks,repmat(100,length(ripples.peaks),1), '*')
    xlim([ops.intervals(1) ops.intervals(2)])
    box off
    
    subplot(4,1,3) % right now the ripple filtered channel does not look any different than the filtered channel.....
    plot((1:length(rawdata))/30000,double(rawdata))  % add ,'color'  if you want all the traces to be the same color
    xlim([ops.intervals(1) ops.intervals(2)])
    box off
    set(gca,'TickDir','out')
    
    % rasters
    subplot(4,1,4)
    spikes = juxtaSpikes;
    
    yTMmax = 0;
    yTMmin = 1;
    for idx_hMFR = 1 %clusters sorted by descending meanFR
        for iSpk = 1:length(spikes.times{idx_hMFR})
            if spikes.times{idx_hMFR}(iSpk) > ops.intervals(1)  && spikes.times{idx_hMFR}(iSpk) <ops.intervals(2)
                line([spikes.times{idx_hMFR}(iSpk) spikes.times{idx_hMFR}(iSpk)],[yTMmin yTMmax]),
                hold on
            end
        end
        yTMmin = yTMmin-plotops.rasterstepY;
        yTMmax = yTMmax-plotops.rasterstepY;
    end
    ylim([-0.5 1.5])
    xlim([ops.intervals(1) ops.intervals(2)])
    box off
    set(gca,'TickDir','out')
    
end

%     [out] = gt_PlotRawTraces(juxtaSpikes(iSess), lfp, params,ops,plotops);
% end



%
% %% Get timestamps of when there is movement
%  EMG_info.idx_movement_datapoints = find(EMGFromLFP.data>0.9);
%  EMG_info.idx_rest_datapoints = find(EMGFromLFP.data <= 0.9);
%  EMG_info.movement_timestamps = EMGFromLFP.timestamps(EMG_info.idx_movement_datapoints);
%  EMG_info.rest_timestamps = EMGFromLFP.timestamps(EMG_info.idx_rest_datapoints);
%
%  [EMG_move_num_CorrComOm, EMG_rest_num_CorrComOm] = gt_EMG_CorrComOm(EMG_info,juxtaSpikes)
%
%  %% Sanity check :)
%  figure
%  plot(EMGFromLFP.timestamps, EMGFromLFP.data, '.r');
%  hold on
%  plot(lfp.timestamps,lfp.data(:,20))
%



