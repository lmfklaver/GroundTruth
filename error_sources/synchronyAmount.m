function synchronyAmount(probe)

% How much synchrony (e.g. power in spike freq / mua) % Can be done without
% manual sorting
file = pwd;
[filepath, name] = fileparts(file);
%name will equal the folder and cell number of the folder you are in
fnameIn = [name '.lfp']
%find power in spike frequency
%find duration of spiking
if ~isempty(dir([name '.lfp']))
    lfpAll = bz_GetLFP('all');
    timePeriod = lfpAll.duration
else
    error('There is not a lfp file in this folder')
end
%find the amplitude of response (mua filtering?)
      %insert extract MUA code here when it is working :) 

%amplitude of response divided by time duration of spiking = power


('Kachow! Synchrony amount found :)');

end
