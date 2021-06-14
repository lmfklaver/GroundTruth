function [] = gt_plotSpectrograms(ops,normdata)


%% Graphing
figure('Name','Spectrograms')

% help gca
for iPlot = 1:3
    if iPlot == 1
        s1 = subplot(1,3,iPlot);
        %         imagesc(wavespec_avg_tot.match');
        imagesc(normdata.match');
        hold on
        title('Highly Correlated Extracellular to Juxtacellular Spikes');
    elseif iPlot == 2
        s2 = subplot(1,3,iPlot);
        %         imagesc(wavespec_avg_tot.omission');
        imagesc(normdata.om');
        title('Omission Error Between Extracellular and Juxtacellular Spikes');
    elseif iPlot == 3
        s3 = subplot(1,3,iPlot);
        
        %         imagesc(wavespec_avg_tot.commission');
        imagesc(normdata.com');
        title('Commission Error Between Extracellular and Juxtacellular Spikes');
    end
    
    xlabel('Time(ms)');
    ylabel('Frequency(Hz)');
    set(gca, 'YDir', 'normal');
    
    freqStep = (ops.freqRange(2)-ops.freqRange(1))./ops.numFreqs;
    YtickVec = 0:20:ops.numFreqs;
    YlabelVec = freqStep*YtickVec;
    for i = 1:length(YlabelVec), YlabelVecStr{i} = num2str(YlabelVec(i));, end
    
    set(gca, 'YTick', [YtickVec])
    set(gca, 'YTickLabel', {YlabelVec}) % changes the labels of the selected indices in 'YTick' above
    set(gca, 'XTick', [1 125 251 376 501])
    set(gca, 'XTickLabel', {-250 -125 0 125 250})
    box 'off';
    set(gca, 'TickDir', 'out');
    t = colorbar;
    colorSc(iPlot,1:2) = t.Limits;
end

for sIdx = [s1,s2,s3]
     caxis(sIdx, [min(colorSc(:,1)) min(colorSc(:,2))]);
end

disp('Done!')

if ops.doSave
    savefig(gcf,'Wavespecs.fig')
    print(gcf,'Wavespecs.eps','-depsc2')
end
end
