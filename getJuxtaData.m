function juxtadata = getJuxtaData(basepath, basename, ops, params)


nIntervals = size(ops.intervals,1);

for i = 1:nIntervals
       
    juxtadata(i).duration = (ops.intervals(i,2)-ops.intervals(i,1));
    juxtadata(i).interval = [ops.intervals(i,1) ops.intervals(i,2)];
    
    juxtadata.data = bz_LoadBinary([basepath filesep basename], ...
    'duration',double(juxtadata(i).duration'),...
    'channels', params.juxtachan,...
    'frequency', params.sampFreq, ...
    'nChannels',params.nChans,... % sessionInfo.nChannels        
    'start',double(juxtadata(i).interval(1)),...
    'downsample', ops.downsamplefactor);

    juxtadata.times = [juxtadata(i).interval(1):(1/params.sampFreq):...
        (juxtadata(i).interval(1)+(length(juxtadata(i).data)-1)/...
        params.sampFreq)]';
    
    juxtadata.channels = params.juxtachan;
    juxtadata.samplingRate = params.sampFreq;
    
     if juxtadata(i).interval(2) == inf
        juxtadata(i).interval(2) = length(juxtadata(i).times)/juxtadata(i).samplingRate;
        juxtadata(i).duration = (juxtadata(i).interval(i,2)-juxtadata(i).interval(i,1));
    end
end

