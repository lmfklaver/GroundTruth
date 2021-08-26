function EA_SaveButtonFunc(pop)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

fig_PointClick      = pop.fig;
jSpkTimes           = pop.jSpkTimes;
basename            = pop.basename;

addedJuxtas     = getappdata(fig_PointClick,'addedJuxtas');
removedJuxtas   = getappdata(fig_PointClick,'removedJuxtas');

[~,removeIdx] = intersect(jSpkTimes,removedJuxtas'); % check to see if the precision is too high
jSpkTimes(removeIdx) = [];
jSpkTimes = [jSpkTimes ; addedJuxtas'];
jSpkTimes = sort(jSpkTimes);
jSpkTimes = unique(jSpkTimes);

save(['D:\GroundTruth\' basename '\' basename '.jSpkTimes.mat'],'jSpkTimes'); % need to fix this

end

