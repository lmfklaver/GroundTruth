function histogram_GT (recordingIdx, excelDoc, BrainRegion)
 
 icountRec = 1;
 jcountRow = 1;
 
excelPath = fullfile(['C:\Users\Englishlab\Documents\R_Neur\', excelDoc]);
recordingsGT = table2struct(readtable(excelPath));

iRec = recordingIdx;
    RecordingNum = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session)]; 
    Cell = [num2str(recordingsGT(iRec).mouse) '_' num2str(recordingsGT(iRec).session) ]; %'_cell' num2str(recordingsGT(iRec).cell)
    
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

                
                JCind = JuxtaSpikes.shankID == 2;
                %spikesJCEC.sampleRate = 30000;
                spikesJCEC.UID(end+1) = JuxtaSpikes.UID(JCind);
                spikesJCEC.times(end+1) = JuxtaSpikes.times(JCind);
                spikesJCEC.shankID(end+1) = JuxtaSpikes.shankID(JCind);
                spikesJCEC.cluID(end+1) = JuxtaSpikes.cluID(JCind);
                spikesJCEC.rawWaveform(end+1) = JuxtaSpikes.rawWaveform(JCind);
                spikesJCEC.maxWaveformCh(end+1) = JuxtaSpikes.maxWaveformCh(JCind);
                spikesJCEC.region(end+1) = JuxtaSpikes.region(JCind); 
                
                [ccg,t] = CCG(spikesJCEC.times,[],'norm','counts','binSize',.001 );
              
   %Get how many neurons the extracellular recording has
    NeuronNum = length(spikesJCEC.shankID);
    vecPlot = NaN(1,NeuronNum, 'single');
                for neuron_num = 1:NeuronNum
                    hold on
                
                    countStat = ccg(:,neuron_num,NeuronNum); 
                    maxCountStat = max(countStat)
                    vecPlot(1,neuron_num) = [maxCountStat]
                   
                end
         
        vecPlot
        histogramPlot = histogram([vecPlot], NeuronNum);
        

  cd('C:\Data');

%add dotted line at zero for reference point


%ylim('manual');

%gray = [200 179 179]/255
%set(gca, 'color', [gray])   USE if want different background color

%Add graph titles and characteristics

%yticks([0 100 200 300]);
%yticklabels({'0', '.2', '.4', '.6', '.8', '1'})

title([BrainRegion ' Extracellular to Juxtacellular Spike Matches']);
xlabel('Number of Spike Matches');
ylabel('Extracellular Neuron Count');
box 'off';
set(gca, 'TickDir', 'out');
hold off
('Kachow! you made a graph!')
end

