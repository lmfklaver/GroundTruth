
 mainPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster';

% hippocampus
% RecPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\1_190315_152315';
% ExtraPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\1_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC';
% JuxtaPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\1_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC';

% % cortex
% RecPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\m41_190621_125124\m41_190621_125124_cell1';
% ExtraPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\m41_190621_125124\m41_190621_125124_cell1\Kilosort_2019-08-08_154651_GOOD_EC';
% JuxtaPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\m41_190621_125124\m41_190621_125124_cell1\Kilosort_2019-08-08_160040_GOOD_jc';

%thalamus
RecPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\m52_190731_145204_cell3\' ;
ExtraPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\m52_190731_145204_cell3\Kilosort_2019-08-06_172234_GOOD_EC';
JuxtaPath = 'D:\Lianne\Groundtruth_Data\Reagans Poster\m52_190731_145204_cell3\Kilosort_2019-08-06_164839_GOOD_JC';
%%
[spikesJCEC, lfp_juxta, lfp_extra, lfp_juxta_error, lfp_extra_error, extra_spike_Datadur, omission_Datadur, commission_Datadur, matches, omission_error_num, commission_error_num, wavespec_avg_tot_spikes,wavespec_avg_tot_omission, wavespec_avg_tot_commission] = gt_Spectrograms(mainPath, RecPath, ExtraPath, JuxtaPath)% Plotting Higly Correlated Graph

%%
figure('Name','Spectrograms')
hold on

% help gca

subplot(1,3,1)
imagesc(wavespec_avg_tot_spikes')
title('Highly Correlated Extracellular to Juxtacellular Spikes')
xlabel('Time(ms)')
ylabel('Frequency(Hz)')
% caxis([0 700])
 set(gca, 'YDir', 'normal') % Flips figure on y-axis to go from low-high frequency bottom-top respectively
% set(gca, 'YTick', [1 51 81 100 130 150 200 230]) % Sets the indices along the y-axis that you want to label (indices corespond to the 'nfreqs' input to wavespec)
 % set(gca, 'YTickLabel', {}) % changes the labels of the selected indices in 'YTick' above
 set(gca, 'XTick', [1 125 251 376 501])
 set(gca, 'XTickLabel', {-250 -125 0 125 250})
box 'off';
set(gca, 'TickDir', 'out');
colorbar

% Plotting Omission Error
subplot(1,3,2)
imagesc(wavespec_avg_tot_omission')
title('Omission Error Between Extracellular and Juxtacellular Spikes')
xlabel('Time(ms)')
ylabel('Frequency(Hz)')
% caxis([0 700])
set(gca, 'YDir', 'normal') % Flips figure on y-axis to go from low-high frequency bottom-top respectively
% set(gca, 'YTick', [1 51 81 100 130 150 200 230]) % Sets the indices along the y-axis that you want to label (indices corespond to the 'nfreqs' input to wavespec)
% set(gca, 'YTickLabel', {0 50 100 150 200 250 300 350}) % changes the labels of the selected indices in 'YTick' above
 set(gca, 'XTick', [1 125 251 376 501])
 set(gca, 'XTickLabel', {-250 -125 0 125 250})
box 'off';
set(gca, 'TickDir', 'out');
colorbar

% Plotting Commission Error
subplot(1,3,3)
imagesc(wavespec_avg_tot_commission')
title('Commission Error Between Extracellular and Juxtacellular Spikes')
xlabel('Time(ms)')
ylabel('Frequency(Hz)')
% caxis([0 500])
set(gca, 'YDir', 'normal') % Flips figure on y-axis to go from low-high frequency bottom-top respectively
% set(gca, 'YTick', [1 51 81 100 130 150 200 230]) % Sets the indices along the y-axis that you want to label (indices corespond to the 'nfreqs' input to wavespec)
% set(gca, 'YTickLabel', {0 50 100 150 200 250 300 350}) % changes the labels of the selected indices in 'YTick' above
 set(gca, 'XTick', [1 125 251 376 501])
 set(gca, 'XTickLabel', {-250 -125 0 125 250})
box 'off';
set(gca, 'TickDir', 'out');
colorbar


savefig(gcf,'Wavespecs.fig')
print(gcf,'Wavespecs.eps','-depsc2')

