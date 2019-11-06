function [juxtaSpikes] = DetectJuxtaSpikes(data, sessionID, ops)

templateMatch = ops.templateMatch;
sampFreq = data.samplingRate;

dJuxtadata = double(data.data);

if strcmpi(ops.filter, 'butterworth')
    %  filter 1: butterworth
    buttOrder = ops.buttorder;
    hpFreq = ops.hpfreq; % Cut off frequency
    [b,a] = butter(buttOrder,hpFreq/(sampFreq/2),'high'); % Butterworth filter of order 
    filtJuxta = zscore(filter(b,a,dJuxtadata)); % Will be the filtered signal
end

if strcmpi(ops.filter, 'highpass')
    % filter 2: built-in highpass
    filtJuxta = highpass(dJuxtadata,hpFreq,sampFreq);
end

if strcmpi(ops.filter, 'fir1')
    % filter 3: filtfilt
    firOrder = ops.firorder;
    hpFreq = ops.hpfreq;
    [b,a] = fir1(firOrder,hpFreq/(sampFreq/2),'high');
    filtJuxta = zscore(filtfilt(b,a,dJuxtadata));
end

% Pieces of adriens code
tIx = ops.spikeSamps;

% %Define the threshold
SNRthr = ops.SNRthr(1);
jSpkThr = SNRthr * std(filtJuxta);

% Avoid multiple detection of same spike
sIx = LocalMinima(-filtJuxta, .1, -jSpkThr); % TSToolbox

% % %Remove events too early or too late in the recording
sIx(sIx<20) = [];
sIx(sIx>length(filtJuxta)-40) = [];

juxtaSpikes.filtJuxta = filtJuxta;
juxtaSpikes.times = {data.times(sIx)}; %cell array of timestamps (seconds) for each neuron
juxtaSpikes.ts = {data.times(sIx)*sampFreq};

% %Select all spk from raw trace
sIxAll = repmat(tIx,[length(sIx) 1])+repmat(sIx(:),[1 length(tIx)]);
juxtaSpikes.spk = dJuxtadata(sIxAll);
juxtaSpikes.rawWaveform = {mean(juxtaSpikes.spk)};


% add ncessary fields for spike struct comptible with buzcode
juxtaSpikes.UID     = [0]; %unique identifier for each neuron in a recording
juxtaSpikes.shankID = [10]; % shank ID that each neuron was recorded on
juxtaSpikes.maxWaveFormCh = [1]; % channel # with largest amplitude spike for each neuron
juxtaSpikes.region = {''};
juxtaSpikes.numcells = length(juxtaSpikes.UID); %number of cells/UIDs

%juxtaSpikes.sessionName    %-name of recording file
%juxtaSpikes.spindices      %-sorted vector of [spiketime UID], useful for input to some functions and plotting rasters
%juxtaSpikes.cluID          %-cluster ID, NOT UNIQUE ACROSS SHANKS

if templateMatch
    C = zscore(double(juxtaSpikes.rawWaveform{1}))*zscore(double(juxtaSpikes.spk)')/length(tIx);
    badIx = find(C<0.8); % used to be .7
    juxtaSpikes.spk(badIx,:) = [];
    juxtaSpikes.ts{1}(badIx,:) = [];
    juxtaSpikes.times{1}(badIx,:) = [];
    sIx(badIx) = [];
end

juxtaSpikes.sIx=sIx;

if ops.doPlots
    
    figure, plot(data.times*30000,filtJuxta), hold on,
    plot(data.times*30000,repmat(jSpkThr,1,length(data.times)),'m'),
    plot(sIx,repmat(10,1,length(sIx)),'*')
    title([sessionID],'Interpreter', 'none')
    
    
    [~, SCORE, ~] = pca(juxtaSpikes.spk);
    figure,plot(SCORE(:,1),SCORE(:,2),'.')
end

end
