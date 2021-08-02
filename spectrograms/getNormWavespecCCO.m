  function [normdata] = getNormWavespecCCO(lfp, lfp_bl,freqRange,numFreqs)
        wavespec_BL     = getWaveSpecCCO(lfp_bl,freqRange,numFreqs);%getWaveSpecCCO
        wavespec_avg_BL = mean(cat(3,wavespec_BL.data),3);
        clear lfp_bl wavespec_BL
        %normalizing
        avgFreq         = mean(mean(wavespec_avg_BL,3));
        clear wavespec_avg_BL
        normMat         = repmat(avgFreq,501,1);
        wavespec        = getWaveSpecCCO(lfp,freqRange, numFreqs);%getWaveSpecCCO
        clear lfp
        wavespec_avg    = mean(cat(3,wavespec.data),3); %concatenate all the matches in the struct, get the average over those matches
        clear wavespec
        normdata  = wavespec_avg./normMat;
    end