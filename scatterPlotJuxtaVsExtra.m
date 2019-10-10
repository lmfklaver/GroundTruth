function scatterPlotJuxtaVsExtra(numRecordings, excelDoc)
%Creates scatterplot of intracellular versus extracellular data & gives r
%value
%
%dependencies
% excel doc with recording info
%timestamps of spikes
%
%Written by Reagan Bullins.. 7-17-19
%
%I'm really good at overcomplicating things :)
%

 
 icountRec = 1;
 jcountRow = 1;
 
excelPath = fullfile(['C:\Users\Englishlab\Documents\R_Neur\', excelDoc]);
recordingsGT = table2struct(readtable(excelPath));

 %loop through each recording
for iRec = 1:numRecordings
    
    RecordingNum = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)]; 
    Cell = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)]; % '_cell' num2str(recordingsGT(iRec).cell)
    
    %Go into recording folder
   RecPath = fullfile(['C:\Data\' RecordingNum '\' Cell]);
    cd(RecPath);
    %Go into kilosort folder for juxtacellular data
    JuxtaPath = fullfile(['C:\Data\' RecordingNum '\' Cell '\' recordingsGT(iRec).kiloJuxta]);
    cd(JuxtaPath);
    %Define JuxtaSpikes with buzcode function get spikes
    JuxtaSpikes = bz_GetSpikes;
   %Go back to main recording folder
    cd(RecPath);
    %Go into kilosort folder for extracellular data
    ExtraPath = fullfile(['C:\Data\' RecordingNum '\' Cell '\' recordingsGT(iRec).kiloExtra])
    cd(ExtraPath);
    %Define extra spikes with buz code function
    ExtraSpikes = bz_GetSpikes;
    
%                             %Find the correct index for each juxta and extra within the get spike
%                             %function
%                             juxtaSpikeIndex = find(JuxtaSpikes.shankID == 2);
%                             extraSpikeIndex = find(ExtraSpikes.shankID == 1);
% 
%                             %Create new array of extracelllular neurons and their spike times
%                             extraSpikeTimes = ExtraSpikes.times(extraSpikeIndex);
%                             %Create new array of juxtacellular neurons and their spike times
%                             juxtaSpikeTimes = JuxtaSpikes.times(juxtaSpikeIndex);

  
    
   
    
    
   %earthy colors 'Ground' Truth hah MAY need to ADD more
    colormat = [
    16, 193, 53;...
    64, 79, 36;...
    209, 156, 76;...
    157, 95, 56;...
    78,97,114;...
    131,146,159;...
    219,202,105;...
    213 117 0; ...
    133,87,35;...
    189,208, 156;...
    158,156,107]/255;
    % want to be able to keep adding plot points to same graph
    
                ECind = ExtraSpikes.shankID == 1;
                spikesJCEC.sampleRate = 30000;
                spikesJCEC.UID = ExtraSpikes.UID(ECind);
                spikesJCEC.times = ExtraSpikes.times(ECind);
                spikesJCEC.shankID = ExtraSpikes.shankID(ECind);
                spikesJCEC.cluID = ExtraSpikes.cluID(ECind);

                spikesJCEC.rawWaveform = ExtraSpikes.rawWaveform(ECind);
                spikesJCEC.maxWaveformCh = ExtraSpikes.maxWaveformCh(ECind);
                spikesJCEC.region = ExtraSpikes.region(ECind); 
                spikesJCEC.sessionName = ExtraSpikes.sessionName;
                spikesJCEC.numcells = ExtraSpikes.numcells;
                spikesJCEC.spindices = ExtraSpikes.spindices;

                
                JCind = JuxtaSpikes.shankID == 2
                %spikesJCEC.sampleRate = 30000;
                spikesJCEC.UID(end+1) = JuxtaSpikes.UID(JCind);
                spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);
                spikesJCEC.shankID(end+1) = JuxtaSpikes.shankID(JCind);
                spikesJCEC.cluID(end+1) = JuxtaSpikes.cluID(JCind);
                spikesJCEC.rawWaveform(end+1) = JuxtaSpikes.rawWaveform(JCind);
                spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);
                spikesJCEC.region(end+1) = JuxtaSpikes.region(JCind); 
                
                [ccg,t] = CCG(spikesJCEC.times,[],'norm','counts', 'binSize',.001);
              
   %Get how many neurons the extracellular recording has
    NeuronNum = length(spikesJCEC.shankID);
                for neuron_num = 1:NeuronNum
                    hold on
                
                    countStat = ccg(:,neuron_num,NeuronNum); 
                    maxCountStat = max(countStat);
                    corrPlot = plot(iRec,[maxCountStat],'o', 'Markersize', 11,'Linewidth', 2.5 , 'Color', colormat(icountRec,:));
                   
                end
        %graph each r value 

        
        

  cd('C:\Data');
end
%add dotted line at zero for reference point
xL = get(gca, 'XLim');
plot(xL, [0 0], '--','Color', 'k')


xlim('manual');
ylim('manual');

%gray = [200 179 179]/255
%set(gca, 'color', [gray])   USE if want different background color

%Add graph titles and characteristics
set(gca, 'YLim',[0  1500]);
xticks([1:numRecordings]);
yticks([0 250 500 750 1000 1250 1500]);
yticklabels({'0', '250', '500', '750', '1000', '1250', '1500'})
title('Juxtacellular to Extracellular Recording Counts');
xlabel('Juxtacellular Recording ID');
ylabel('Normalized Spike Count Matches');
box 'off';
set(gca, 'TickDir', 'out');
hold off
('Kachow! you made a graph!')
end



% maxCC = max(max(checkCorrs))
% [r,c] = find(checkCorrs ==maxCC)
% spikesJCEC
% spikesJCEC.cluID(c)
% r
% ccg(r,:,24)
% help ccg
% help CCG
% spikesJCEC.cluID(c) % clusterID in neuroscope of indexed column
% spikesJCEC.maxWaveformCh(c)
% spikesJCEC.maxWaveformCh(c) % channel on which waveform is highest
% help CCG
% [ccg,t] = CCG(spikesJCEC.times,[],'norm','counts');
% checkCorrs = squeeze(ccg(:,:,24))