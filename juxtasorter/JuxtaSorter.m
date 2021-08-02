%% Juxta Sorter Ground Truth

% Workflow to get the ground truth juxta sorter going 
%
% Relies on functions in 
% Buzcode, TSToolbox, Groundtruth Github repo

% addpath(genpath('E:\Dropbox\MATLAB (1)\AdrienToolBox\'))%TStoolbox
% addpath(genpath('C:\Users\lklaver\Github\GroundTruth\'))

%GTSessionsInfo

%  Replace this with an excell sheet that can be loaded in using xlsread
% [NUM,TXT,RAW]=XLSREAD(FILE,RANGE)
%   sessions = {'basename_1' ... 'basename_n'};

sessions =  {'m14_190326_160710_cell1'};
% sessions =  {'m15_190315_145422'};
areas = {'hpc'};


%ommit SNR bad
%'m41_190621_125124_cell1',...
%'m52_190731_145204_cell2',...

% params

% params.juxtachan = 1;
% variable ops
% ops.intervals = [0 Inf];%[480 Inf]; %sec
% ops.downsamplefactor = 1;
% ops.SNRthr = 7; % figure this one out per cell PARAM SEARCH
% ops.filter = 'butterworth';
% ops.hpfreq = 1000;
% ops.buttorder = 1;
% ops.firorder = 256;
% ops.templateMatch = 1;
% ops.spikeSamps = -40:55;
% ops.doPlots = 0;
% 
% ops.ccgBinSize = 0.0015;
% ops.ccgDur = 0.1;

myDataPath = 'D:\GroundTruth\';
areaOfInterest = 'hpc';

for iSess = 1:length(sessions)
    
    selecSession = sessions{iSess};
    
        if strcmp(areas{iSess},areaOfInterest)
            
        basepath = fullfile(myDataPath,selecSession);
        
        cd(basepath)
        
        disp(['Currently evaluating session:' selecSession])
        
%         sessionInfo = bz_getSessionInfo;
%         
%         params.nChans = sessionInfo.nChannels;
%         params.sampFreq = sessionInfo.rates.wideband;
%         params.channels0idx = sessionInfo.channels;
%         params.channels = params.channels0idx+1;
%         
%         if ~isempty(sessionInfo.region)
%             params.region = sessionInfo.region;
%         end
%         
%         if params.nChans == 33
%             params.chansinorder = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
%         elseif params.nChans == 5
%             params.chansinorder = [1 2 3 4 0];
%         end
        
        [juxtaSpikes] = GetJuxtaSpikes(basepath, 'intervals', intervals,'juxtachan',0, ...
            'templateMatch',true,'filter','butterworth','saveMat',true,'forceOverwrite',true);
%         remember that 7/14/21 you changed the default filter to fir1
        
        
        % intervals will be read from excel file 
        
        allJuxtas = juxtaSpikes.times;

    else
        continue
    end
end



if ops.doPlots
    plotJuxtaSorted(allJuxtas,juxtaSpikes, sessions, ops,params)
    [meanFR] = plotJuxtaFR(juxtaSpikes, params);
end

% PCA + Kmeans
% if kMeansWF
%     [IDX]=kMeansOnWF(spikes, params);
% end


