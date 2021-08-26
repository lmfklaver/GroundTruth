function EA_PrevButtonFunc(pop)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

fig_PointClick      = pop.fig;
JuxtaSpikesTimes    = pop.jSpkTimes;
ax1                 = pop.ax1;
ax2                 = pop.ax2;
samplingFreq        = pop.sampFreq;
juxtadata           = pop.jData;
lWinEdge            = pop.rWinEdge; % r/l intentionally switched for reverse window movement
rWinEdge            = pop.lWinEdge; % r/l intentionally switched for reverse window movement
txa1                = pop.txa1;     
lbl4                = pop.lbl4;
   
theseJuxtas = getappdata(fig_PointClick,'theseJuxtas');

if(theseJuxtas(1) > JuxtaSpikesTimes(1))
iSpike = find(JuxtaSpikesTimes < theseJuxtas(1), 1,'last');%normal
elseif(theseJuxtas(1) <= JuxtaSpikesTimes(1))
iSpike = 1;% exceeding upper bounds
txa1.Value = 'First Spike Reached';
end
% iSpike = find(JuxtaSpikesTimes < theseJuxtas(1), 1,'last');

setappdata(fig_PointClick,'iSpike',iSpike);

currSpkTime = JuxtaSpikesTimes(iSpike);

lowWinLength = round(rWinEdge*samplingFreq); %in indices. Time = 50 ms
upWinLength =  round(lWinEdge*samplingFreq); %in indices. Time = 100 ms
%can make the window lengths editable using parser

currDataInx = round(samplingFreq * currSpkTime);

if(currDataInx - lowWinLength)>= round(juxtadata.times(1)*samplingFreq)
lowWinBound = juxtadata.times(currDataInx - lowWinLength); %need to have out of bound cases
elseif(currDataInx - lowWinLength)< round(juxtadata.times(1)*samplingFreq)
lowWinBound = juxtadata.times(1);
end
upWinBound = juxtadata.times(currDataInx + upWinLength); %why do you use 
juxtaInx = find(JuxtaSpikesTimes >= lowWinBound & JuxtaSpikesTimes <= upWinBound);
theseJuxtas = JuxtaSpikesTimes(juxtaInx);
setappdata(fig_PointClick,'theseJuxtas',theseJuxtas);

xlim(ax2,[lowWinBound upWinBound]);
xlim(ax1,[lowWinBound upWinBound]);

lbl4.Text = [num2str(iSpike) '/' num2str(length(pop.jSpkTimes))];

% disp('Low Speed High Drag')
end

