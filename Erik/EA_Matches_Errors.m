function [cco_timevector,cco_indexvector,numMatch_Error] = EA_Matches_Errors(JuxtaSpikesTimes,ExtraSpikesTimes,highestChannelCorr, bestCluster,opts)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here

matches                 = 0;
omission_error_num      = 0;
commission_error_num    = 0;

rangeSpkBin             = opts.rangeSpkBin;

cco_timevector.matches  = [];
cco_timevector.om  = [];

cco_indexvector.matches = [];
cco_indexvector.om = [];

for iSpikeJuxta = 1:length(JuxtaSpikesTimes)
    
    selectedJuxtaSpike = JuxtaSpikesTimes(iSpikeJuxta);
    
    compareTimes = ExtraSpikesTimes{bestCluster} - selectedJuxtaSpike;
    
    closestTimeInt = min(abs(compareTimes));
    closestInx = find(compareTimes == closestTimeInt);
    if closestTimeInt <= rangeSpkBin
        
        matches = matches + 1;
        cco_timevector.matches = [cco_timevector.matches ; ExtraSpikesTimes{bestCluster}(closestInx)];
        cco_indexvector.matches = [cco_indexvector.matches ; closestInx];
        
    else
        
        omission_error_num = omission_error_num + 1;
        cco_timevector.om = [cco_timevector.om ; selectedJuxtaSpike];
        cco_indexvector.om = [cco_indexvector.om ; iSpikeJuxta];
        
    end
    
    
end

commission_error_num = length(ExtraSpikesTimes{bestCluster})- matches - omission_error_num;

numMatch_Error.matches = matches;
numMatch_Error.om = omission_error_num;
numMatch_Error.com = commission_error_num;


end

