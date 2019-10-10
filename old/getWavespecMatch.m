function [wavespec_tot_spikes] = getWavespecMatch(lfp_extra_matches,freqRange, numFreqs)

% run for matches
sizeMatrixOfTimestamps = size(lfp_extra_matches.timestamps);
timestampCount = sizeMatrixOfTimestamps(2);

for iEvents = 1:timestampCount
    lfp_extra_temp = lfp_extra_matches;
    lfp_extra_temp.data = lfp_extra_matches.data(:,iEvents);
    lfp_extra_temp.timestamps = lfp_extra_matches.timestamps(:,iEvents);
    wavespec_event_temp = bz_WaveSpec(lfp_extra_temp,'frange',freqRange,'nfreqs',numFreqs, 'space','lin');
    wavespec_event_temp.data = abs(wavespec_event_temp.data);
    wavespec_tot_spikes(iEvents) = wavespec_event_temp; % change to be an input of animal
end

fprintf('done Matches\n')
end