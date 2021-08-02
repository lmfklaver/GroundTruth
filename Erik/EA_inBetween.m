function [midPoints] = EA_inBetween(Value)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

thisValue = Value;

for i = 1:(length(thisValue)-1)
    
    midPoints(1,i) = (thisValue(i) + thisValue(i+1))/2;
    
end

if isempty(i)
midPoints = [];
else
% midPoints = mids;

end

