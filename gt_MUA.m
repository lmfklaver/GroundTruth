SetCurrentSession(basepath,basename) % creates GLOBAL variable DATA (see contents with 'global DATA'), can be called for in a function. 
GetMUAfilterLFP

extradata = bz_LoadBinary('1_190315_152315.dat', 'channels',2:33,'frequency', 30000,'nChannels',33); % Juxta is always the first channel in the .dat file.


hp_butter           = 500;  %Low pass filter (Hz) (Butter)
ord_butter          = 4;    %Butterworth filter order

[B_butt,A_butt]     = butter(ord_butter,hp_butter/(Fs/2),'high');
%%
nthresholds = 4;

lfpData.ts = lfp.timestamps;
for iCh = 1:5 %Ch 1 is the juxta recording
    
    lfpData.hpsignal(:,iCh)    = filtfilt(B_butt,A_butt,double(lfp.data(:,iCh)));
    idx                 = find(abs(lfpData.hpsignal(:,iCh))>nthresholds*std(lfpData.hpsignal(1:1000,iCh))); % correct for artifacts, now only used the first 1000 datapoints.

    idx                 = idx(diff(idx)~=1);
 
    selSignal = lfpData.hpsignal(:,iCh);
    plot(lfpData.ts, abs(lfpData.hpsignal(:,iCh))) % plots "raw" mua-filtered data (now 500-1250 Hz, maybe need higher Hz?).

    %From here on the outputs are not what I want them to be, so there's probably a mistake in the code here.
    params.binsize      = 0.05;
    params.conv_twin    = 0.01; % convolution time window
    params.conv_sigma   = 0.1e6;        %sd of gaussian window for smoothing
    
    edges               = lfpData.ts(1):params.binsize:lfpData.ts(end); % define edges of bins to calculate histogram over
    hist_mat            = histc(selSignal(idx),edges) * 1e6/params.binsize; % calculate count of mua within each bin
    figure;
    plot(edges,hist_mat,'k')

    %%
    N                   = params.conv_twin/params.binsize;
    alpha               = ((N-1)/(params.conv_sigma/params.binsize))/2; %? = (N ? 1)/(2?)
    win                 = gausswin(N,alpha); %convolution with gaussian
    win                 = win/sum(win); %normalized
    
%Smooth either the total or the individual trials: %% This is not working yet: Select one? Check this.
    
    hist_mat            = padarray(hist_mat,[0 round(length(win)/2)],'symmetric','both'); %pad the array on both sides for convolution
    hist_mat            = conv(hist_mat,win,'valid'); %Take only the valid overlapping center of convolution
    hist_mat            = hist_mat(1:length(edges)); %slight correction to get same size (edge vs convolution)
    
    %%
    figure;
    plot(edges,hist_mat,'k')
    %%
end
%%
