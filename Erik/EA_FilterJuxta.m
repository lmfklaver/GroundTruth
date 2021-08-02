function [filtJuxta] = EA_FilterJuxta(filterSelectStr,dJuxtadata,sampFreq,hpFreq,firOrder,buttOrder)
%UNTITLED5 Summary of this function goes here
% Filter the juxtadata trace, to be able to detect spikes
if strcmpi(filterSelectStr, 'butterworth')
    %  filter 1: butterworth
    [b,a] = butter(buttOrder,hpFreq/(sampFreq/2),'high'); % Butterworth filter of order
    filtJuxta = zscore(filter(b,a,dJuxtadata)); % Will be the filtered signal
    
elseif strcmpi(filterSelectStr, 'highpass')
    % filter 2: built-in highpass
    filtJuxta = highpass(dJuxtadata,hpFreq,sampFreq);
    
elseif strcmpi(filterSelectStr, 'fir1')
    % filter 3: filtfilt
    [b,a] = fir1(firOrder,hpFreq/(sampFreq/2),'high');
    filtJuxta = zscore(filtfilt(b,a,dJuxtadata));
end
end

