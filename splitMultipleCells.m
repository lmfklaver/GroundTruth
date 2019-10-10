splitSessions = {'m14_190326_160710',...
'm15_190315_142052',...
'm15_190315_150831',...
'm15_190315_152315',...
'm26_190524_100859_cell1',...
'm26_190524_100859_cell2',...
'm41_190614_114301_cell2',...
'm41_190614_114301_cell3',...
'm52_190731_145204_cell3'};

numCellsPerRec = [1 1 1 1 1 1 1 1 1 ];
startTime = [0      205      294     398     707     0      0        37      0];
recDur =    [1119   1249     460     750     2248    105     497     262     2879]    ;
% % % {'m26_190524_100859',...
% % % 'm41_190614_114301',...
% % % 'm41_190621_125124',...
% % % 'm52_190725_142740',...
% % % 'm52_190731_145204'};
% % % 
% % % numCellsPerRec    = [3 4 1 1 3];
% % % 
% % % startTime   = [2614     6330    6841    13125   13781   14580   15045   2256    5400    2565    6170    9630];
% % % recDur      = [2966     210     2669    555     559     300     3555    1764    2100    795     1750    3030];

cellCount = 0;

for iSess = 1:length(splitSessions)
    basepath = fullfile('E:\Data\GroundTruth\',splitSessions{iSess});%'m52_190731_145204_cell3';
    cd(basepath)
    for iCell =1:numCellsPerRec(iSess)
        cellCount = cellCount+1 ;
        fnameIn     = [splitSessions{iSess} '.dat'];
        fnameOut    = [splitSessions{iSess} '_cellcut' num2str(iCell) '.dat'];
        fnameInAI     = [splitSessions{iSess} '_analogin.dat'];
        fnameOutAI    = [splitSessions{iSess} '_cellcut' num2str(iCell) '_analogin.dat'];
        
        CopyDat(fnameIn,fnameOut,'start',startTime(cellCount),'duration',recDur(cellCount))
        CopyDat(fnameInAI,fnameOutAI,'start',startTime(cellCount),'duration',recDur(cellCount))
    end
end


