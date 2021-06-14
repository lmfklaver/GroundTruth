function graphWaveform (titleOfArea)
%Graph individual waveforms for cells
%dependencies
%       load_klusta_spikes.m
%       get_spikes_from_kwik.m
%       get_waveforms_from_kwik.m
%       buz code
%Written by Reagan.. 7-12-19
%
 
 spikes = bz_GetSpikes;
 
 juxtaSpikeIndex = find(spikes.shankID == 2);
 juxtaSpikeWaveform = spikes.rawWaveform{juxtaSpikeIndex};
 juxtaCorrected = juxtaSpikeWaveform * 0.195;
graphWaveform = plot(juxtaCorrected);

title([titleOfArea ' ' 'Juxtacellular Waveform Average']); 
xlabel('Time (seconds)');
ylabel('mV');
set(gca, 'TickDir', 'out');
box off
'graph made!'
end



        