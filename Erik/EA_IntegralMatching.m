function [spkInts] = EA_IntegralMatching(spk)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

zspk = zscore(double(spk),0,2);

spkInts = trapz(zspk,2);
histogram(spkInts);

% for i = 1:5
% plot(zspk(i,:))
% hold on
% end
% legend
% hold off
% 
% g = figure
% for i = 1:20
% plot(spk(i,:))
% hold on
% end
% legend

end

