function [juxtaSpikes, allJuxtas] = GetJuxtaSpikes(basepath, selecSession, ops, params)

        datfileName = [selecSession '.dat'];%'m52_190731_145204_cell3'; %.dat

        % Load juxta chan
        juxtadata = getJuxtaData(basepath, datfileName, ops, params);
        
        % Detect spikes above threshold
        [juxtaSpikes] = DetectJuxtaSpikes(juxtadata, selecSession, ops);
         allJuxtas = juxtaSpikes.times;
        % To implement: manual rejection with rejectDetectedSpikes
end
