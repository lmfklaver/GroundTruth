%% Juxta Sorter Ground Truth
% dependency: buzcode
addpath(genpath('E:\Dropbox\MATLAB (1)\AdrienToolBox\'))%TStoolbox
addpath(genpath('E:\Dropbox\Code\GroundTruth\'))
addpath(genpath('C:\Users\lklaver\Documents\GitHub\buzcode'))

%
% basepath = 'E:\Data\GroundTruth\m15_190315_152315';
% cd(basepath)
% basename = '1_190315_152315.dat';

%GTSessionsInfo

sessions = {'m14_190326_155432',...
'm14_190326_160710_cell1',...
'm15_190315_142052_cell1',...
'm15_190315_145422',...
'm15_190315_150831_cell1',...
'm15_190315_152315_cell1',...
'm16_190404_155823',...
'm26_190524_100859_cell1',...
'm26_190524_100859_cell2',...
'm26_190524_100859_cell3',...
'm41_190614_114301_cell1',...
'm41_190614_114301_cell2',...
'm41_190614_114301_cell3',...
'm41_190614_114301_cell4',...
'm41_190621_125124_cell1',...
'm52_190725_142740_cell1',...
'm52_190731_145204_cell1',...
'm52_190731_145204_cell2',...
'm52_190731_145204_cell3'};
% 
% FILES BEFORE SPLIT:
% 'm26_190524_100859',...
% 'm41_190614_114301',...
% 'm41_190621_125124',...
% 'm52_190725_142740',...
% 'm52_190731_145204',...

% MISSING:
%'m52_190731_145204_cell1',... % not there?
%'m52_190731_145204_cell2',... % not there?

% UNKNOWN: MIGHT BE LOOKING FOR CELLS BUT NOT FINDING ONE: OPENING INTAN
% MAKES FOLDER
% 'm15_190315_150535',... % what is this?
% 'm15_190315_155044',... % what is this?
% 'm16_190403_122130',...% what is this?


%'m14_190326_160710',... % stim
%'m15_190315_142052',... % stim
% {'m14_190326_155432',...
%     'm14_190326_160710',...
%     'm15_190315_142052',...
%     'm15_190315_145422',...
%     'm15_190315_150831',...
%     'm15_190315_152315',...
%     'm16_190404_155823',...
%     'm26_190524_100859_cell1',...
%     'm26_190524_100859_cell2',...
%     'm26_190524_100859_cell3',...
%     'm41_190614_114301_cell1',...
%     'm41_190614_114301_cell2',...
%     'm41_190614_114301_cell3',...
%     'm41_190614_114301_cell4',...
%     'm41_190621_125124_cell1',...
%     'm52_190725_142740_cell1',...
%     'm52_190731_145204_cell3'};
% params

params.juxtachan = 1;

% variable ops
ops.intervals = [0 Inf];%[480 Inf]; %sec
ops.downsamplefactor = 1;
ops.SNRthr = 8; % figure this one out per cell PARAM SEARCH
ops.filter = 'butterworth';
ops.hpfreq = 1000;
ops.buttorder = 1;
ops.firorder = 256;
ops.templateMatch = 1;
ops.spikeSamps = [-40:60];


for iSess = 1%:length(sessions)
    basepath = fullfile('E:\Data\GroundTruth\',sessions{iSess});%'m52_190731_145204_cell3';
    cd(basepath)
    disp(['Currently evaluating session:' sessions{iSess}])

    sessionInfo = bz_getSessionInfo;

    params.nChans = sessionInfo.nChannels;
    params.sampFreq = sessionInfo.rates.wideband;
    params.channels0idx = sessionInfo.channels;
    params.channels = params.channels0idx+1;
    
    if ~isempty(sessionInfo.region)
        params.region = sessionInfo.region;
    end
    help    
    if params.nChans == 33
        params.chansinorder = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
    elseif params.nChans == 5
        params.chansinorder = [1 2 3 4 0];
    end
    
    datfileName = [sessions{iSess} '.dat'];%'m52_190731_145204_cell3'; %.dat
    
    % Load juxta chan
    juxtadata = getJuxtaData(basepath, datfileName, ops, params);
    
    % Detect spikes above threshold
    [juxtaSpikes(iSess)] = GetJuxtaSpikes(juxtadata, sessions{iSess}, ops);
    
    allJuxtas(iSess) = juxtaSpikes(iSess).times;
     
   
end
%%
%plot ACG
ops.ccgBinSize = 0.001;
ops.ccgDur = 0.1;
[ccg,t]=CCG(allJuxtas,[],'Fs',params.sampFreq,'binSize',ops.ccgBinSize,'duration', ops.ccgDur,'norm','rate');

plotCount = 1;
figure
for idx_hMFR = 1:size(ccg,2)
    for iPair = 1:size(ccg,2)
        if idx_hMFR == iPair
            subplot(ceil(sqrt(size(ccg,2))),ceil(sqrt(size(ccg,2))),plotCount)
            plotCount = plotCount+1;
            if idx_hMFR == iPair
                bar(t,ccg(:,idx_hMFR,iPair),'k')
            end
            
        end
    end
end

figure
hold on
for iSess = 1:length(sessions)
    subplot(ceil(sqrt(length(sessions))),ceil(sqrt(length(sessions))),iSess)
        plot(juxtaSpikes(iSess).rawWaveform{1})
end


for idx_hMFR = 1:length(juxtaSpikes)
        numSpikes = length(juxtaSpikes(idx_hMFR).times{1});
        recLengthSec = juxtaSpikes(idx_hMFR).ts{1}(end)/params.sampFreq;
        meanFR(idx_hMFR) = numSpikes/recLengthSec;
        %spikes per second /Fs ->> to go o  seconds
end
%     hist(meanFR,10)

% PCA % Leave for now

%% Kmeans clustering on waveform
for iSpk = 1:length(juxtaSpikes.spk)
    [iw(iSpk),ahp(iSpk),pr(iSpk),ppd(iSpk),slope(iSpk),had(iSpk)]=waveforms_features(juxtaSpikes.spk(iSpk,:),params.sampFreq);
end

K = 3;
X = [iw; ppd;had;ahp;pr;slope]';
[IDX] = kmeans(X, K); % partitions the points in the N-by-P data matrix X into K clusters.

% plot kmeans
figure
hold on
for i=1:K
    colors = 'brgy';
    app=find(IDX==i);
    
    for j = 1:length(app)
        plot(juxtaSpikes.spk(app(j),:), colors(i))
        hold on
    end
    
end

figure,
hold on
for i=1:K
    app =find(IDX ==i);
    colors = 'brgy';
    
    subplot(4,4,1)
    hold on
    plot(X(app,1),X(app,2),[colors(i),'.']);
    title('1 vs 2')
    subplot(4,4,2)
    hold on
    plot(X(app,1),X(app,3),[colors(i),'.']);
    title('1 vs 3')
    subplot(4,4,3)
    hold on
    plot(X(app,1),X(app,4),[colors(i),'.']);
    title('1 vs 4')
    subplot(4,4,4)
    hold on
    plot(X(app,1),X(app,5),[colors(i),'.']);
    title('1 vs 5')
    subplot(4,4,5)
    hold on
    plot(X(app,1),X(app,6),[colors(i),'.']);
    title('1 vs 6')
    subplot(4,4,6)
    hold on
    plot(X(app,2),X(app,1),[colors(i),'.']);
    title('2 vs 1')
    subplot(4,4,7)
    hold on
    plot(X(app,2),X(app,3),[colors(i),'.']);
    title('2 vs 3')
    subplot(4,4,8)
    hold on
    plot(X(app,2),X(app,4),[colors(i),'.']);
    title('2 vs 4')
    subplot(4,4,9)
    hold on
    plot(X(app,2),X(app,5),[colors(i),'.']);
    title('2 vs 5')
    subplot(4,4,10)
    hold on
    plot(X(app,2),X(app,6),[colors(i),'.']);
    title('2 vs 6')
    subplot(4,4,11)
    hold on
    plot(X(app,3),X(app,1),[colors(i),'.']);
    title('3 vs 1')
    subplot(4,4,12)
    hold on
    plot(X(app,3),X(app,2),[colors(i),'.']);
    title('3 vs 2')
    subplot(4,4,13)
    hold on
    plot(X(app,3),X(app,4),[colors(i),'.']);
    title('3 vs 4')
    subplot(4,4,14)
    hold on
    plot(X(app,3),X(app,5),[colors(i),'.']);
    title('3 vs 5')
    subplot(4,4,15)
    hold on
    plot(X(app,3),X(app,6),[colors(i),'.']);
    title('3 vs 6')
    
end
