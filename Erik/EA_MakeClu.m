function EA_MakeClu(JuxtaSpikesTimes,basename,spikes)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

%% Dependencies
% JuxtaSpikesTimes
% basename
% spikes

%% Create SpkTimesAll and RMSpikesID (Juxta Data to go into .clu and .res files)
% ***** Notice that the first entry of the clu file is the number of
% clusters (it doesn't just start off with the cluster IDs)


SpkTimesAll = JuxtaSpikesTimes;
RMSpikesID = zeros(length(JuxtaSpikesTimes)+1,1);
RMSpikesID(1:1) = 1; % there is one group (juxta) even though cluster ID is 0
% RMSpikesID(RMSpikesID == 0) = 1;

%% Writing the .clu and .res Files for Juxta


SpkTimesSamp = round(SpkTimesAll*30000);
EA_WriteCluFile(basename, 'JC', '.res.1', SpkTimesSamp);
EA_WriteCluFile(basename, 'JC', '.clu.1', RMSpikesID);

%% Prepare corresponding data for extracellular spikes

SpkTimesAllEC = [];

for i = 1:spikes.numcells
    
    currentSpikeTimes = spikes.ts{i}(:,1);
    
    SpkTimesAllEC = [SpkTimesAllEC; currentSpikeTimes];
end


RMSpikesIDEC = [];
RMSpikesIDEC(1:1) = spikes.numcells;
for  i = 1:spikes.numcells
    
    currentEC_Clu_ID = ones(length(spikes.ts{i}),1)*i;
    RMSpikesIDEC = [RMSpikesIDEC; currentEC_Clu_ID];
end


%% Writing the .clu and .res Files for EC

EA_WriteCluFile(basename, 'EC', '.res.1', SpkTimesAllEC);
EA_WriteCluFile(basename, 'EC', '.clu.1', RMSpikesIDEC);

%% Prepare corresponding data for Juxta (JC) and EC combo

SpkTimesAll_JCEC = [SpkTimesSamp ; SpkTimesAllEC ];
RMSpikesID_JCEC = [spikes.numcells + 1 ; RMSpikesID(2:end,1)];
RMSpikesID_JCEC = [RMSpikesID_JCEC ; RMSpikesIDEC(2:end,1)];
%     RMSpikesID_JCEC = [RMSpikesID(1:end-1,1) ; ];
%% Writing the .clu and .res Files for JCEC

EA_WriteCluFile(basename, '_JCEC', '.res.1', SpkTimesAll_JCEC);
EA_WriteCluFile(basename, '_JCEC', '.clu.1', RMSpikesID_JCEC);


end

