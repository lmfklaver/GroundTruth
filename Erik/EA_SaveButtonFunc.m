function EA_SaveButtonFunc(pop)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fig_PointClick      = pop.fig;
jSpkTimes           = pop.jSpkTimes;
basename            = pop.basename;
txa1                = pop.txa1;
   
addedJuxtas     = getappdata(fig_PointClick,'addedJuxtas');
removedJuxtas   = getappdata(fig_PointClick,'removedJuxtas');

[~,removeIdx] = intersect(jSpkTimes,removedJuxtas'); % check to see if the precision is too high
jSpkTimes(removeIdx) = [];
jSpkTimes = [jSpkTimes ; addedJuxtas'];
jSpkTimes = sort(jSpkTimes);
jSpkTimes = unique(jSpkTimes);

dateStr = datestr(now,'mm_dd_yyyy');
timeStr = datestr(now,'.HH.MM.SS.AM');
timeStr = timeStr(find(~isspace(timeStr)));

dtStr = [dateStr timeStr];
pathway = pop.pathway; 


save([pathway '\' basename '.jSpkTimes_' dtStr '.mat'],'jSpkTimes'); % need to fix this
% save(['D:\GroundTruth\' basename '\' basename '.jSpkTimes_' dtStr '.mat'],'jSpkTimes'); % need to fix this

txa1.Value = ['Saved ' pathway '.jSpkTimes_' dtStr '.mat'];

end

