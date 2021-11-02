function [juxtaSpikes] = GetJuxtaSpikes(basepath,varargin)
% This function gets the juxtaSpikes out through loading in the juxtadata
% from the .dat file and subsequently
%
%   USAGE
%   [juxtaSpikes] = GetJuxtaSpikes(basepath,<options>)
%   Dependencies:
%   buzcode
%
%   INPUTS
%   basepath        - path in which basename.dat is located
%
%   Name-value paired inputs:
%   'basename'      - if not the same as basepath (default:
%                      bz_BasenameFromBasepath)
%   'intervals'     - time in sec to include (default: [0 Inf])
%   'juxtachan'     - 0-based Neuroscope channel for juxta (default: 0)
%   'dsfactor'      - if you want to downsample (default: 1);
%   'templateMatch' - true or false (default:true);
%   'filter'        - what filter to use 'butterworth','fir1','highpass'
%                     (default: 'butterworth')
%   'hpfreq'        - hpfreq for filtering juxtadata (default: 1000);
%   'forceOverwrite' - default:false. Overwrites previously generated
%                      matfiles, use with caution
%
%   OUTPUTS
%   juxtaSpikes     - struct
%   .filtJuxta
%   .times
%   .ts
%   .spk
%   .rawWaveform
%   .UID            %unique identifier for each neuron in a recording
%   .shankID        % shank ID that each neuron was recorded on
%   .maxWaveformCh % 0-based channel for Juxta
%   .region 
%   .numcells       %0 of cells with UID
%   .sIx
%
%   EXAMPLES
%   [juxtaSpikes] = GetJuxtaSpikes(basepath, 'intervals', intervals,'juxtachan',0, ...
%             'templateMatch',true,'filter','butterworth','saveMat',true);
%   juxtaSpikes = GetJuxtaSpikes(juxtadata, 'templateMatch',templateMatch,'filter',...
%     hpfilter,'hpfreq',hpFreq,'tempmatchThr',0.8, 'SNRThr',7,'saveMat',true);
%   NOTES
%
%
%   TO-DO
%   - Figure out yes or no template match
%   - Make a dynamic SNR threshold perhaps by normalizing each trace. Right
%   now it needs to be adjusted per cell.
%   - Optimize template match exclusion threshold.
%   - Perhaps phagocytose getJuxtaData into this function, because without
%   data, there are no spikes.
%   - Figure out if we want manual rejection with rejectDetectedSpikes
%
%   HISTORY
%   2019    Originally written by Lianne
%   2021/06     Lianne commented this for Erik + removed params and ops,
%               for consistency moved assigning variables to struct to the bottom, and
%               made the maxWaveFormCh 0based. Merged DetectJuxtaSpikes
%               into this functionn

%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'intervals',[0 Inf],@isnumeric);
addParameter(p,'juxtachan',0,@isnumeric);
addParameter(p,'dsfactor',1,@isnumeric);
addParameter(p,'templateMatch',true, @islogical);
addParameter(p,'filter','butterworth',@isstr);
addParameter(p,'hpfreq',1000,@isnumeric);
addParameter(p,'tempmatchThr',0.8,@isnumeric);
addParameter(p,'SNRThr',7,@isnumeric);% was 7 7/27/21
addParameter(p,'forceOverwrite',false,@islogical);
addParameter(p,'numIters',0,@isnumeric);

parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
intervals       = p.Results.intervals;
juxtachan       = p.Results.juxtachan;
downsampfactor  = p.Results.dsfactor;
templateMatch   = p.Results.templateMatch;
hpfilter        = p.Results.filter;
hpFreq          = p.Results.hpfreq;
forceOverwrite  = p.Results.forceOverwrite;
tempmatchtThr   = p.Results.tempmatchThr;
SNRThr          = p.Results.SNRThr;
numIters        = p.Results.numIters;

cd(basepath)
disp(['SNRThr is: ', num2str(SNRThr)]);
disp(['numIters is: ', num2str(numIters)]);
%% Check this:
% These are now hardcoded, unsure if we need to do something with that
buttOrder = 1;
firOrder = 256;

%% Load in data juxta
% consider removing force overwrite from this section since we want to
% overwrite the spike times but not re-read the raw data each time
if ~exist([basename '.juxtadata.mat'],'file') %forceOverwrite || 
    juxtadata = getJuxtaData(basepath,'intervals',intervals,'juxtachan',...
        juxtachan, 'dsfactor',downsampfactor,'saveMat',true);
elseif exist([basename '.juxtadata.mat'],'file')
    load([basename '.juxtadata.mat'],'juxtadata');
end

% Unpack necessary variables:
sampFreq    = juxtadata.samplingRate;
dJuxtadata  = double(juxtadata.data);


%% Filter

% Filter the juxtadata trace, to be able to detect spikes
if strcmpi(hpfilter, 'butterworth')
    %  filter 1: butterworth
    [b,a] = butter(buttOrder,hpFreq/(sampFreq/2),'high'); % Butterworth filter of order
    filtJuxta = zscore(filter(b,a,dJuxtadata)); % Will be the filtered signal
    
elseif strcmpi(hpfilter, 'highpass')
    % filter 2: built-in highpass
    filtJuxta = highpass(dJuxtadata,hpFreq,sampFreq);
    
elseif strcmpi(hpfilter, 'fir1')
    % filter 3: filtfilt
    [b,a] = fir1(firOrder,hpFreq/(sampFreq/2),'high');
    filtJuxta = zscore(filtfilt(b,a,dJuxtadata));
end

% yy = snr(juxtadata.times,filtJuxta);

%% diagnostic section to check out the difference between the filters
compareFilters = 0; %keeping this one for now
if compareFilters
filCompInt = [0, 1000000];
EA_JuxtaFilterCompare(dJuxtadata,sampFreq,hpFreq,firOrder,buttOrder,filCompInt)
end

%% Determine threshold crossings

% This part of the function consists of bits and pieces of Adriens code and
% is determining thresholds used to detect the spikes from the filtered
% signal.

% Choose amount of samples around threshold crossing to pull spike waveform
% from
tIx = -40:55; % hardcoded now, i don't think this needs to be changed
% tIx = -5:10;

% Define a threshold (NEEDS WORK)
SNRthrFactor = SNRThr; % figure this one out per cell
jSpkThr = SNRthrFactor * std(filtJuxta);

% Avoid multiple detection of same spike
sIx = LocalMinima(-filtJuxta, .1, -jSpkThr); % TSToolbox
% you are actually getting the local minimum of the negative signal which
% is like the same as the local max. same with std

% % %Remove events too early or too late in the recording
sIx(sIx<20) = [];
sIx(sIx>length(filtJuxta)-40) = [];

times   = {juxtadata.times(sIx)}; %cell array of timestamps (seconds) for each neuron;
ts      = {juxtadata.times(sIx)*sampFreq};
timesReserve = times;
tsReserve = ts;
sIxReserve = sIx;
% Select all spk from raw trace
sIxAll = repmat(tIx,[length(sIx) 1])+repmat(sIx(:),[1 length(tIx)]);
spk = dJuxtadata(sIxAll); %*** the raw data gets fed into the template matcher.
% also, raw data creates the template
spkReserve = spk;


rawWaveform = {mean(spk)};

%% creating a function determines threshold crossings using fir  
[fir1FiltJuxta] = EA_FilterJuxta('fir1',dJuxtadata,sampFreq,hpFreq,firOrder,buttOrder);
[fir1times,fir1ts,fir1sIx] = EA_Thresholding_Fir1(fir1FiltJuxta,tIx,SNRThr,juxtadata,sampFreq);
fir1sIxAll = repmat(tIx,[length(fir1sIx) 1])+repmat(fir1sIx(:),[1 length(tIx)]);
fir1spk = filtJuxta(fir1sIxAll); % remember that the butterworth is what ultimately gets fed into the template matcher
% all the spike window indices get fed into filtJuxta which comes from
% butter worth (or whatever the user chooses)

fir1RawWaveform = {mean(fir1spk)};
%% Integral Matching section

% [spkInts] = EA_IntegralMatching(spk); %turned off for now 8/3/21

%% Template Matching section
normalTemplateMatching = 1;
if normalTemplateMatching
    
    if templateMatch
        C = zscore(double(rawWaveform{1}))*zscore(double(spk)')/length(tIx);        
        badIx = find(C<tempmatchtThr); %
        spk(badIx,:) = [];
        ts{1}(badIx,:) = [];
        times{1}(badIx,:) = [];
        sIx(badIx) = [];
    end
    
end
%% Template Matching Pre-Filtered Differently

% ideally we use an Fir filter to sharpen spikes, run that through the
% template matcher 

fir1AltTemp = 0;
if fir1AltTemp == 1
%     fir1times
    
    
%     times = fir1times;
%     ts = fir1ts;
%     rawWaveform = fir1RawWaveform;

    if templateMatch
        fir1C = zscore(double(fir1RawWaveform{1}))*zscore(double(fir1spk)')/length(tIx);
        badIx = find(fir1C<tempmatchtThr); 
        fir1spk(badIx,:) = [];
        fir1ts{1}(badIx,:) = [];
        fir1times{1}(badIx,:) = [];
        fir1sIx(badIx) = [];
    end
%     sIx = fir1sIx;
%     spk = fir1spk;
end
% figure out some issue with this, apparlently line 216 is throwing errors
% it's probably a naming convention thing with fir

%% Template Matching Multiple Iterations
%%%****&&&
% Here, we only keep the post template match spikes
% those spikes then get fed back into template matcher
% now theoretically, junk spikes won't get incorporated 
% to keep things simple, we are ingnoring the fir1-indices

% we will start off with spk post primary template matching
% now that we have fewer spikes, we can recreate the template (rawWaveform2)
% and scan the original spk group (spkReserve) while keeping the same
% thresholds

storeAllIters = 1;

if numIters >= 1
    templateIter = 1;
elseif numIters < 1
    templateIter = 0;
    storeAllIters = 0;
end



if templateIter == 1    
    
    spkNew = spk; %to start off the loop, we take the output from the 1st template match   
    
    for i = 1:numIters
%         i = 2
        rawWaveformN{i} = mean(spkNew); %we then calculate the new template
        spkHolder   = spkReserve; % these are dummy variables which hold the original pre-template voltages and times
        tsHolder    = tsReserve;
        timesHolder = timesReserve;
        sIxHolder   = sIxReserve;
        
        if templateMatch
            C = zscore(double(rawWaveformN{i}))*zscore(double(spkHolder)')/length(tIx); %templating with the new template
            badIx = find(C<tempmatchtThr);
            spkHolder(badIx,:) = []; % each time the original data is rescanned with the new template to avoid recollecting spikes each time
            tsHolder{1}(badIx,:) = [];
            timesHolder{1}(badIx,:) = [];
            sIxHolder(badIx) = [];
        end
        
        if storeAllIters == 1 && i < numIters  % if you want the data from each iteration to be stored
            
            allIters.ts{i} = tsHolder{1};
            allIters.times{i} = timesHolder{1};
            allIters.sIx{i} = sIxHolder;
        elseif i == numIters
            
            finalIter.ts = tsHolder{1};
            finalIter.times = timesHolder{1};
            finalIter.sIx = sIxHolder;
        end
        spkNew = spkHolder;
        
    end
    
%      spkReserve(badIx,:) = [];
%         tsReserve{1}(badIx,:) = [];
%         timesReserve{1}(badIx,:) = [];
%         sIxReserve(badIx) = [];
    
    
end

%% Make struct
% add necessary fields for spike struct for it to be comptible with buzcode

juxtaSpikes.filtJuxta   = filtJuxta;
juxtaSpikes.times       = times;
juxtaSpikes.ts          = ts;
juxtaSpikes.spk         = spk;
juxtaSpikes.rawWaveform = rawWaveform;
juxtaSpikes.UID         = 0; %unique identifier for each neuron in a recording
juxtaSpikes.shankID     = 10; % shank ID that each neuron was recorded on
juxtaSpikes.maxWaveFormCh = 0 ; % 0-based channel for Juxta
juxtaSpikes.region      = {''};
juxtaSpikes.numcells    = length(juxtaSpikes.UID); %number of cells/UIDs
juxtaSpikes.sIx         = sIx;

juxtaSpikes.fir1times   = fir1times;
juxtaSpikes.fir1ts      = fir1ts;
juxtaSpikes.fir1RawWaveform = fir1RawWaveform;
juxtaSpikes.fir1sIx     = fir1sIx;
juxtaSpikes.fir1spk     = fir1spk;

juxtaSpikes.spkReserve  = spkReserve;
juxtaSpikes.tsReserve   = tsReserve;
juxtaSpikes.timesReserve= timesReserve;
juxtaSpikes.sIxReserve  = sIxReserve;

if storeAllIters == 1
    if numIters >= 2
juxtaSpikes.allIters    = allIters;
    end
juxtaSpikes.finalIter   = finalIter;
end
%% Plot
% % This can probably go

% if doPlots
%
%     figure, plot(juxtadata.times*30000,filtJuxta), hold on,
%     plot(juxtadata.times*30000,repmat(jSpkThr,1,length(juxtadata.times)),'m'),
%     plot(sIx,repmat(10,1,length(sIx)),'*')
%     title([sessionID],'Interpreter', 'none')
%
%
%     [~, SCORE, ~] = pca(juxtaSpikes.spk);
%     figure,plot(SCORE(:,1),SCORE(:,2),'.')
% end

%% Save
if saveMat
    if forceOverwrite || ~exist([basename '.juxtaSpikes.mat'],'file')
                
        save([basename, '.juxtaSpikes.mat'], 'juxtaSpikes')
    end
    
elseif exist([basename '.juxtaSpikes.mat'],'file')
    warning('This file already exists and forceOverwrite=false, juxtaSpikes output is not saved to matfile!')
end

end


