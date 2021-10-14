%% ripple detection 

lfp = bz_GetLFP('all');
maxripchannel = 27;

[ripples] = bz_FindRipples(basepath,maxripchannel,'thresholds',[4 7],...
    'durations',[30 100],'passband',[130 200],'saveMat',false,'EMGThresh',0);
ripples.detectorinfo.detectionchannel = maxripchannel;
save([basename,'.ripples.events.mat'], 'ripples')

makeRipFile

% plot Rips and manually exclude EMGs 
% for iRip = 1:length(