function [waveforms] = get_waveforms_from_kwik_intan(fileName, spikeSamples, spikeChannel, nChans, sampleRate)

% Get Waveforms KlustaKwik

nRawChans = nChans ; %input from kwx file directly, length of meanFeatures
nChansInDatFile = nChans;

DatFile = [fileName(1:end-4) 'dat'];

tBefore = 40; % % 
tAfter = 40; % % 

MySamples =  spikeSamples;% timestamps in samples, not in seconds
MySamples = double(MySamples);

FileInfo = dir(DatFile);

nSpikes = length(spikeSamples);
nTimeSamplesPerWaveform = tBefore + tAfter +1;

num_channels = nChans; %length(amplifier_channels); % amplifier channel info from header file
fileinfo = dir(DatFile);
num_samples = fileinfo.bytes/(num_channels * 2); % int16 = 2 bytes
fid = fopen(DatFile, 'r');
v = fread(fid, [num_channels, num_samples], 'int16');
time_v = 1:length(v);
time_v = time_v ;%/ sampleRate;

fclose(fid);

waveforms = zeros(1, nTimeSamplesPerWaveform, nSpikes);

for iSpk=1:nSpikes
    try
        selSpike = MySamples(iSpk);
        time2Match = selSpike;%/sampleRate;
        matchTime = find(time_v == time2Match);
        waveforms(1,:,iSpk) = v(spikeChannel,matchTime-tBefore:matchTime+tAfter);
%         waveforms(:,:,i) = Source.Data.x(1:nChansInDatFile,MyTimes(i)-tBefore:MyTimes(i)+tAfter);
%         waveforms(1,:,iSpk) = Source.Data.x(spikeChannel,MySamples(iSpk)-tBefore:MySamples(iSpk)+tAfter);
    catch ME
        fprintf(ME)
    end
end
