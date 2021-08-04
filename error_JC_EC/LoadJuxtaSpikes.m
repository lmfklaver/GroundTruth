function [JuxtaSpikes, JCind] = LoadJuxtaSpikes(pathInfo,params,opts)

switch (opts.juxta_sorter)
        case 'JC_kilosort1'
             cd(pathInfo.RecPathJC);
             JuxtaSpikes = bz_GetSpikes;
             
             JCind = find(JuxtaSpikes.shankID == 2);
             
        case 'JC_juxtaSorter'
             cd(pathInfo.JuxtaPath);     
             JuxtaSpikes = juxtaSpikes;             
             JCind = find(JuxtaSpikes.shankID == 10);
             
        case 'JC_firings_true.mda'
             cd(pathInfo.RecPath); 
             
             juxtafile = readmda('firings_true.mda');
             [j_maxWaveformCh, j_times, j_cluID] = deal(juxtafile(1,:), juxtafile(2,:), juxtafile(3,:));
                for iClu = 1:max(j_cluID)
                    JuxtaSpikes.times{iClu} = j_times(j_cluID == iClu)';
                    JuxtaSpikes.times{iClu} = JuxtaSpikes.times{iClu}/opts.SampFreq; % if this becomes an array, how to divide every element in array?
                    %JuxtaSpikes.maxWaveformCh{iClu} = j_maxWaveformCh(j_cluID == iClu);
                end
                  JuxtaSpikes.shankID = repmat(2,1,max(j_cluID));
                  %(1:numel(JuxtaSpikes.times))
                  JuxtaSpikes.cluID = 1:max(j_cluID);
                  JuxtaSpikes.cluID = JuxtaSpikes.cluID + 1;
                  JuxtaSpikes.sampleRate = opts.SampFreq;
                  JuxtaSpikes.region = {'HPC'};
                  %Change WITH JAMES
                  JChanID = 1;
                  JuxtaSpikes.maxWaveformCh = repmat(JChanID,1,max(j_cluID));
end
end