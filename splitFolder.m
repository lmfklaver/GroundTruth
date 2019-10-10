function splitFolder (excelDoc)
which Copydat
edit Copydat

%find the excel doc
excelPath = fullfile(['C:\Users\Englishlab\Documents\R_Neur\', excelDoc]);
%read the excel doc into a struct
recordingsGT = table2struct(readtable(excelPath));

index = 1;
x = length(recordingsGT);

for imice = 1:x
    %find the amplifier folder 
   fnameIn = fullfile(['C:\Data\' recordingsGT(index).mouse '_' recordingsGT(index).session '\amplifier.dat']);
  %save it as mouse name, day, and time
   fnameOut = fullfile(cd, [recordingsGT(index).mouse '_' recordingsGT(index).session '_' recordingsGT(index).cell]);
   %define inputs from excel doc
   start = recordingsGT(index).start;
   duration = recordingsGT(index).dur;
   probeNum = recordingsGT(index).probe;
   % account for whether using 4 site probe or 32 site probe
   if probeNum == 4
       CopyDat(fnameIn, fnameOut,'duration',duration, 'start', start, 'ChannelIx', [1 2 3 4 5]);
   else 
       CopyDat(fnameIn, fnameOut,'duration',duration, 'start', start, 'ChannelIx', [1:33]);
   end
   %make a new folder for each cell
   mkdir(fnameOut);
   cd(fnameOut);
   save workspace;
   %account for looping
   x = x - 1;
   index = index + 1;
   
end
end
