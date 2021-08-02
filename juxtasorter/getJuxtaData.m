function juxtadata = getJuxtaData(basepath, varargin)
% This function loads in the raw juxtachannel
%
%   USAGE 
%   juxtadata = getJuxtaData(basepath, <options>)
%
%   Dependencies: 
%   buzcode
%
%   INPUTS
%   basepath        - path in which basename.dat is located
%
%   Name-value paired inputs:
%   'basename'      - if not the same as basepath (default:
%                      bz_BasenameFromBasepath)
%   'intervals'     - time in sec to include (default: [0 Inf])
%   'juxtachan'     - 0-based Neuroscope channel for juxta (default: 0)
%   'dsfactor'      - if you want to downsample (default: 1);
%
%   OUTPUTS
%   juxtadata       struct
%   .duration       - Total duration of read in recording
%   .interval       - interval to read in recording
%   .data           - [NxInterval] data through bz_LoadBinary
%   .times          - [NxInterval]
%   .channels       - juxtachannel, 0-based
%   .samplingRate   - sampling rate of data
%
%   EXAMPLES
%   juxtadata = getJuxtaData(basepath,'juxtachan',1,'intervals',[0 450])
%
%
%   TO-DO
%    
%
%   HISTORY
%   2019    Originally written by Lianne
%   2021/06 Lianne commented this code for Erik, removed ops/params
%

%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',false,@islogical);
addParameter(p,'intervals',[0 Inf],@isnumeric);
addParameter(p,'juxtachan',0,@isnumeric);
addParameter(p,'dsfactor',1,@isnumeric);
parse(p,varargin{:});

basename        = p.Results.basename;
saveMat         = p.Results.saveMat;
intervals       = p.Results.intervals;
juxtachan       = p.Results.juxtachan;
downsampfactor  = p.Results.dsfactor;

%% 

cd(basepath)

sessionInfo = bz_getSessionInfo;
nIntervals = size(intervals,1);

juxtachanIdx = juxtachan+1; % because we're looking for the index over a 0-based chan. 

datname = [basename '.dat'];


for i = 1:nIntervals
       
    juxtadata(i).duration = (intervals(i,2)-intervals(i,1));
    juxtadata(i).interval = [intervals(i,1) intervals(i,2)];
    
    juxtadata(i).data = bz_LoadBinary(datname, ...
    'duration',     double(juxtadata(i).duration'),...
    'channels',     juxtachanIdx,...
    'frequency',    sessionInfo.rates.wideband, ...
    'nChannels',    sessionInfo.nChannels,... 
    'start',        double(juxtadata(i).interval(1)),...
    'downsample',   downsampfactor);

    juxtadata(i).times = [juxtadata(i).interval(1):(1/sessionInfo.rates.wideband):...
        (juxtadata(i).interval(1)+(length(juxtadata(i).data)-1)/...
        sessionInfo.rates.wideband)]';
    
    juxtadata(i).channels = juxtachan;
    juxtadata(i).samplingRate = sessionInfo.rates.wideband;
    
     if juxtadata(i).interval(2) == inf
        juxtadata(i).interval(2) = length(juxtadata(i).times)/juxtadata(i).samplingRate;
        juxtadata(i).duration = (juxtadata(i).interval(i,2)-juxtadata(i).interval(i,1));
     end
    
     
end

if saveMat
    save([basename '.juxtadata.mat'],'juxtadata')
end

    
