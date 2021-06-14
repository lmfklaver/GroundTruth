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
addParameter(p,'templateMatch',true @islogical);
addParameter(p,'filter','butterworth',@isstr);
addParameter(p,'hpfreq',1000,@isnumeric);
addParameter(p,'tempmatchThr',0.8,@isnumeric);
addParameter(p,'SNRThr',7,@isnumeric);
addParameter(p,'forceOverwrite',false,@islogical);

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


cd(basepath)

%% Check this:
% These are now hardcoded, unsure if we need to do something with that
buttOrder = 1;
firOrder = 256;

%% Load in data juxta

if forceOverwrite || ~exist([basename '.juxtadata.mat'],'file')
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


%% Determine threshold crossings

% This part of the function consists of bits and pieces of Adriens code and
% is determining thresholds used to detect the spikes from the filtered
% signal.

% Choose amount of samples around threshold crossing to pull spike waveform
% from
tIx = -40:55; % hardcoded now, i don't think this needs to be changed

% Define a threshold (NEEDS WORK)
SNRthrFactor = SNRThr; % figure this one out per cell
jSpkThr = SNRthrFactor * std(filtJuxta);

% Avoid multiple detection of same spike
sIx = LocalMinima(-filtJuxta, .1, -jSpkThr); % TSToolbox

% % %Remove events too early or too late in the recording
sIx(sIx<20) = [];
sIx(sIx>length(filtJuxta)-40) = [];

times   = {juxtadata.times(sIx)}; %cell array of timestamps (seconds) for each neuron;
ts      = {juxtadata.times(sIx)*sampFreq};


% Select all spk from raw trace
sIxAll = repmat(tIx,[length(sIx) 1])+repmat(sIx(:),[1 length(tIx)]);
spk = dJuxtadata(sIxAll);

rawWaveform = {mean(spk)};
%% Template Matching section

if templateMatch
    C = zscore(double(rawWaveform{1}))*zscore(double(spk)')/length(tIx);
    badIx = find(C<tempmatchtThr); %
    spk(badIx,:) = [];
    ts{1}(badIx,:) = [];
    times{1}(badIx,:) = [];
    sIx(badIx) = [];
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
juxtaSpikes.sIx         =sIx;


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


