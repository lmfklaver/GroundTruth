function [wavespec_tot] = getWaveSpecCCO(lfp, freqRange, numFreqs)

sizeMatrixOfTimestamps = size(lfp.timestamps);
timestampCount = sizeMatrixOfTimestamps(2);

for iEvents = 1:timestampCount
    if iEvents > 1000
        break
    else
    lfp_temp = lfp;
    lfp_temp.data = lfp.data(:,iEvents);
    lfp_temp.timestamps = lfp.timestamps(:,iEvents);
    
    wavespec_temp = bz_WaveSpec(lfp_temp,'frange',freqRange,'nfreqs',numFreqs,'space','lin');
    wavespec_temp.data = abs(wavespec_temp.data);
    wavespec_tot(iEvents) = wavespec_temp;
    end
end
end