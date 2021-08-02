function juxtadata = getJuxtaTime(intervals, juxtadata)


nIntervals = size(intervals,1);
for i = 1:nIntervals
    
    juxtadata(i).duration = (intervals(i,2)-intervals(i,1));
    juxtadata(i).interval = [intervals(i,1) intervals(i,2)];
    
    
    juxtadata.timestamps = [juxtadata(i).interval(1):(1/juxtadata.samplingFreq):...
        (juxtadata(i).interval(1)+(length(juxtadata(i).data)-1)/...
        juxtadata.samplingFreq)]';
end
