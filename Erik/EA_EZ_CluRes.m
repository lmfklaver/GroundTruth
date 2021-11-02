% Erik's EZ clu res generator
% cd the main datafile

%% input/param section

sorterFolder             = 'ks2';
opts.extra_sorter        = 'EC_kilosort2';
opts.SampFreq            = 30000;
opts.rangeSpkBin         = .002;
opts.timWinWavespec      = 250;

session = bz_getSessionInfo; 
session.spikeGroups; 

S = [session.FileName, '_EC'];
sessions = {session.FileName};

basepath = cd;
basename = bz_BasenameFromBasepath(basepath);
opts.basename = basename;

params.Probe0idx    = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
params.Probeflip    = flip(params.Probe0idx);
params.Probeflip(1) = []; % rm juxta
params.juxtachan    = 1;
params.Probe        = params.Probe0idx +1;


    if(exist('spikes') ~= 1)
        filepath = fullfile(basepath, sorterFolder,[S, '.spikes.cellinfo.mat']);
        load(filepath);
    end

    if(exist([basename, '.juxtaSpikes.mat']) ==2)
        load(fullfile(basepath,[basename, '.juxtaSpikes.mat']));
    else
        disp('Run JuxtaSorter.m for this session');
    end

%% get JCEC
if(exist([basename, '.EZ_JCEC_EA.mat']) ~= 2)
iSess = 1;
pathInfo.JuxtaPath = ['D:\GroundTruth\', sessions{iSess}];% these are for the 'firing_true.mda' found in the main file
pathInfo.ExtraPath = ['D:\GroundTruth\', sessions{iSess},'\ks2'];% these are for the 'firing.mda' files found in kilosort
pathInfo.RecPath = ['D:\GroundTruth\', sessions{iSess}];
% [highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes, bestCluster] = gt_LoadJuxtaCorrExtra(pathInfo,params,opts);

% [cco_timevector, cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, bestCluster, lfp_extra,lfp_juxta, opts, sessions, iSess);

save([basename, '.EZ_JCEC_EA.mat']) %, 'cco_timevector', 'cco_indexvector','num_CorrComOm'
elseif(exist([basename, '.EZ_JCEC_EA.mat']) == 2)
load(fullfile(basepath,[basename, '.EZ_JCEC_EA.mat']));
else
    disp('Somethin is not quite right there pardner');
end
%% cluster things generate cluster files
EA_MakeSingleCluster(basename,0,juxtaSpikes.ts,1);

nClu = bestCluster; %clu/res for best cluster
EA_MakeSingleCluster(basename,nClu,spikes.ts,nClu);

try
gg = juxtaSpikes.allIters;
allItersGo = 1;
catch
allItersGo = 0;
end

if allItersGo
iterNum = spikes.numcells + 1; %clu/res for first iteration
EA_MakeSingleCluster(basename,iterNum,juxtaSpikes.allIters.ts,1);
end

finalIterNum = spikes.numcells + 2; %clu/res for final iteration
finalIterCell{1} = juxtaSpikes.finalIter.ts;
EA_MakeSingleCluster(basename,finalIterNum,finalIterCell,1);

altJuxtaNum = spikes.numcells + 3; %clu/res for alt final iteration
altJuxtaCell{1} = juxtaSpikes2.finalIter.ts;
EA_MakeSingleCluster(basename,altJuxtaNum,altJuxtaCell,1);

mergedJuxtaNum = spikes.numcells + 4; %clu/res for merged iteration
mergedJuxtaCell{1} = mergedJuxta;
EA_MakeSingleCluster(basename,mergedJuxtaNum,mergedJuxtaCell,1); 


