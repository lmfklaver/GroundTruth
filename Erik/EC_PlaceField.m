function [extSpkLapPosMat] = EC_PlaceField(filtered_pos,binEdges,analoginTimes,spikes)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


pos = filtered_pos;
analoginTimes = analoginTimes;
binEdges = binEdges;
spikes = spikes;

extSpkLapPosMat = zeros(spikes.numcells,100);

for i = 1:spikes.numcells
    

currExtraTimes = spikes.times{i};
    
binnedExtraTimes = discretize(currExtraTimes,analoginTimes,'IncludedEdge','right');
binnedExtraTimes_missRem = rmmissing(binnedExtraTimes);
binnedExtraPos = filtered_pos(binnedExtraTimes_missRem);

numericExtraPos = discretize(binnedExtraPos,binEdges,'IncludedEdge','right');

extSpkPosCell{i} = numericExtraPos;

[posCounts,posNumerVals] = groupcounts(extSpkPosCell{i}');

extSpkLapPosMat(i,posNumerVals') = posCounts';


end

% Games being played. So it may be the case that the anlogin recording is
% shorter than the hybrid probe recording. That actually makes sense ngl. 

end

