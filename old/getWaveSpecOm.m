function [wavespec_tot_spikes_omission] = getWaveSpecOm(lfp_om_error, freqRange, numFreqs)
sizeMatrixOfTimestamps = size(lfp_om_error.timestamps);
timestampCount = sizeMatrixOfTimestamps(2);

for iEvents = 1:timestampCount
    lfp_juxta_temp_omission = lfp_om_error;
    lfp_juxta_temp_omission.data = lfp_om_error.data(:,iEvents);
    lfp_juxta_temp_omission.timestamps = lfp_om_error.timestamps(:,iEvents);
    
    wavespec_omission_temp = bz_WaveSpec(lfp_juxta_temp_omission,'frange',freqRange,'nfreqs',numFreqs,'space','lin');
    wavespec_omission_temp.data = abs(wavespec_omission_temp.data);
    wavespec_tot_spikes_omission(iEvents) = wavespec_omission_temp;
    
end
fprintf('done Omissions\n')
end