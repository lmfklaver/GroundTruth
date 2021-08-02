function [aveISIs] = EA_aveISI_ByPos(ISIs,numericISI_Pos)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

uniqVals = unique(numericISI_Pos);

aveISIs = zeros(1,100);

for i = 1:length(uniqVals)
    
    currVal = uniqVals(i);
    
    currINX = find(numericISI_Pos == currVal);
    
    currISIs = ISIs(currINX);
    
    aveISIs(1,currVal) = mean(currISIs);
    
end



end

