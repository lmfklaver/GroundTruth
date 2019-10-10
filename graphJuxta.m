function graphJuxta (timeRange, titleOfArea)
%Graph raw data from Juxta Recording
%
%Written by Reagan Bullins 7/19/19
%
%Dependencies
%lfp files for each cell
% buz code
%
lfpJuxta = bz_GetLFP(1);
JuxtaXTemp = lfpJuxta.timestamps(timeRange);
JuxtaX = downsample(JuxtaXTemp, 24);
JuxtaYTemp = lfpJuxta.data(timeRange);
JuxtaY = downsample(JuxtaYTemp, 24);
colormat = [
    16, 193, 53;...
    64, 79, 36;...
    209, 156, 76;...
    157, 95, 56;...
    78,97,114;...
    131,146,159;...
    219,202,105;...
    213 117 0; ...
    133,87,35;...
    189,208, 156;...
    158,156,107]/255;

graphJuxta = plot(JuxtaX,JuxtaY);
%[filepath,name,ext] = fileparts(cd);
title([titleOfArea ' ' 'Raw Data Juxtacellular']); 
xlabel('Time (seconds)');
ylabel('mV');
ylim('manual');
set(gca, 'YLim',[-5000  5000]);
set(gca, 'YTick', [-5000 -2500 0 2500 5000]);
pbaspect([4 1 1]);
set(gca, 'TickDir', 'out');
box off
graphJuxta
end