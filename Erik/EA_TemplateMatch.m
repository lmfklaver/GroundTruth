function [C] = EA_TemplateMatch(rawWaveform,spk,tIx)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

% C = zscore(double(rawWaveform{1}))*zscore(double(spk)')/length(tIx);

obs = zscore(double(spk),0,2);

exp = zscore(double(rawWaveform{1}));

numerator = obs - exp;

tempDiff = abs(numerator ./ exp);

tempDiffFin = 1 - tempDiff;

tempVal = mean(tempDiffFin,2);

C = tempVal';

GG = find(C >= 0.4)

end

