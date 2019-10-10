%% Analysis Pipeline for Ground-truth Dataset
% Workflow for analyzing juxta-silicon dual recordings for the ground-truth
% dataset
% Try to integrate buzcode as much as possible - https://github.com/buzsakilab/buzcode

%% Start-up
% Set paths (Where is the data, where are the functions/where is the code)
dataDir = 'C:\User\Data\';
codeDir = 'C:\User\Code\';

addpath(genpath(codeDir)) %(n.b. genpath takes all the underlying folders)
cd(dataDir)

% Read in the data (Get data into MATLAB format)
% - extracting LFP (bz_LFPFromDat.m)
% - aligning TTL pulse data (signalAlignment)
% - bz_PreprocessExtracellEphysSession
% - bz_SpktToSpkmat %1 x N_neurons cell array of spiketimes  and converts into a t/dt x N spike
% matrix.

%% Spike Train Statistics
% Firing Rate (Spikes per second) 

% Burstiness (How many spikes are firing quickly)  - burst_cls_kmeans.m

% Waveform Amplitude (Peak-to-trough / Max amp)

% SD from noise (GetSNR.m?)

%% Assessing "difficulty" for sorting algorithms 
% How many cells in recording

% How many spikes per cell

% How much synchrony (e.g. power in spike freq / mua) % Can be done without
% manual sorting

% Animal movement by obtaining pseudo-EMG (power of gamma across channels,
% Schomburg gamma paper Neuron ) % Can be done without manual sorting 

%% Recording characteristics without manual sorting
% 