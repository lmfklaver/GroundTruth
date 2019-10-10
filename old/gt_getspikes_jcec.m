cd(ECfolder)
spikesEC = bz_GetSpikes;
ECind = spikesEC.shankID == 1;
spikesJCEC.sampleRate = 30000;
spikesJCEC.UID = spikesEC.UID(ECind);
spikesJCEC.times = spikesEC.times(ECind);
spikesJCEC.shankID = spikesEC.shankID(ECind);
spikesJCEC.cluID = spikesEC.cluID(ECind);
spikesJCEC.rawWaveform = spikesEC.rawWaveform(ECind);
spikesJCEC.maxWaveformCh = spikesEC.maxWaveformCh(ECind);
spikesJCEC.region = spikesEC.region(ECind); 
spikesJCEC.sessionName = spikesEC.sessionName;
spikesJCEC.numcells = spikesEC.numcells;
spikesJCEC.spindices = spikesEC.spindices;

cd(JCfolder)
spikesJC = bz_GetSpikes 
JCind = spikesJC.shankID == 2
%spikesJCEC.sampleRate = 30000;
spikesJCEC.UID(end+1) = spikesJC.UID(JCind);
spikesJCEC.times(end+1) = spikesJC.times(JCind);
spikesJCEC.shankID(end+1) = spikesJC.shankID(JCind);
spikesJCEC.cluID(end+1) = spikesJC.cluID(JCind);
spikesJCEC.rawWaveform(end+1) = spikesJC.rawWaveform(JCind);
spikesJCEC.maxWaveformCh(end+1) = spikesJC.maxWaveformCh(JCind);
spikesJCEC.region(end+1) = spikesJC.region(JCind); 
% spikesJCEC.sessionName = spikesJC.sessionName;
% spikesJCEC.numcells = spikesJC.numcells;
% spikesJCEC.spindices = spikesJC.spindices;



[ccg,t] = CCG(spikesJCEC.times,[]);


checkCorrs = squeeze(ccg(:,:,end));
maxCC = max(max(checkCorrs)) % gives you EC cluster with highest correlation to JC
[r,c] = find(checkCorrs ==maxCC)

% by looking at all the times (101) of the ccg matrix for all different clusters, you can get the counts for the other EC correlation occurences out

spikesJCEC.cluID(c) % clusterID in neuroscope of indexed column
spikesJCEC.maxWaveformCh(c) % channel on which waveform is highest
