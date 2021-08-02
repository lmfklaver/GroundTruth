function plotJuxtaSorted(allJuxtas,juxtaSpikes,sessions, ops,params)
% This function 
%
%   USAGE 
%
%   Dependencies: 
%   
%
%   INPUTS
%   basepath
%
%   Name-value paired inputs:
%
%   OUTPUTS
%
%
%   EXAMPLES
%
%
%   NOTES
%  
%
%   TO-DO
%    
%
%   HISTORY
%
%

%% Parse!

if ~exist('basepath','var')
    basepath = pwd;
end

basename = bz_BasenameFromBasepath(basepath);

p = inputParser;
addParameter(p,'basename',basename,@isstr);
addParameter(p,'saveMat',true,@islogical);


parse(p,varargin{:});
basename        = p.Results.basename;
saveMat         = p.Results.saveMat;

cd(basepath)

sessionInfo = bz_getSessionInfo(cd);


%plot AutoCorelloGram
[ccg,t]=CCG(allJuxtas,[],'Fs',sessionInfo.rates.wideband,'binSize',ops.ccgBinSize,'duration', ops.ccgDur,'norm','rate');

plotCount = 1;

figure
for iCell = 1:size(ccg,2)
    for iPairedCell = 1:size(ccg,2)
        if iCell == iPairedCell
            subplot(ceil(sqrt(size(ccg,2))),ceil(sqrt(size(ccg,2))),plotCount)
            plotCount = plotCount+1;
            if iCell == iPairedCell
                bar(t,ccg(:,iCell,iPairedCell),'k')
            end
        end
    end
end

figure
for iSess = 1:length(sessions)
    subplot(ceil(sqrt(length(sessions))),ceil(sqrt(length(sessions))),iSess)
    plot(juxtaSpikes(iSess).rawWaveform{1})
end

end