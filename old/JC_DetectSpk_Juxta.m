function [clu,res,spk] = JC_DetectSpk_Juxta(fbasename,channel,varargin)

% Make_SpkFromVm(fbasename,channel)
% extracts spike times from fbasename.dat where the Vm trace is given
% by the value 'channel'
% generates a res and a clu file (the clu will be used to segregate complex
% spikes)

% Adrien Peyrache, 2013

%Parameters:
templateMatch   = 0;
analogNCh       = 1;
stimCh          = 1;

fprintf('Running JC_DetectSpk_Juxta on %s\nreads Vm and Analogin files\nassumes 1 analog channel\n',fbasename)

%Number of samples before and after the peak
tIx = [-30:50];

% cluster identity
if ~isempty(varargin)
    cluId = varargin{1};
else
    cluId = 1;
end

syst = LoadXml(fbasename);
fs = syst.SampleRate;

Vm = LoadBinary([fbasename '.dat'],'frequency',fs,'nchannels',syst.nChannels,'channels',channel);
Stim = LoadBinary([fbasename '_analogin.dat'],'frequency',fs,'nchannels',analogNCh,'channels',stimCh);

%%%%%%%%%%%%%%%%%%%
% Load Evt file
%%%%%%%%%%%%%%%%%%%

[st,en] = LoadEvtFile([fbasename '.evt.bas']);
ixBas = round([st*fs:en*fs]');
if ixBas(1)==0
    ixBas(1) = 1;
end
%[st,en] = LoadEvtFile([fbasename '.evt.stm']);
%ix = [ixBas;round((st*fs:en*fs)')];

% 0 out of ROI
ix0 = ~ismember(ix,[1:length(Vm)]);
Vm(ix0) = 0;

% 'broad' high pass filtering
[b,a] = fir1(256,100/10000,'high');
Vmf = filtfilt(b,a,double(Vm));

%Define the threshold
threshold = 15*std(Vmf(ixBas));
sIx = LocalMinima(-Vmf,30,-threshold);

%Remove events too early or too late in the recording
sIx(sIx<20) = [];
sIx(sIx>length(Vmf)-40) = [];

%Select all spk from raw trace
sIxAll = repmat(tIx,[length(sIx) 1])+repmat(sIx(:),[1 length(tIx)]);
spk = Vm(sIxAll);
mSpk = mean(spk);

%Here we validate the detection with a simple template matching
if templateMatch
    C = zscore(double(mSpk))*zscore(double(spk)')/length(tIx);
    badIx = find(C<0.70);
    spk(badIx,:) = [];
    sIx(badIx) = [];
end

res = sIx;

%And we write the final result
spk = single(spk)';

fid0 = fopen([fbasename '.spk.100'],'w');
fwrite(fid0,spk(:),'int16');
fclose(fid0);

fid0 = fopen([fbasename '.res.100'],'w');
fprintf(fid0,'%i\n',res);
fclose(fid0);

clu = cluId*ones(length(sIx),1);
fid0 = fopen([fbasename '.clu.100'],'w');
fprintf(fid0,'%i\n',[1;clu]);
fclose(fid0);