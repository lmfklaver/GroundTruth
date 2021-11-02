function [mergedJuxta] = EA_MergeJuxtaTimes(juxta1,juxta2,dupTimeInt)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

rangeSpkBin = dupTimeInt;
for iSpikeJuxta = 1:length(juxta2)
    
    selectedJuxtaSpike = juxta2(iSpikeJuxta);
    
    compareTimes = juxta1 - selectedJuxtaSpike;
    
    closestTimeInt = min(abs(compareTimes));
    closestInx1 = find(compareTimes == closestTimeInt);
    if closestTimeInt >= rangeSpkBin
        
        juxta1 = [juxta1 ; selectedJuxtaSpike];       
              
    end
    
    mergedJuxta = sort(juxta1);
end

end

