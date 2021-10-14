function [EMG_ep] = getEMGEpochs(basepath,EMGFromLFP,varargin)
% This function is designed to get the EMG epochs
%
%   USAGE
%
%   %% Dependencies %%%
%
%
%   INPUTS
%   basepath
%   
%
%
%   OUTPUTS
%  
%   EXAMPLE
% [EMG_ep] = getEMGEpochs(basepath,EMGFromLFP, 'EMGthr',0.8','smoothwin',0.25*1250);
%   HISTORY


%   TO-DO


%%

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);
addParameter(p,'EMGthr',[],@isnumeric);
addParameter(p,'smoothwin',[],@isnumeric);
addParameter(p,'saveAs','.EMG.epochs.mat',@isstr);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
thr             = p.Results.EMGthr;
saveAs          = p.Results.saveAs;
smoothwin       = p.Results.smoothwin;

cd(basepath)


%%
smoothedEMG  = movmean(EMGFromLFP.data,smoothwin); %
% fractionEMG = length(smoothedEMG(smoothedEMG>thr))/length(smoothedEMG);
EMG = smoothedEMG> thr;
diff_Rb = diff(EMG);
time = EMGFromLFP.timestamps;

%% finding start and stop of running epochs
emgStartIdx = find(diff_Rb==1)+1;
emgStopIdx = find(diff_Rb==-1)+1;

StartorStop = diff_Rb(diff_Rb~=0);
if ~isempty(emgStartIdx)
    if diff_Rb(1) == 0 && StartorStop(1) == -1
        emgStartIdx = [1 emgStartIdx];
    end
    if diff_Rb(end) == 0 && StartorStop(end) ==1
        emgStopIdx=  [emgStopIdx length(EMG)];
    end
    
    %%_____Reagan______________
    % if more starts than stops, introduce end of recording as stop
    if length(emgStartIdx) > length(emgStopIdx)
        emgStopIdx(end+1) = max(time);
    end
    %___________________________
    
    emgIdx = [emgStartIdx' emgStopIdx'];
    emgEpochs = [time(emgStartIdx)' time(emgStopIdx)'];
else
    emgEpochs = [NaN NaN];
    emgIdx = [NaN NaN];
end
%%

% for backward compatibility with current code
EMG_ep.epochs = emgEpochs;
EMG_ep.index = emgIdx;

% for compatibility with buzcode
EMG_ep.ints.emg = EMG_ep.epochs;
EMG_ep.detectorinfo.detectorname = 'getEMGEpochs.m';
EMG_ep.detectorinfo.detectionparms.EMGthr = thr;
EMG_ep.detectorinfo.detectionparms.smoothwin = smoothwin;
EMG_ep.EMGFromLFP = EMGFromLFP;
EMG_ep.detectorinfo.detectiondate = today('datetime');

%%

if saveMat
    % Check if file exists:
    femg = [basename saveAs];
    
    if exist(femg,'file')
        overwrite = input([basename, saveAs ' already exists. Overwrite? [Y/N] '],'s');
        switch overwrite
            case {'y','Y'}
                delete(femg)
            case {'n','N'}
                return
            otherwise
                error('Y or N please...')
        end
    end
    
    save([basename saveAs],'EMG_ep')
end
end

