function [meanFR] = plotJuxtaFR(juxtaSpikes, params)

    numSpikes = length(juxtaSpikes.times{1});
    recLengthSec = juxtaSpikes.ts{1}(end)/params.sampFreq;
    meanFR = numSpikes/recLengthSec;


hist(meanFR,10)