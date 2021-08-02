function extractMUA (fs, raw_data)
%% Analog MUA extraction
%inputs: fs sampling rate, raw_data
fc = 1000; %cutoff frequency
[b,a] = butter(4,fc/(fs/2),'high');
HP_data = filtfilt(b,a,raw_data);
bpFilt = designfilt('bandpassfir', 'StopbandFrequency1', 400, 'PassbandFrequency1',...
           450, 'PassbandFrequency2', 2950, 'StopbandFrequency2', 3000,... 
           'StopbandAttenuation1', 60, 'PassbandRipple', 0.01, 'StopbandAttenuation2', 60,...
           'SampleRate', 20000, 'DesignMethod', 'kaiserwin');
analg_MUA = abs(filtfilt(bpFilt,HP_data));
decimated_data = decimate(analg_MUA,10);
%fc = 250; %cultoff frequency
%[b,a] = butter(4,fc/(fs/20),'low');
%decimated_data_LP = filtfilt(b,a,decimated_data);
%MUA = downsample(decimated_data_LP,2);
Noise_peak_threshold = 4*std(abs(MUA)); % adapt to suit your data (I changed this from 10 to 4)
Noise_peak_index = find(abs(MUA) > Noise_peak_threshold);
temp = MUA;
temp(Noise_peak_index) = [];
replace_noise_with = mean(temp);
MUA(Noise_peak_index) = replace_noise_with;
fs_MUA = fs/20;
end
