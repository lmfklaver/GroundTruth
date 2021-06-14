%%
for iCell = 1%:length(juxtaSpikes)
    spikeEpochs = round(linspace(1,length(juxtaSpikes(iCell).spk),10));
    spkInd = [];
    
    for startEpoch = spikeEpochs
        
        numSpikeStep = spikeEpochs(end)-spikeEpochs(end-1); %step
        
        plotInd = startEpoch:startEpoch+numSpikeStep;
        if sum(plotInd>spikeEpochs(end)) >1
            continue
        else
            
            figure,
            plot(juxtaSpikes(iCell).spk(plotInd,:)')
            
            result = input('y?','s');
            
            if strcmp(result,'y')
                fig = gcf;
                axObjs = fig.Children;
                dataObjs = axObjs.Children;
                lineObjs = findobj(dataObjs, 'type', 'line');
                ydata = [];
                ydata = get(lineObjs, 'YData');
                
                newY = [];
                for i = 1:length(ydata)
                    newY(i,:) = ydata{i};
                end
                
                spkInd = [spkInd; find(ismember(juxtaSpikes(iCell).spk,newY,'rows'))];
                % plotInd = plotInd + numSpikeStep;
                
            end
        end
    end
end
