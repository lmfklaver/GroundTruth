function EA_MakeSingleCluster(basename,nClu,dataCell,cellNum)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

nCluStr = num2str(nClu);
nClusterData = ones(length(dataCell{cellNum}),1)*nClu;
nCluster = [1 ; nClusterData];
EA_WriteCluFile(basename, ['_',nCluStr,'test'], ['.clu.',nCluStr], nCluster)

EA_WriteCluFile(basename, ['_',nCluStr,'test'], ['.res.',nCluStr], dataCell{cellNum})
end

