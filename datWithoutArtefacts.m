function out = datWithoutArtefacts(basepath,fnameIn,fnameOut, nChans) % nChans per .dat?

  %
  %   This function is designed to make a new .dat file from "data" derived via bz_LoadBinary
  %   I cannot remember why i made this function (LK). Probably to remove noise and create a new .dat file to run
  %   Kilosort over or something
  %
  %
  %   USAGE
  %
  %   %% Dependencies %%%
  %   Buzcode
  %
  %   INPUTS
  %   'basepath'          -
  %   'data     '         -
  %   'nChans'            -
  %
  %   OUTPUTS
  %   out        -
  %
  %   HISTORY
  %   2021-01 - Lianne documented
  %
  %

  %% Parse!
  if ~exist('basepath','var')
      basepath = pwd;
  end

  basename = bz_BasenameFromBasepath(basepath);

  p = inputParser;
  addParameter(p,'basename',basename,@isstr);

  parse(p,varargin{:});
  basename        = p.Results.basename;
  


  cd(basepath)


  %%
%% bz_LoadBinary things
% data = bz_LoadBinary

for iChan=1:nChans
    rawTrace(iChan,:) = data(:,iChan);
end

int16RawTrace = int16(rawTrace);

intRawVec = zeros((size(int16RawTrace,1)*size(int16RawTrace,2)),1);
intRawVec = int16RawTrace(:);


%%remove your artifacts here needs to be superchanged
% % 
% % for i = 1:size(artefact,1)
% %     duration = artefact(i,2)-artefact(i,1);
% %     nBytes = round(syst.SampleRate*duration);
% %     
% %     start = floor(artefact(i,1)*syst.SampleRate)*syst.nChannels*sizeInBytes;
% %     status = fseek(fidI,start,'bof');
% %     if status ~= 0,
% %         error('Could not start reading (possible reasons include trying to read a closed file or past the end of the file).');
% %     end
% %     
% %     
% %     
% %     dat = fread(fidI,nbChan*nBytes,'int16');
% %     dat = reshape(dat,[nbChan nBytes]);
% %     n = size(dat,2);
% %     
% %     for ii = 1:size(dat,1)
% %         dat(ii,:) =  interp1([1 n],[dat(ii,1) dat(ii,end)],1:n);
% %     end
% %    
% %     dat = int16(dat(:));
% % 
% % end


% cd(resultDir)
fileID = fopen([char(basename), '.dat'], 'w');
fwrite(fileID, intRawVec, 'int16')
fclose(fileID)
clear data rawTrace intRawTrace intRawVec

out = 1;
end
