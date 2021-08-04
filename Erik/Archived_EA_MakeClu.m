%% Dependencies
% JuxtaSpikesTimes
% basename
% spikes


%% create SpkTimesAll and RMSpikesID
% ***** Notice that the first entry of the clu file is the number of
% clusters (it doesn't just start off with the cluster IDs)

EA_MakeClu(JuxtaSpikesTimes,basename,spikes);

SpkTimesAll = JuxtaSpikesTimes;
RMSpikesID = zeros(length(JuxtaSpikesTimes)+1,1);
RMSpikesID(1:1) = 1; % there is one group (juxta) even though cluster ID is 0
% RMSpikesID(RMSpikesID == 0) = 1;

%% Creating the Files for Juxta

    
    SpkTimesSamp = round(SpkTimesAll*30000);
    fid=fopen([basename, 'JC', '.res.1'],'wt+');
%     fwrite(fid,' %.0f\n',SpkTimesAll);
    fprintf(fid,'%.0f\n',SpkTimesSamp);
    fclose(fid);
    clear fid
    
    fid=fopen([basename, 'JC', '.clu.1'],'wt+');
    fprintf(fid,'%.0f\n',RMSpikesID);
    fclose(fid);
    clear fid
    
%% Now creating the corresponding files for extracellular

% here we will make the decision to add one extra value to the end of the
% array

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

% RMSpikesIDEC(end + 1,1) = RMSpikesIDEC(end);


%%    writing to file
    
%     SpkTimesSamp = round(SpkTimesAll*30000);
    fid=fopen([basename, 'EC', '.res.1'],'wt+');
    fprintf(fid,'%.0f\n',SpkTimesAllEC);
    fclose(fid);
    clear fid  
    
    fid=fopen([basename, 'EC', '.clu.1'],'wt+');
    fprintf(fid,'%.0f\n',RMSpikesIDEC);
    fclose(fid);
    clear fid

%% Create JCEC version of Clu and res
        
    SpkTimesAll_JCEC = [SpkTimesSamp ; SpkTimesAllEC ];    
    RMSpikesID_JCEC = [spikes.numcells + 1 ; RMSpikesID(2:end,1)];
    RMSpikesID_JCEC = [RMSpikesID_JCEC ; RMSpikesIDEC(2:end,1)];
%     RMSpikesID_JCEC = [RMSpikesID(1:end-1,1) ; ];
%% Create Associated Files            
    fid=fopen([basename, '_JCEC', '.res.1'],'wt+');
    fprintf(fid,'%.0f\n',SpkTimesAll_JCEC);
    fclose(fid);
    clear fid    
    
    fid=fopen([basename, '_JCEC', '.clu.1'],'wt+');
    fprintf(fid,'%.0f\n',RMSpikesID_JCEC);
    fclose(fid);
    clear fid
    
% fid=fopen([basename '.clu.3'],'wt+');
%     fprintf(fid,'%.0f\n',test);
%     fclose(fid);
%     clear fid
