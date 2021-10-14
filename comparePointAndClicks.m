% Find ambiguous juxta spikes 

load('m15_190315_145422.jSpkTimes_10_08_2021.11.30.34.AM_LK.mat')
LK_jSpkTimes = jSpkTimes;
load('m15_190315_145422.jSpkTimes_10_09_2021.8.38.14.PM_EA.mat')
EA_jSpkTimes = jSpkTimes;
load('m15_190315_145422.juxtaSpikes.mat')
OG_jSpkTimes = juxtaSpikes.times{1};

% find overlapping timestamps or unique timestamps but within the
% wiggle-room of a spike, becuase:
% OG_jSpkTimes(1:4)
% 
% ans =
% 
%     0.1472
%     0.1510
%     0.1538
%     0.1582
%     0.1639
% 
% LK_jSpkTimes(1:5)
% 
% ans =
% 
%     0.1473
%     0.1511
%     0.1539
%     0.1583
%     0.1640
% 
% 
% EA_jSpkTimes(1:5)
% 
% ans =
% 
%     0.1388
%     0.1473
%     0.1511
%     0.1539
%     0.1583
