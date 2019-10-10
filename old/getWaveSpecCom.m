function [wavespec_tot_spikes_commission] = getWaveSpecCom(lfp_com_error, freqRange, numFreqs)

%Run for commission error
sizeMatrixOfTimestamps = size(lfp_com_error.timestamps);
timestampCount = sizeMatrixOfTimestamps(2);

for iEvents = 1:timestampCount
    lfp_extra_temp_commission = lfp_com_error;
    lfp_extra_temp_commission.data = lfp_com_error.data(:,iEvents);
    lfp_extra_temp_commission.timestamps = lfp_com_error.timestamps(:,iEvents);
    wavespec_commission_temp = bz_WaveSpec(lfp_extra_temp_commission,'frange',freqRange,'nfreqs',numFreqs,'space','lin');
    wavespec_commission_temp.data = abs(wavespec_commission_temp.data);
    wavespec_tot_spikes_commission(iEvents) = wavespec_commission_temp; % change to be an input of animal
end

fprintf('done Commissions\n')
end