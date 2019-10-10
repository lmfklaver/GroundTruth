function [juxtaSpikes] = GetJuxtaSpikes(data, ops)

templateMatch = 1;
sampfreq = data.samplingRate;

% Trying different filters
%  filter 1: butterworth
buttOrder = 1;
hpFreq = 450; % Cut off frequency
[b,a] = butter(buttOrder,hpFreq/(sampfreq/2),'high'); % Butterworth filter of order 6
filtJuxta = filter(b,a,data.data); % Will be the filtered signal

% filter 2: built-in highpass
% filtJuxta = highpass(double(data),hpFreq,sampFreq);

% % filter 3: filtfilt
% [b,a] = fir1(256,450/15000,'high');
% filtJuxta = filtfilt(b,a,double(data));

% Pieces of adriens code
tIx = [-40:60];

%
SNRthr = ops.SNRthr;
jSpkThr = SNRthr * std(filtJuxta);

%Select all spk from raw trace
sIx = LocalMinima(-data.data, 30, -jSpkThr);

%findSpk = find(filtJuxta>(jSpkThr));

juxtaSpikes.sIx = sIx; %(voormalig findSpk)
juxtaSpikes.filtJuxta = filtJuxta;
juxtaSpikes.timestamps = data.timestamps(sIx);

% %Define the threshold
% threshold = 15*std(Vmf(ixBas));
% sIx = LocalMinima(-Vmf,30,-threshold); % Adriens Toolbox

% %Remove events too early or too late in the recording
% sIx(sIx<20) = [];
% sIx(sIx>length(Vmf)-40) = [];

sIxAll = repmat(tIx,[length(sIx) 1])+repmat(sIx(:),[1 length(tIx)]);
dJuxtadata = double(data.data);
juxtaSpikes.spk = dJuxtadata(sIxAll);
juxtaSpikes.mSpk = mean(juxtaSpikes.spk);

if templateMatch
    C = zscore(double(juxtaSpikes.mSpk))*zscore(double(juxtaSpikes.spk)')/length(tIx);
    badIx = find(C<0.70);
    juxtaSpikes.spk(badIx,:) = [];
    sIx(badIx) = [];
    
    sIxAll = repmat(tIx,[length(sIx) 1])+repmat(sIx(:),[1 length(tIx)]);
    dJuxtadata = double(data.data);
    juxtaSpikes.spk = dJuxtadata(sIxAll);
    juxtaSpikes.mSpk = mean(juxtaSpikes.spk);
end

figure, plot(filtJuxta), hold on, plot(sIx,repmat(8000,1,length(sIx)),'*')

end


% %
% %
% % %% to implement:
% % % ixBas =  % determine baseline indices
% % threshold = 15*std(filtJuxta(ixBas));
% % sIx = LocalMinima(-filtJuxta,30,-threshold);
% %
% % %Remove events too early or too late in the recording
% % sIx(sIx<20) = [];
% % sIx(sIx>length(Vmf)-40) = [];

% % % % Based on Adrien's JC_DetectSpk_Juxta
% % %Here we validate the detection with a simple template matching
% % if templateMatch
% %     C = zscore(double(mSpk))*zscore(double(spk)')/length(tIx);
% %     badIx = find(C<0.70);
% %     spk(badIx,:) = [];
% %     sIx(badIx) = [];
% % end
% %
% % res = sIx;
% %
% % %And we write the final result
% % spk = single(spk)';
% %
% % fid0 = fopen([fbasename '.spk.100'],'w');
% % fwrite(fid0,spk(:),'int16');
% % fclose(fid0);
% %
% % fid0 = fopen([fbasename '.res.100'],'w');
% % fprintf(fid0,'%i\n',res);
% % fclose(fid0);
% % %
% % % clu = cluId*ones(length(sIx),1);
% % % fid0 = fopen([fbasename '.clu.100'],'w');
% % % fprintf(fid0,'%i\n',[1;clu]);
% % % fclose(fid0);

