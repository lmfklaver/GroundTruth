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

% sessions =  {'m14_190326_160710_cell1'};
basepath = cd;
basename = bz_BasenameFromBasepath(basepath);
sessions = {basename};

%%%% =  {'m15_190315_150831_cell1'};
areas = {'hpc'};
proximThresh = 20;

%ommit SNR bad
%'m41_190621_125124_cell1',...
%'m52_190731_145204_cell2',...

intervals           = [0 inf];
SampFreq            =   30000;
ops.doPlots             =   0;

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
        
SNR1_temp = 4;
numIter1_temp = 2;
% tempmatchThr1 = 0.8;
SNR2_temp = 20;
numIter2_temp = 1;
% tempmatchThr2 = 0.8;

        [juxtaSpikes] = GetJuxtaSpikes(basepath, 'intervals', intervals,'juxtachan',0, ...
            'templateMatch',true,'filter','butterworth','saveMat',true,...
            'forceOverwrite',true,'SNRThr',SNR1_temp, 'numIters',numIter1_temp);
% ,'tempmatchThr',tempmatchThr1
%         remember that 7/14/21 you changed the default filter to fir1
% 8/3/21 - bout to commit some real nonsense plays with two GetJuxtaSpikes.
% tyring to run two analyses with a high SNR run through and a low SNR run
% through. Will do this by running the function twice and adding more
% options to the parser. 
        juxtaMerger = 1;
        if juxtaMerger == 1
            
            [juxtaSpikes2] = GetJuxtaSpikes(basepath, 'intervals', intervals,'juxtachan',0, ...
                'templateMatch',true,'filter','butterworth','saveMat',true,...
                'forceOverwrite',true,'SNRThr',SNR2_temp, 'numIters',numIter2_temp);
% ,'tempmatchThr',tempmatchThr2

            juxta1 = juxtaSpikes.finalIter.ts;
            juxta2 = juxtaSpikes2.ts{1}; %this may be a source of confusion
            dupTimeInt = 0.002;
            [mergedJuxta] = EA_MergeJuxtaTimes(juxta1,juxta2,dupTimeInt);
            juxtaSpikes.ts{1} = mergedJuxta;
            
            juxta1Times = juxtaSpikes.finalIter.times;
            juxta2Times = juxtaSpikes2.times{1};
            [mergedJuxtaTimes] = EA_MergeJuxtaTimes(juxta1Times,juxta2Times,dupTimeInt);
            juxtaSpikes.times{1} = mergedJuxtaTimes;
            
%           checks for near duplicates
            diffJuxtaSpikes = diff(juxtaSpikes.times{1});
%             proximThresh = 20; % defined above
            diffJuxtaSpkInx = find(diffJuxtaSpikes <= (proximThresh/SampFreq));
            juxtaSpikes.times{1}(diffJuxtaSpkInx) = [];

            % intervals will be read from excel ffile
            basename = bz_BasenameFromBasepath(basepath);
            save([basename, '.juxtaSpikes.mat'], 'juxtaSpikes', 'juxtaSpikes2','mergedJuxta')
        end
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


