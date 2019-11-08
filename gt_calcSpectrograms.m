function [cco_duration, cco_data, normdata]=gt_calcSpectrograms(pathInfo,lfp_extra, cco_indexvector,opts)
%working on this: should contain "get lfp matrices, calculate spectrograms,
%normalize spectrograms"

BLtimVec = opts.bltimvec;

for ii= 1:length(cco_indexvector.matches)
    % Extracellular LFP centered on juxtaspike
    if cco_indexvector.matches(ii)-opts.timWinWavespec < 0 || cco_indexvector.matches(ii)-BLtimVec < 0
        continue
    else
        cco_duration.matches(:,ii) = lfp_extra.timestamps(cco_indexvector.matches(ii)-opts.timWinWavespec:cco_indexvector.matches(ii)+opts.timWinWavespec);
        cco_data.matches(:,ii) = lfp_extra.data(cco_indexvector.matches(ii)-opts.timWinWavespec:cco_indexvector.matches(ii)+opts.timWinWavespec);
        cco_duration.matchBL(:,ii) = lfp_extra.timestamps(cco_indexvector.matches(ii)-BLtimVec:cco_indexvector.matches(ii)-opts.timWinWavespec); %
        cco_data.matchBL(:,ii) = lfp_extra.data(cco_indexvector.matches(ii)-BLtimVec:cco_indexvector.matches(ii)-opts.timWinWavespec);%
    end
end

for ii = 1:length(cco_indexvector.om) %5255
    if cco_indexvector.om(ii)-opts.timWinWavespec < 0 || cco_indexvector.om(ii)-BLtimVec < 0 ... 
            || cco_indexvector.om(ii)+ opts.timWinWavespec > length(lfp_extra.timestamps) || cco_indexvector.om(ii)+BLtimVec > length(lfp_extra.timestamps)
        continue
    else
        % Extracellular LFP centered on juxtaspike
        cco_duration.omission(:,ii) = lfp_extra.timestamps(cco_indexvector.om(ii)-opts.timWinWavespec:cco_indexvector.om(ii)+opts.timWinWavespec);
        cco_data.omission(:,ii) = lfp_extra.data(cco_indexvector.om(ii)-opts.timWinWavespec:cco_indexvector.om(ii)+opts.timWinWavespec);
        cco_duration.omissionBL(:,ii) = lfp_extra.timestamps(cco_indexvector.om(ii)-BLtimVec:cco_indexvector.om(ii)-opts.timWinWavespec); %
        cco_data.omissionBL(:,ii) = lfp_extra.data(cco_indexvector.om(ii)-BLtimVec:cco_indexvector.om(ii)-opts.timWinWavespec);%
    end
end

for ii = 1:length(cco_indexvector.com)
    if cco_indexvector.com(ii)-opts.timWinWavespec < 0 || cco_indexvector.com(ii)-BLtimVec < 0
        continue
    else
        % Extracellular LFP centered on extraspike
        cco_duration.commission(:,ii) = lfp_extra.timestamps(cco_indexvector.com(ii)-opts.timWinWavespec:cco_indexvector.com(ii)+opts.timWinWavespec);
        cco_data.commission(:,ii) = lfp_extra.data(cco_indexvector.com(ii)-opts.timWinWavespec:cco_indexvector.com(ii)+opts.timWinWavespec);
        cco_duration.commissionBL(:,ii) = lfp_extra.timestamps(cco_indexvector.com(ii)-BLtimVec:cco_indexvector.com(ii)-opts.timWinWavespec); %
        cco_data.commissionBL(:,ii) = lfp_extra.data(cco_indexvector.com(ii)-BLtimVec:cco_indexvector.com(ii)-opts.timWinWavespec);%
    end
end

%% Replace .data and .timestamps of channel lfp
%make copies of big files so can manipulate them seperately

cd(pathInfo.RecPath); % hi Reagan, somehow, this changed over functions between a lowercase p to a higher case p. should work now.

%make copies of lfp files
lfp_com_error       = lfp_extra;
lfp_om_error        = lfp_extra; % CHANGED THIS FROM LFP_JUXTA TO LFP_EXTRA!!
lfp_matches         = lfp_extra;
lfp_matches_bl      = lfp_extra;
lfp_om_error_bl     = lfp_extra;
lfp_com_error_bl    = lfp_extra;

clear lfp_extra

%matches
lfp_matches.timestamps = cco_duration.matches;
lfp_matches.data       = cco_data.match;
lfp_matches_bl.timestamps = cco_duration.matchBL;
lfp_matches_bl.data       = cco_data.matchBL;

%omission error
lfp_om_error.timestamps     = cco_duration.omission;
lfp_om_error.data           = cco_data.omission;
lfp_om_error_bl.timestamps  = cco_duration.omissionBL;
lfp_om_error_bl.data        = cco_data.omissionBL;

%commission error
lfp_com_error.timestamps    = cco_duration.commission;
lfp_com_error.data          = cco_data.commission;
lfp_com_error_bl.timestamps = cco_duration.commissionBL;
lfp_com_error_bl.data       = cco_data.commissionBL;

clear cco_duration cco_data

cco_duration = 1;
cco_data = 1;

fprintf('Done with getting cco_duration and cco_data, ready to calculate wavespec\n')
%% Loop wavespec over the columns(spikes) for each cell
freqRange   = opts.freqRange;
numFreqs    = opts.numFreqs;

% to run through each event set and run wavespec on it(assuming each collumn is a time stamp and each row is one of 501 time/data stamps)
[normdata.match] = getNormWavespecCCO(lfp_matches, lfp_matches_bl,freqRange,numFreqs);
disp('leggo')

% omission error
[normdata.om] = getNormWavespecCCO(lfp_om_error, lfp_om_error_bl,freqRange,numFreqs);
disp('almost there')

%commission error
[normdata.com] = getNormWavespecCCO(lfp_com_error, lfp_com_error_bl,freqRange,numFreqs);
disp('whoooo done')

if opts.doSave
    save normwavespecdata normdata
end


    function [normdata] = getNormWavespecCCO(lfp, lfp_bl,freqRange,numFreqs)
        wavespec_BL     = getWaveSpecCCO(lfp_bl,freqRange,numFreqs);%getWaveSpecCCO
        wavespec_avg_BL = mean(cat(3,wavespec_BL.data),3);
        clear lfp_bl wavespec_BL
        %normalizing
        avgFreq         = mean(mean(wavespec_avg_BL,3));
        clear wavespec_avg_BL
        normMat         = repmat(avgFreq,501,1);
        wavespec        = getWaveSpecCCO(lfp,freqRange, numFreqs);%getWaveSpecCCO
        clear lfp
        wavespec_avg    = mean(cat(3,wavespec.data),3); %concatenate all the matches in the struct, get the average over those matches
        clear wavespec
        normdata  = wavespec_avg./normMat;
    end

end
