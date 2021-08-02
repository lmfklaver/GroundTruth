%% Script with all the items to get the raw traces figure for the SfN Poster

% addpath(genpath('C:\Users\lklaver\Documents\Github\GroundTruth'))
% addpath(genpath('C:\Users\lklaver\Documents\GitHub\buzcode'))

% Dependencies
%   JuxtaSorter() ... gives juxta spikes

%%
% For Future -- if had folder of only cut cells wanting to look at...
% sessions_extended = dir('D:\Data\GroundTruth\');
% sessions = {sessions_extended.name};


sessions = {'m15_190315_152315'};

%     All Sessions
%     {'m14_190326_155432',...
%     'm14_190326_160710_cell1',...
%     'm15_190315_142052_cell1',...
%     'm15_190315_145422',...
%     'm15_190315_150831_cell1',...
%     'm15_190315_152315_cell1',...
%     'm52_190731_145204_cell3'};   

areas = {'hpc','hpc','cx','hpc','hpc','hpc','th'};
%%
plotRasters = 0;

for iSess = 1%1:length(sessions)
    
    %KS1 
    pathInfo.JuxtaPath = 'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
    pathInfo.ExtraPath = 'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
    
    pathInfo.RecPath = ['E:\Data\GroundTruth\', sessions{iSess}];
    cd(pathInfo.RecPath);
    
    selecSession = sessions{iSess};
    
    disp(['Currently evaluating session:' sessions{iSess}])
    sessionInfo = bz_getSessionInfo(cd);
    %sessionInfo.region = areas{iSess}
    
    
    params.nChans = sessionInfo.nChannels;
    params.sampFreq = sessionInfo.rates.wideband;
    params.Probe0idx = sessionInfo.channels;
    params.Probe = params.Probe0idx+1;
    params.juxtachan = 1;
    %params.Probe0idx = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
    %params.Probe = params.Probe0idx +1;
    
    ops.intervals           = [0 Inf]; %in sec - change to desired time (find via neuroscope) multiple intervals can be assigned to multiple rows
    ops.downsamplefactor    = 1;
    ops.intervals           = [0 Inf];%[480 Inf]; %sec
    ops.SNRthr              = 10; % figure this one out per cell PARAM SEARCH
    ops.filter              = 'butterworth';
    ops.hpfreq              = 450;
    ops.buttorder           = 1;
    ops.firorder            = 256;
    ops.templateMatch       = 1;
    ops.spikeSamps          = [-40:60];
    ops.doPlots             = 0;
     
    plotops.plotRawTraces   = 1;
    plotops.plotRasters     = 1;
    
    %raw traces
    plotops.lfpTracesLowY       = -6.8*10^4;
    plotops.lfpstepY            = 1000;
    plotops.divisionFactorLFP   = 1;
    
    % rasters
    plotops.rasterstepY         = 500;
    
    % Make .lfp file ... only if lfp does not exist
    if any(size(dir([pathInfo.RecPath '/*.lfp' ]),1)) == 0
        bz_LFPfromDat(cd);
    end
    
    % Load LFP
    datfileName = [sessions{iSess} '.dat'];
    lfp         = bz_GetLFP('all','basename', selecSession); %
    
    %% Get Juxta spikes (Multiple ways)
    
    % Lianne's juxta-extraction
    %     juxtadata = getJuxtaData(basepath, datfileName, ops, params);
    %     [JuxtaSpikes,allJuxtas] = GetJuxtaSpikes(juxtadata, selecSession, ops,params);
    
    % James % mda files
    %     pathInfo.JuxtaPath = 'E:\Data\GroundTruth\juxta_cell_output\m15_190315_152315_cell1';
    %     pathInfo.ExtraPath = 'E:\Data\GroundTruth\juxta_cell_output\m15_190315_152315_cell1';
    
    % Old KS1 files
%     pathInfo.JuxtaPath = 'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';
%     pathInfo.ExtraPath = 'E:\Data\GroundTruth\m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
    
    % Get Times
    
    [highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes] = gt_LoadJuxtaCorrExtraOld(pathInfo);
    
    
    %% Find Ripples % ONLY HPC AND RSC Recordings
    chan    = bz_GetBestRippleChan(lfp);
    ripples = bz_FindRipples(lfp.data(:,chan),lfp.timestamps,'thresholds',[1 4]); %may have to give date,  line 374

    % ripples.timestamps(1) and ripples.timestamps(2) are the start and
    % stop times of the ripples
    
    
    % Make a logical of ripple blocks to plot
    allRipIdx = [];
    
    for iRip = 1:length(ripples.timestamps)
        ripLogic    = find(lfp.timestamps>ripples.timestamps(iRip,1) & lfp.timestamps<ripples.timestamps(iRip,2));
        allRipIdx   = [allRipIdx; ripLogic];
    end
    
    rippTs      = lfp.timestamps(allRipIdx);
    rippLogic   = ismember(lfp.timestamps,rippTs);
    
    %% Load Raw Data
    rawdata = bz_LoadBinary(datfileName,'frequency',params.sampFreq,'nChannels',33,'channels',chan);
    
    %% Filtered LFP Data
    sampFreq = lfp.samplingRate;
    dLfpData = double(lfp.data(:,chan));
    ripFreq = [120 200]; % Cut off frequency
    
    % butterworth filter
%   buttOrder = ops.buttorder;
%   [b,a] = butter(buttOrder,[ripFreq/(sampFreq/2)],'stop'); % Butterworth filter of order \
    
    % fir1 filter
    [b,a] = fir1(256,ripFreq/(sampFreq/2),'stop');
    filtLfpData = filtfilt(b,a,dLfpData);
    
    
    
    %% Population Synchrony cumulSpikeRate:
    cd(pathInfo.JuxtaPath)
    e_spikes = readmda('firings.mda');
    [viTime_spk, viClu_spk] = deal(e_spikes(2,:), e_spikes(3,:));
    
    binSize     = 0.01; %s;
    binnedmua   = hist(viTime_spk,round(viTime_spk(end)/30000/binSize));
    timevec     = 1:length(binnedmua);
    timevec     = timevec * binSize;
    
    %% pseudo EMG from LFP
    cd(pathInfo.RecPath)
    
    [EMGFromLFP] = bz_EMGFromLFP(cd,'overwrite',true,'rejectChannels', 0,'samplingFrequency', 1250,'noPrompts',true); % 0 is juxtachan
    smoothEMG    = movmean(EMGFromLFP.data,.25*1250);
    
    %% plot the things
    plotops.plotEMG         = 1;
    plotops.plotRipple      = 1;
    plotops.plotRawTraces   = 1;
    plotops.plotRasters     = 1;
    ops.intervals           = [726.8 727.8]; %[740 742]; %EMG
    ops.ripintervals        = [468.9 469.9];%[469 470]; %Rip
    
    figure
    
    % plot EMG + thresholded EMG
    
    subplot(3,2,5)
    % plot(EMGFromLFP.timestamps, EMGFromLFP.data);
    plot(EMGFromLFP.timestamps,smoothEMG)
    hold on, plot(EMGFromLFP.timestamps, (smoothEMG>0.8)); % if zero-lag correlation > 0.9 (arbitrary), call it a movement epoch?
    ylim([0 1.2])
    xlim([ops.intervals(1) ops.intervals(2)])
    
    box off
    set(gca,'TickDir','out')
    
    % plot thresholded Ripple
    subplot(3,2,6)
    plot(lfp.timestamps,filtLfpData)
    hold on
    plot(lfp.timestamps,rippLogic*2000)
    plot(ripples.peaks,repmat(100,length(ripples.peaks),1), '*')
    xlim([ops.ripintervals(1) ops.ripintervals(2)])
    box off
    set(gca,'TickDir','out')
    
    % plot population synchrony during emg epoch
    subplot (3,2,3)
    plot(timevec, binnedmua)
    xlabel('time (s)')
    ylabel('# spikes')
    %title('Population synchrony: Cumulative extracellular spikes')
    xlim([ops.intervals(1) ops.intervals(2)])
    ylim([0 20])
    box off
    set(gca,'TickDir','out')
    
    % plot population synchrony during ripple epoch
    subplot (3,2,4)
    plot(timevec, binnedmua)
    xlabel('time (s)')
    ylabel('# spikes')
    %   title('Population synchrony: Cumulative extracellular spikes')
    xlim([ops.ripintervals(1) ops.ripintervals(2)])
    ylim([0 20])
    box off
    set(gca,'TickDir','out')
    
    % plot raw data emg
    subplot(3,2,1)
    plot((1:length(rawdata))/30000,double(rawdata))
    xlim([ops.intervals(1) ops.intervals(2)])
    ylim([-2300 2300])
    box off
    set(gca,'TickDir','out')
    
    % plot raw data ripple
    subplot(3,2,2)
    hold on
    plot((1:length(rawdata))/30000,double(rawdata))  % add ,'color'  if you want all the traces to be the same color
    xlim([ops.ripintervals(1) ops.ripintervals(2)])
    ylim([-2300 2300])
    box off
    set(gca,'TickDir','out')
    
    if plotRasters
        % rasters
        figure
        subplot(2,1,1)
        spikes = juxtaSpikes;
        
        yTMmax = 0;
        yTMmin = 1;
        for idx_hMFR = 1 %clusters sorted by descending meanFR
            for iSpk = 1:length(JuxtaSpikesTimes)
                if JuxtaSpikesTimes(iSpk) > ops.intervals(1)  && JuxtaSpikesTimes(iSpk) <ops.intervals(2)
                    line([JuxtaSpikesTimes(iSpk) JuxtaSpikesTimes(iSpk)],[yTMmin yTMmax]),
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
   
    
end

