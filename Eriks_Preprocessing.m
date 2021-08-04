%% Erik's Preprocessing Workflow with Buzcode

%% Get Metadata


session = bz_getSessionInfo; 
session.spikeGroups; %

%% Define Generic Options   
    opts.rangeSpkBin        = .002; %binsize for extra occurring before or after juxta % maybe a bit wider for james' irc2 output?
    opts.timWinWavespec     = 250; %ms
    opts.doSave             = 0;
    opts.freqRange          = [1 500];
    opts.numFreqs           = 100;%ops.freqRange(end)-ops.freqRange(1);
    opts.bltimvec           = 10*501-1+250; %5259
    opts.intervals           = [0 Inf]; %in sec - change to desired time (find via neuroscope) multiple intervals can be assigned to multiple rows
    opts.downsamplefactor    = 1;
    opts.intervals           = [0 Inf];%[480 Inf]; %sec
    opts.hpfreq              = 450;
    opts.doPlots             = 0; 
    opts.SampFreq            = 30000;
    opts.extra_sorter        = 'EC_kilosort2';
    
    rangeSpkBin        = .002; %binsize for extra occurring before or after juxta % maybe a bit wider for james' irc2 output?
% is usually 0.001
    timWinWavespec     = 250; %ms
    doSave             = 0;
    freqRange          = [1 500];
    numFreqs           = 100;%ops.freqRange(end)-ops.freqRange(1);
    bltimvec           = 10*501-1+250; %5259
    intervals           = [0 Inf]; %in sec - change to desired time (find via neuroscope) multiple intervals can be assigned to multiple rows
    downsamplefactor    = 1;
    intervals           = [0 Inf];%[480 Inf]; %sec % need this one ***
    hpfreq              = 450;
    ops.doPlots             = 0; % need this one ***
    SampFreq            = 30000;
    extra_sorter        = 'EC_kilosort2';
    sessionLength       = 577; %in seconds
    
    params.Probe0idx    = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
    params.Probeflip    = flip(params.Probe0idx);
    params.Probeflip(1) = []; % rm juxta
    params.juxtachan    = 1;
    params.Probe        = params.Probe0idx +1;
 
    doSpikeTimeSanity = 0;
%              tempThr = 15;
%               SNRthr = 7;
%               filter = 'butterworth';
%               buttorder = 1;            
%        templateMatch = 1;          
%           ccgBinSize = 0.0015;
%               ccgDur = 0.1000;


%% Get Analogin/Digitalin

basepath = cd;
basename = bz_BasenameFromBasepath(basepath);
opts.basename = basename;
%clone utilities folder! https://github.com/englishneurolab/utilities.git
analogin = getAnaloginVals(basepath,'wheelChan',1,'pulseChan','none',...
'rewardChan','none','samplingRate',30000,'downsampleFactor',300); % check function for inputs by typing edit getAnaloginVals
% analogin = getAnaloginVals(basepath,'wheelChan',1,'pulseChan','none','rewardChan','none'); % check function for inputs by typing edit getAnaloginVals
analogin_NoDs = getAnaloginVals(basepath,'wheelChan',1,'pulseChan','none',...
'rewardChan','none','samplingRate',30000,'downsampleFactor',0);

%% downsample analogin timestamps

analogin.ts = downsample(analogin_NoDs.ts,300);

%% Find our match

% % Get Spikes
% EC
%check something with paths
% cd(pathInfo.RecPath)
spikes = bz_LoadPhy; % edit bz_LoadPhy to check path things gives you .spikes.cellinfo.mat 
% you've edited bz_LoadPhy to look into ks2 for the .npy files

% also for other sorters 

% JC

% you effectively want to run JuxtaSorter beforehand with the list of
% sessions you want to analyze
% alternatively (although this has not yet been confirmed) you could just
% modify the .m file to be a function so you can call it and pass the
% filename in as a parameter. - Erik 
% you can save the output of JuxtaSorter as a cell specific juxtaspikes
% struct

% JuxtaSorter.m inside you'll find the functions GetJuxtaSpikes
% Check your Juxta Spikes in Neuroscope <- makeCluFiles
% juxtaspikes.mat already has .ts .times 



% compare JC and EC times to find the best match cluster and channel
% remember that pathInfo is coded into gt_LFP_hfArtifacts and
% gt_figureEMGRippleCCO.m

iSess = 1;
pathInfo.JuxtaPath = ['D:\GroundTruth\', sessions{iSess}];% these are for the 'firing_true.mda' found in the main file
pathInfo.ExtraPath = ['D:\GroundTruth\', sessions{iSess},'\ks2'];% these are for the 'firing.mda' files found in kilosort
pathInfo.RecPath = ['D:\GroundTruth\', sessions{iSess}];
[highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes, bestCluster] = gt_LoadJuxtaCorrExtra(pathInfo,params,opts);

% get commission and omission


% [cco_timevector, cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra,lfp_juxta, opts, sessions, iSess);
% JuxtaSpikestimes = juxta cellular spikes JuxtaSpikes.times
% ExtraSpikesTimes = extracell spikes,


[cco_timevector, cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, bestCluster, lfp_extra,lfp_juxta, opts, sessions, iSess); 

[cco_timevector,cco_indexvector,numMatch_Error] = EA_Matches_Errors(JuxtaSpikesTimes,ExtraSpikesTimes,highestChannelCorr, bestCluster,opts);

% ********************
% This is the end of the comission ommission data
% The following sections plot juxta spike times against their corresponding EC spike times, and then overlay the match times layed out in cco_timevector 
% ********************

%%

% Erik will make a fabulous script to separate out the piece of code to get
% the matching cluster and the lfp channel that it has the highest amplitude on . Right now it contains also pulling of the LFP
% around spike times. 
%% Erik makes a quick sanity graph which plots the juxta spike times with respect to the correlated extra spike times

% a quick note, (spikes.ts is in indices not seconds)
% ExtraSpikesTimes is also in times
% (juxtaSpikes.ts is in indices, wheras JuxtaSpikesTimes is in times

if doSpikeTimeSanity
    
timeSequence = [0:(1/30000):sessionLength];
juxtaHits = zeros(size(timeSequence));

for i = 1:length(juxtaSpikes.ts{1})
    
   ithJxSpike = round(juxtaSpikes.ts{1}(i));
   juxtaHits(1,ithJxSpike) = 1;   
    
end

juxPlotIDX = find(juxtaHits == 1);

% -----------------------------------------
extraHits = zeros(size(timeSequence));


hh = spikes.ts{highestChannelCorr};
for i = 1:length(hh)
    
   ithEcSpike = round(hh(i));
   extraHits(1,ithEcSpike) = 1;   
    
end

extraPlotIDX = find(extraHits == 1);


matchHits = zeros(size(timeSequence));

bb = (cco_timevector.matches)* 30000;
for i = 1:length(bb)
    
    ithMatch = round(bb(i));
    matchHits(1,ithMatch) = 1.0002;
end
% might do a technique where we use the integer 1 instead oof 1.0002 to
% prevent loss of data from inexactness (will then add the 0.0002
% afterwards
matchPlotIDX = find(matchHits == 1.0002);

% 14.352400000000001 * 30000

% matchHits(1,430572)

scatter(timeSequence(juxPlotIDX),juxtaHits(juxPlotIDX))
hold on
scatter(timeSequence(extraPlotIDX),extraHits(extraPlotIDX))
scatter(timeSequence(matchPlotIDX),matchHits(matchPlotIDX))
% juxtaSpikeHit = find()
% 
% v = juxtaHits(1,11851984:11851986);
% 
% timeSequence(1,11851986)
% 
% (3.950661666666667e+02)*30000 


% ************************************************************************* 
% End of supplemental comission omission spike time plots
% ahead is the place field junk
% *************************************************************************

end

%% figure 1 Place fields Juxta + Extra

position = analogin.pos;
% time = analogin.ts;

%% smooth signal

slide = 20;
kernel = pdf('Normal', -slide:slide+1, 0, 2);
filtered_pos = filtfilt(kernel,1,position);
% plot(filtered_output)
%% plot the pos trail

subplot(2,1,1)
plot(position) % plots raw position trace
subplot(2,1,2)
plot(filtered_pos) %plots filtered position trace

%% define voltage bins
voltSteps = 100;

vb_size = (max(filtered_pos)-min(filtered_pos))/voltSteps;

minPos = min(filtered_pos);
maxPos = max(filtered_pos);

for i = 1:voltSteps
    
    binStart(i) = minPos + vb_size*(i-1);
    binEnd(i) = minPos + vb_size*(i);
    
end

%% get lap times
% 

% lapEnd = find(filtered_pos <= max(filtered_pos) + 0.00015 && filtered_pos >= max(filtered_pos) - 0.00015);

[posPeak,posPeakInx] = findpeaks(filtered_pos); % gets the lap start/end by looking at the peaks of the filtered position trace

[threshPosPeak] = find(posPeak >= 1.17); % have to pass a threshold since "find peaks" is a little over-zealous with peak detection

threshPeakInx = posPeakInx(1,threshPosPeak);
threshPeakVal = filtered_pos(1,threshPeakInx);




hold on;
subplot(2,1,2);
scatter(threshPeakInx,threshPeakVal); % puts the orange markers on the filtered pos graph
hold off;
lap.end = analogin.ts(threshPeakInx);
lap.end(1,end + 1) = analogin.ts(1,end);
% analogStart(1,1) = analogin.ts(1,1);
lap.start(1,1) = analogin.ts(1,1);

for i = 1:(length(lap.end))
    
    lap.start(1, i + 1) = lap.end(1,i);
    
end

lap.num = length(lap.end);

for i = 1:lap.num
lap.startINX(1,i) = find(analogin.ts == lap.start(1,i));
end

for i = 1:lap.num
lap.endINX(1,i) = find(analogin.ts == lap.end(1,i));
end


% getting juxta bins
% getting every position time for each bin

% remember that bin start and end are just the highest and lowest voltage
% bins. We need to pair each lap time with a position
% also remember to use filtered position
for i = 1:lap.num

    lap.times{i} = analogin.ts(1,lap.startINX(i):lap.endINX(i));
    lap.pos{i} = filtered_pos(1,lap.startINX(i):lap.endINX(i));
    
end


% making good progress you now have time and position(voltage) of each lap
% now you need to convert voltage to position (au aka 0-100)
% remember, you recently (6/18/21) changed this to reflect 101 voltage bins
% this makes it closer in line to the vr track



% so now assign each bin a number 0-100, then for every voltage in lap.pos,
% check which bin it is in and assign it that bin number

% might have to first split JuxtaSpikeTimes into lap segments

binEdges = binStart;
binEdges(1,end+1) = binEnd(1,end);

jxtSpkLapPosMat = zeros(lap.num,100);
aveISIs = zeros(lap.num,100); % used for isi later, can ignore for now

%% making the juxta plots
for i = 1:lap.num
    
    currentLapTimes = lap.times{i}; 
    currentLapPos   = lap.pos{i};
    currJuxtaTimes_INX = find(JuxtaSpikesTimes >= currentLapTimes(1,1) & JuxtaSpikesTimes <= currentLapTimes(1,end) );
    currJuxtaTimes = JuxtaSpikesTimes(currJuxtaTimes_INX,1);
    
    binnedJuxtaTimes = discretize(currJuxtaTimes,currentLapTimes,'IncludedEdge','right');
    binnedJuxtaPos = currentLapPos(1,binnedJuxtaTimes);
    
%   the following lines you are adding are extra to calc ISI
% *** see if you can make this a function
    ISIs = diff(currJuxtaTimes);
    [ISI_Times] = EA_inBetween(currJuxtaTimes);
    binnedISI_Times = discretize(ISI_Times,currentLapTimes,'IncludedEdge','right');
    binnedISI_Pos = currentLapPos(1,binnedISI_Times);
    numericISI_Pos = discretize(binnedISI_Pos,binEdges,'IncludedEdge','right');
    
           
    aveISIs(i,:) = EA_aveISI_ByPos(ISIs,numericISI_Pos);
 
        
% *** 
    
    
    numericJuxtaPos = discretize(binnedJuxtaPos,binEdges,'IncludedEdge','right');
    
    jxtSpkPosCell{i} = numericJuxtaPos;
    [posCounts,posNumerVals] = groupcounts(jxtSpkPosCell{i}');
    
    jxtSpkLapPosMat(i,posNumerVals') = posCounts';    
    
end

% JSC_Lap = 
subplot(2,1,1);

imagesc(jxtSpkLapPosMat); % plots juxta spikes per position bin per lap
colorbar
title('Juxta Spike Count per Position per Lap');
xlabel('Position Bins (AU 0 - 100)') 
ylabel('Laps') 

hold on

subplot(2,1,2);

sumJxtSpk = sum(jxtSpkLapPosMat); % plots juxta spikes per position bin per session
JSC_Sum = imagesc(sumJxtSpk);
title('Juxta Spike Total Count per Position');
xlabel('Position Bins (AU 0 - 100)')
set(gcf,'Position', [100 100 540 100]);

hold off
%% graphing ISI

imagesc(aveISIs);
colorbar
title('Juxta Spike Count per Position per Lap');
xlabel('Position Bins (AU 0 - 100)') 
ylabel('Laps') 

% notes for 6_25_21
% ironcially, you need an inverse of the ISI to detect burstiness
% also, try making your outputs structs rather than new named vars

%% making the PlaceField plots

[extSpkLapPosMat] = EC_PlaceField(filtered_pos,binEdges,analogin.ts,spikes);

imagesc(extSpkLapPosMat);
colorbar
title('Si PlaceField');
xlabel('Position Bins (AU 0 - 100)') 
ylabel('Cells') 

[~,placeFieldSort] = max(extSpkLapPosMat,[],2);
[~,placeFieldSort] = sortrows(placeFieldSort);

imagesc(extSpkLapPosMat(placeFieldSort,:)) % plots the place field for the silicon probe data
colorbar
title('Si PlaceField');
xlabel('Position Bins (AU 0 - 100)') 
ylabel('Cells') 
% now, since the analog times are downsampled the spike times will be
% assigned to a corresponding analog time bin. best will be to keep it
% consistent and have (,] type bins. because each time has a corresponding
% position au, we can now tally how many spikes are in each position per
% lap.


% ultimately, you need to make a matrix that has all the numbers you want
% to project into a graph. That matrix is the graph in a real sense based
% on the way matlab creates the graphics. 

% for i = 1:length(lapEnd)
%     
% zz(i) = find(analogin_NoDs.ts == lapEnd(1,i));
% 
% end
[SpkVoltage, SpkTime, VelocityatSpk] = rastersToVoltage(analogin, spikes); % rasters over time

%%
% for this we need the analogin.pos ( = location in Voltage )
% we need our juxta times
% we need our matching cluster's EC times

% utilities/placemaps

% rastersToVoltage
% placeRastersoverVoltage

% % % % % % % 
% % % % % % % % Separate the wheel in trials
% % % % % % % [len_ep, ts_ep, vel_ep, tr_ep, len_ep_fast, ts_ep_fast, vel_ep_fast] = getWheelTrials(analogin);
% % % % % % % %%
% % % % % % %  cd(spike_path)
% % % % % % % spikes = bz_LoadPhy;
% % % % % % % 
% % % % % % % % % spkRateperBin % heatmaps
% % % % % % % 
% % % % % % % % % [SpkVoltage, SpkTime, VelocityatSpk] = rastersToVoltage(analogin, spikes) % rasters over time
% % % % % % % % % plotRasterstoVoltage % spks over Voltage, by time 
% % % % % % % 
 % % % % % % % plotRastersTrials % spks over Voltage, by trial


%% figure 2 

% % Get LFP 

lfp = bz_GetLFP(bestMatchChannel); 




% biovariables checking through scripts in
% englishneurolab/utilities/neuroscope


%% splitting the EC from the JC


CopyDat('D:\GroundTruth\m256_210621_122956\m256_210621_122956.dat','D:\GroundTruth\m256_210621_122956\ks2\m256_210621_122956_EC.dat','channelIx',2:1:33);
% channelStr = int2str(1:1:32);
% newStr = split( channelStr )
% for i = 1:32
%     tt(i,1) = newStr{i}(:);
% end
% fclose('D:\GroundTruth\m256_210621_122956\ks2\m256_210621_122956_NoJC.dat')

% writing down notes now so I don't forget. When this code was intially
% used, Lianne included a file that included RMSpikesID and SpkTimesAll.
% SpkTimesAll is just a collection of spike times in seconds and RMspikesID
% is a list (with the same lengh of SpkTimesAll) of either just 0 or just 1
% I beleive this corresponds to which spike group it is in (but for juxta
% data, they will all be in one file).

%% Create .clu and .res files for Hybrid Probe Data

iterDiff = setdiff(juxtaSpikes.ts{1},juxtaSpikes.tsReserve{1}); %normal vs iter
iterDiffCell{1} = iterDiff;

iterDiffRev = setdiff(juxtaSpikes.tsReserve{1}, juxtaSpikes.ts{1}); %iter vs normal
iterDiffRevCell{1} = iterDiffRev;

% EA_MakeClu(JuxtaSpikesTimes,basename,spikes);

% EA_MakeClu(juxtaSpikes.timesReserve{1},[basename , '_Iter'],spikes);

EA_MakeSingleCluster(basename,0,juxtaSpikes.ts,1);

nClu = bestCluster; %clu/res for best cluster
EA_MakeSingleCluster(basename,nClu,spikes.ts,nClu);

iterNum = spikes.numcells + 1; %clu/res for first iteration
EA_MakeSingleCluster(basename,iterNum,juxtaSpikes.allIters.ts,1);

finalIterNum = spikes.numcells + 2; %clu/res for final iteration
finalIterCell{1} = juxtaSpikes.finalIter.ts;
EA_MakeSingleCluster(basename,finalIterNum,finalIterCell,1);


% % % iterDiffNum = spikes.numcells + 2; %clu/res for spikes in 0th temp but not first iteration
% % % EA_MakeSingleCluster(basename,iterDiffNum,iterDiffCell,1);
% % % 
% % % iterDiffRevNum = spikes.numcells + 3; %clu/res for spikes in first iteration but not 0th temp
% % % EA_MakeSingleCluster(basename,iterDiffRevNum,iterDiffRevCell,1);



% fir1Num = spikes.numcells + 4;
% EA_MakeSingleCluster(basename,fir1Num,iterDiffRevCell,1);




