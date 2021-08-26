function EA_TextAreaFunc(pop)
%UNTITLED10 Summary of this function goes here
%   Detailed explanation goes here
txa2                = pop.txa2;
txa1                = pop.txa1;
JuxtaSpikesTimes    = pop.jSpkTimes;
juxtadata           = pop.jData;
rWinEdge            = pop.rWinEdge;
lWinEdge            = pop.lWinEdge;
samplingFreq        = pop.sampFreq;
fig_PointClick      = pop.fig;
ax1                 = pop.ax1;
ax2                 = pop.ax2;
lbl4                = pop.lbl4;

    val = txa2.Value;
    
    if length(val{1}) >= 11 && strcmp(val{1}(1:11),'Spike First')
        timePoint = JuxtaSpikesTimes(1);
    elseif length(val{1}) >= 10 && strcmp(val{1}(1:10),'Spike Last')
        timePoint = JuxtaSpikesTimes(end);
    elseif length(val{1}) >= 5 && strcmp(val{1}(1:5),'Spike')
        if isnan(str2double(val{1}(7:end)))
            txa1.Value = 'Enter Valid Number in (Spike Indices)';
            return
        elseif str2double(val{1}(7:end)) > length(JuxtaSpikesTimes)
            timePoint = JuxtaSpikesTimes(end);
        elseif str2double(val{1}(7:end)) < 1
            timePoint = JuxtaSpikesTimes(1);
        else
            timePoint = JuxtaSpikesTimes(str2double(val{1}(7:end)));
        end
    else
        timePoint = str2double(val{1});
        if isnan(timePoint)
            txa1.Value = 'Enter Valid Number in (Seconds). Type Spike to enter spike index';
            return
        end
    end
    
    if (timePoint <= juxtadata.times(1))
        timePoint = juxtadata.times(2);
    end
    if(timePoint >= juxtadata.times(end))
        timePoint = juxtadata.times(end-1);
    end

currDataInx = round(timePoint*samplingFreq);
currJuxtaTimes = juxtadata.times(round(timePoint*samplingFreq));
    
lowWinLength = round(rWinEdge*samplingFreq); %in indices. Time = 50 ms
upWinLength =  round(lWinEdge*samplingFreq); %in indices. Time = 100 ms

if(currDataInx - lowWinLength)>= round(juxtadata.times(1)*samplingFreq)
lowWinBound = juxtadata.times(currDataInx - lowWinLength); %if normal
elseif(currDataInx - lowWinLength)< round(juxtadata.times(1)*samplingFreq)
lowWinBound = juxtadata.times(1); %if exceeding lower bound
end
if (currDataInx + upWinLength)<= round(juxtadata.times(end)*samplingFreq)
upWinBound = juxtadata.times(currDataInx + upWinLength); %if normal
elseif (currDataInx + upWinLength)> round(juxtadata.times(end)*samplingFreq)
upWinBound = juxtadata.times(end); %if exceeding upper bound
end

juxtaInx = find(JuxtaSpikesTimes>= lowWinBound & JuxtaSpikesTimes <= upWinBound);
theseJuxtas = JuxtaSpikesTimes(juxtaInx);

if (~isempty(theseJuxtas))
    [~,closetsJuxta] = min(abs(theseJuxtas - currJuxtaTimes));%check for columns
    iSpike = find(JuxtaSpikesTimes == theseJuxtas(closetsJuxta),1);
elseif(isempty(theseJuxtas))
    theseJuxtas = currJuxtaTimes;
    iSpike = [];
end

xlim(ax2,[lowWinBound upWinBound]);
xlim(ax1,[lowWinBound upWinBound]);

lbl4.Text = [num2str(iSpike) '/' num2str(length(pop.jSpkTimes))];
setappdata(fig_PointClick,'iSpike',iSpike);
setappdata(fig_PointClick,'theseJuxtas',theseJuxtas);


end



