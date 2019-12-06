% StartUp code for GroundTruth Analysis
%     --Defines paths, parameters, recording sessions,options--
% By:      Reagan  on  11/13/19

% INPUTS: -Drive on Computer with ... -Code and Data
%                                     -Buzcode
%         -Which JuxtaSorter & which ExtraSorter

%% DEFINE DRIVE & SORTERS - EVERYTIME :)
    drive_code = 'D';     
      % Reagan = D 
      % Lianne = E
    drive_buzcode = 'D';
      % Reagan = D
      % Lianne = C
    opts.juxta_sorter = 'JC_kilosort1';
      % JC_kilosort1  
      % JC_juxtaSorter      
      % JC_firings_true.mda    Ironclust
    opts.extra_sorter = 'EC_kilosort1';
      % EC_kilosort1           
      % EC_kilosort2
      % EC_firings.mda         Ironclust
%% Add & Define Generic Pathways
    if strcmp(drive_code, 'D')
        addpath(genpath('D:\Data\GroundTruth\'))
        addpath(genpath('D:\Code\Github\'))
        basepath = ([drive_code ':\Data\GroundTruth\']);
    end
    if strcmp(drive_code, 'E')
        addpath(genpath('C:\Users\lklaver\Documents\GitHub\buzcode'))
        addpath(genpath('E:\Dropbox\Code\GroundTruth\'))
        basepath = ([drive_code ':\Data\GroundTruth\']);
    end

%% Recording Sessions Available 
%Sessions availble for each type of sorter
    switch (opts.juxta_sorter)
        case 'JC_kilosort1'
            sessions    = {'m15_190315_152315', ...
               'm41_190614_114301_cell4', ...
               'm41_190621_125124_cell1', ...
               'm52_190731_145204', ...
               'm52_190731_145204_cell3'};
            JC_sessions = {'m15_190315_152315\Kilosort_2019-08-06_110856_GOOD_JC', ...
               'm41_190614_114301_cell4\Kilosort_2019-08-08_135113_GOOD_EC_AND_JC', ...
               'm41_190621_125124_cell1\Kilosort_2019-08-08_160040_GOOD_jc', ...
               'm52_190731_145204\Kilosort_2019-08-06_155420_GOOD_JC', ...
               'm52_190731_145204_cell3\m52_190731_145204_cell3_Kilosort_2019-08-06_164839_GOOD_JC'};
%         case 'JC_juxtaSorter'
%             JC_sessions =   %Lianne
        case 'JC_firings_true.mda'
             sessions = {'m15_190315_152315_cell1'};
    end
    
    switch (opts.extra_sorter)
        case 'EC_kilosort1'
            EC_sessions = {'m15_190315_152315\Kilosort_2019-08-06_105959_GOOD_EC',...
                'm41_190614_114301_cell4\Kilosort_2019-08-08_135113_GOOD_EC_AND_JC',...
                'm41_190621_125124_cell1\Kilosort_2019-08-08_154651_GOOD_EC', ...
                'm52_190731_145204\Kilosort_2019-08-06_143641_GOOD_EC',...
                'm52_190731_145204_cell3\m52_190731_145204_cell3_Kilosort_2019-08-06_172234_GOOD_EC'};
%         case 'EC_kilosort2'
%             EC_sessions =   %James
    end
        
%         sessions = {'m14_190326_155432',...
%             'm14_190326_160710_cell1',...
%             'm15_190315_142052_cell1',...
%             'm15_190315_145422',...
%             'm15_190315_150831_cell1',...
%             'm15_190315_152315_cell1',...
%             'm52_190731_145204_cell3'};
%         areas = {'hpc','hpc','cx','hpc','hpc','hpc','th'};
  
%% Define Generic Params (intrinsic properties of recording)
    params.Probe0idx    = [13 20 28 5 9 30 3 24 31 2 4 32 1 29 23 10 8 22 11 25 21 12 7 19 14 26 18 15 6 17 16 27 0];
    params.Probeflip    = flip(params.Probe0idx);
    params.Probeflip(1) = []; % rm juxta
    params.juxtachan    = 1;
    params.Probe        = params.Probe0idx +1;
   
%% Define Generic Options   
    opts.rangeSpkBin        = .001; %binsize for extra occurring before or after juxta % maybe a bit wider for james' irc2 output?
    opts.timWinWavespec     = 250; %ms
    opts.doSave             = 0;
    opts.freqRange          = [1 500];
    opts.numFreqs           = 100;%ops.freqRange(end)-ops.freqRange(1);
    opts.bltimvec           = 10*501-1+250; %5259
    opts.intervals           = [0 Inf]; %in sec - change to desired time (find via neuroscope) multiple intervals can be assigned to multiple rows
    opts.downsamplefactor    = 1;
    opts.intervals           = [0 Inf];%[480 Inf]; %sec
    opts.hpfreq              = 450;
    opts.doPlots             = 0;
    opts.SampFreq            = 30000;
 



 
 
 
 
 