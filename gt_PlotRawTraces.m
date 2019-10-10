
function [out] = gt_PlotRawTraces(juxtaSpikes,lfp,params,ops,plotops)
spikes = juxtaSpikes;
%% Figure raw

% raw data
if plotops.plotRawTraces
    figure
    yOffset = 0;
    for iChan = params.Probe(1:end-1)% minus juxtachan
        hold on
        yOffset = yOffset - plotops.lfpstepY;
        plot(lfp.timestamps,double(lfp.data(:,iChan))/plotops.divisionFactorLFP+yOffset)  % add ,'color'  if you want all the traces to be the same color
    end
end

% rasters

if plotops.plotRasters
    yTMmax = plotops.lfpTracesLowY;
    yTMmin = plotops.rasterstepY-abs(plotops.lfpTracesLowY);
    
    for idx_hMFR = 1 %clusters sorted by descending meanFR
        for iSpk = 1:length(spikes.times{idx_hMFR})
            if spikes.times{idx_hMFR}(iSpk) > ops.intervals(1)  && spikes.times{idx_hMFR}(iSpk) <ops.intervals(2)
                line([spikes.times{idx_hMFR}(iSpk) spikes.times{idx_hMFR}(iSpk)],[yTMmin yTMmax]),
                hold on
            end
        end
        yTMmin = yTMmin-plotops.rasterstepY;
        yTMmax = yTMmax-plotops.rasterstepY;
    end
    
    xlim([ops.intervals(1) ops.intervals(2)])
    
    out=1;
end