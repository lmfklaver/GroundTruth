function [times,ts,sIx] = EA_Thresholding_Fir1(fir1FiltJuxta,timeIndex,SNRThr,juxtadata,sampFreq)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

filtJuxta = fir1FiltJuxta;
tIx = timeIndex; % hardcoded now, i don't think this needs to be changed

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


end

