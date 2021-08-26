function EA_NextButtonFunc(pop)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fig_PointClick      = pop.fig;
JuxtaSpikesTimes    = pop.jSpkTimes;
ax1                 = pop.ax1;
ax2                 = pop.ax2;
samplingFreq        = pop.sampFreq;
juxtadata           = pop.jData;
rWinEdge            = pop.rWinEdge;
lWinEdge            = pop.lWinEdge;
txa1                = pop.txa1;  
lbl4                = pop.lbl4;

theseJuxtas = getappdata(fig_PointClick,'theseJuxtas');

% iSpike = find(JuxtaSpikesTimes > theseJuxtas(end), 1);

if(theseJuxtas(end) < JuxtaSpikesTimes(end))
iSpike = find(JuxtaSpikesTimes > theseJuxtas(end), 1);%normal
elseif(theseJuxtas(end) >= JuxtaSpikesTimes(end))
iSpike = length(JuxtaSpikesTimes);%exceeding upper bounds
txa1.Value = 'Last Spike Reached';
end

setappdata(fig_PointClick,'iSpike',iSpike);

currSpkTime = JuxtaSpikesTimes(iSpike);

lowWinLength = round(rWinEdge*samplingFreq); %in indices. Time = 50 ms
upWinLength =  round(lWinEdge*samplingFreq); %in indices. Time = 100 ms
%can make the window lengths editable using parser

currDataInx = round(samplingFreq * currSpkTime);

lowWinBound = juxtadata.times(currDataInx - lowWinLength); %need to have out of bound cases
if (currDataInx + upWinLength)<= round(juxtadata.times(end)*samplingFreq)
upWinBound = juxtadata.times(currDataInx + upWinLength); %why do you use 
elseif (currDataInx + upWinLength)> round(juxtadata.times(end)*samplingFreq)
upWinBound = juxtadata.times(end);
end
juxtaInx = find(JuxtaSpikesTimes >= lowWinBound & JuxtaSpikesTimes <= upWinBound);
theseJuxtas = JuxtaSpikesTimes(juxtaInx);
setappdata(fig_PointClick,'theseJuxtas',theseJuxtas);

xlim(ax2,[lowWinBound upWinBound]);
xlim(ax1,[lowWinBound upWinBound]);


lbl4.Text = [num2str(iSpike) '/' num2str(length(pop.jSpkTimes))];

% disp('High Speed Low Drag')


% EA_PopulatePointClick(pop)

end

