function get_Wheel_Velocity () %input will be analogin file
% Reagan Bullins
% 9/10/19
%voltage readout code from http://intantech.com/files/Intan_RHD2000_data_file_formats.pdf
%Dependencies
%   analogin dat file
%   lfp file

analogin_file = 'm52_190731_145204_cell3_analogin.dat';
analogin_path = fullfile(['E:\ReaganB\GT_Recorded_Cells\m52_190731_145204\m52_190731_145204_cell3\', analogin_file]);
cd(fileparts(analogin_path))

%% First get info of analogin and convert to voltage
%reads a board ADC input data file 

%num_channels = length(board_adc_channels); % ADC input info from header file
num_channels = 8;

%fileinfo = dir('analogin.dat');
fileinfo = dir(analogin_file);
num_samples = fileinfo.bytes/(num_channels * 2); % uint16 = 2 bytes
data_in_file = fopen(analogin_file, 'r');
%Get voltage
voltage = fread(data_in_file, [num_channels, num_samples], 'uint16');
fclose(data_in_file);
voltage = voltage * 0.000050354; % convert to volts
% get voltage of only 2nd channel == wheel
voltage_analogin = voltage(2,:);

%% defining voltage to position 0 to 360
degreeWheel = rescale(voltage_analogin, 0 , 360);


%% get velocity aka derivative of graph

num_datapoints_analogin = length(degreeWheel);
lfp_juxta = bz_GetLFP(0); % just need amount of timepoints, any channel will work
num_timestamps_lfp = length(lfp_juxta.timestamps);

ratio_timestamps_to_datapoints = num_timestamps_lfp/num_datapoints_analogin;

difference_between_points(1,:) = diff(degreeWheel); %so if diff = 0, velocity is 0

velocity(1,:) = difference_between_points/ratio_timestamps_to_datapoints; %get derivative of curve for velocity at each point in time
%degrees per milisecond

%% make velocity plot of movement
%Wheel movement
figure,
subplot(3,1,1)
plot(((1:length(degreeWheel))/30000),degreeWheel)
title('wheel movement')
ylabel('degrees')
xlabel('time')
% plot(((1:length(voltage_analogin))/30000),voltage_analogin)

%make time vector
% for i = 1:num_datapoints_analogin
%         time(1,i) = ratio_timestamps_to_datapoints * i;
% end

% Juxta LFP
subplot(3,1,2)
plot(lfp_juxta.timestamps, lfp_juxta.data)
title('juxta')
xlabel('time')
ylabel('amplitude')

% Velocity
subplot(3,1,3)
plot(lfp_juxta.timestamps,velocity(1:23.9920818452:length(velocity)));
title('velocity')
xlabel('time')
ylabel('')
% plot(time(1:23.9920818452:length(time)), velocity(1:23.9920818452:length(velocity))) % plot every milisecond
    

%% make vectors of timepoints during movement, and make vector of timepoints during stillness

%% find errors during movement

%% find errors during still positions
end

