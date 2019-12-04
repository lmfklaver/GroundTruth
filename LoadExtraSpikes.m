function [ExtraSpikes, ECind] = LoadExtraSpikes(pathInfo,params,opts)

switch (opts.extra_sorter)
    case 'EC_kilosort1'  
         cd(pathInfo.RecPathEC);
         ExtraSpikes = bz_GetSpikes;
          ECind = find(ExtraSpikes.shankID == 1);
    case 'EC_kilosort2'
         cd(pathInfo.RecPath);  
        
    case 'EC_firings.mda'
         cd(pathInfo.RecPath);
         
         extrafile = readmda('firings.mda');
         [e_maxWaveformCh ,e_times, e_cluID] = deal(extrafile(1,:),extrafile(2,:), extrafile(3,:));
            for iClu = 1:max(e_cluID)
                ExtraSpikes.times{iClu} = e_times(e_cluID == iClu)';
                ExtraSpikes.times{iClu} = ExtraSpikes.times{iClu}/opts.SampFreq;
                %ExtraSpikes.maxWaveformCh{iClu} = e_maxWaveformCh(e_cluID == iClu);
            end
                ExtraSpikes.shankID = repmat(1,1,max(e_cluID));
                ExtraSpikes.cluID = 1:max(e_cluID)
                ExtraSpikes.cluID = ExtraSpikes.cluID + 1;
                ExtraSpikes.sampleRate  = opts.SampFreq;
                ExtraSpikes.region = {'HPC'};
                S_score1 = load('raw_geom_score.mat');
            % set the ground truth unit index
                iGt1 = 1;

            % Find the peak channel (which has the most negative peak)
                iChan_max = S_score1.viSite_gt(iGt1); 

                EChanID = params.Probeflip(iChan_max);
                ExtraSpikes.maxWaveformCh = repmat(EChanID,1,max(e_cluID));
    
end
end
        