%% This script is gets the spectrogram figures out

% Lianne's adaptation of Reagan's script
% Reagan edits on 11/13/19
%%
for iSess = 5%1:length(sessions)
  %Define Recording Session Specific Pathways
            
        switch (opts.juxta_sorter)
            case 'JC_kilosort1'
                pathInfo.RecPath       =  [basepath sessions{iSess}];
                pathInfo.RecPathJC     =  [basepath JC_sessions{iSess}];
            case 'JC_juxtaSorter'
                pathInfo.RecPath       =  [basepath sessions{iSess}]; %Lianne
            case 'JC_firings_true.mda'
                pathInfo.RecPath       =  [basepath 'juxta_cell_output\' sessions{iSess}]; %Ironclust
        end

        switch (opts.extra_sorter)
            case 'EC_kilosort1'
                pathInfo.RecPathEC     =  [basepath EC_sessions{iSess}];
            case 'EC_kilosort2'
                pathInfo.RecPathEC     =  [basepath sessions{iSess}];  %James
        end 
    
    %Define Recording Session Specific Params
        sessionInfo         = bz_getSessionInfo(pathInfo.RecPath);
        params.nChans       = sessionInfo.nChannels;
        params.sampFreq     = sessionInfo.rates.wideband;

    %%
    [highestChannelCorr,  lfp_juxta, lfp_extra, JuxtaSpikesTimes, ExtraSpikesTimes] = gt_LoadJuxtaCorrExtra(pathInfo,params,opts);
    %
    [cco_timevector, cco_indexvector, num_CorrComOm] = gt_GetCorrCommOm(JuxtaSpikesTimes, ExtraSpikesTimes, highestChannelCorr, lfp_extra,lfp_juxta, opts, sessions, iSess);
    %
    [~, ~, normdata] = gt_calcSpectrograms(pathInfo,lfp_extra, cco_indexvector,opts);
    %ERROR in ^^^ GetNormWaveSpec
    %             GetWaveSpecCCO (line 14 error) when calling on WaveSpec function
    %
    gt_plotSpectrograms(opts,normdata)
end
