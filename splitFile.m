function splitFile(excelDoc)
%find the excel doc
excelPath = fullfile(['C:\Users\Englishlab\Documents\R_Neur\', excelDoc]);
%read the excel doc into a struct
recordingsGT = table2struct(readtable(excelPath));

indexCell = 1;
numRecs = length(recordingsGT);

for imice = 1:numRecs
    %find the amplifier folder 
    ampDir = ['C:\Data\' recordingsGT(indexCell).mouse '_' recordingsGT(indexCell).session];
    cd(ampDir)
   fnameIn = 'amplifier.dat'; %
  %save it as mouse name, day, and time
   fnameOut =  [recordingsGT(indexCell).mouse '_' recordingsGT(indexCell).session '_' num2str(recordingsGT(indexCell).cell) '.dat']; %fullfile(['C:\Data\' recordingsGT(indexCell).mouse '_' recordingsGT(indexCell).session '\'
   %fnameOut = fullfile(cd, [recordingsGT(index).mouse '_' recordingsGT(index).session '_' recordingsGT(index).cell]);
   %define inputs from excel doc
   start = recordingsGT(indexCell).start;
   duration = recordingsGT(indexCell).dur;
   probeNum = recordingsGT(indexCell).probe;
   % account for whether using 4 site probe or 32 site probe
   if probeNum == 4
       CopyDat(fnameIn, fnameOut,'duration',duration, 'start', start, 'ChannelIx', [1 2 3 4 5]);
   else 
       CopyDat(fnameIn, fnameOut,'duration',duration, 'start', start, 'ChannelIx', (1:33));
   end
   %make a new folder for each cell
   outPath = ['C:\Data\' recordingsGT(indexCell).mouse '_' recordingsGT(indexCell).session];
   
   newFolder = [outPath '\' recordingsGT(indexCell).mouse '_' recordingsGT(indexCell).session '_' num2str(recordingsGT(indexCell).cell)];
   
   mkdir(newFolder);
   
   movefile(fnameOut, newFolder)
   
   
   %account for looping
   numRecs = numRecs - 1;
   indexCell = indexCell + 1;
   
end
end

%problem with fwrite, suggests may be problem with fnameOut??? 
