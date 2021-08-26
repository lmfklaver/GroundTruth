function EA_PopulatePointClick(pop)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

fig_PointClick      = pop.fig;
samplingFreq        = pop.sampFreq;
JuxtaSpikesTimes    = pop.jSpkTimes;
juxtadata           = pop.jData;
ax1                 = pop.ax1;
ax2                 = pop.ax2;
rWinEdge            = pop.rWinEdge;
lWinEdge            = pop.lWinEdge;

iSpike = getappdata(fig_PointClick,'iSpike');
currSpkTime = JuxtaSpikesTimes(iSpike);

lowWinLength = round(rWinEdge*samplingFreq); %in indices. Time = 50 ms
upWinLength =  round(lWinEdge*samplingFreq); %in indices. Time = 100 ms
%can make the window lengths editable using parser

currDataInx = round(samplingFreq * currSpkTime);


lowWindowInx = currDataInx - lowWinLength;
if (lowWindowInx < 1)
    lowWindowInx = 1;
end

lowWinBound = juxtadata.times(lowWindowInx); %need to have out of bound cases
upWinBound = juxtadata.times(currDataInx + upWinLength); %why do you use 
juxtaInx = find(JuxtaSpikesTimes>= lowWinBound & JuxtaSpikesTimes <= upWinBound);
theseJuxtas = JuxtaSpikesTimes(juxtaInx);
% juxtaInx2 = find(juxtaSpikes.times{1}>= lowWinBound & juxtaSpikes.times{1} <= upWinBound);

plot(ax2,juxtadata.times,juxtadata.data,'LineWidth',1.25);
xlim(ax2,[lowWinBound upWinBound]);
z = round(JuxtaSpikesTimes(:)*samplingFreq); %Took this out
hold(ax2,'on')
initPointsScatt = scatter(ax2,JuxtaSpikesTimes(:),juxtadata.data(z),40,...
              'MarkerEdgeColor',[0.8 .32 0],...
              'MarkerFaceColor',[1 .4 0],...
              'LineWidth',1.5);
setappdata(fig_PointClick,'initPointsScatt', initPointsScatt);
% scatter(ax2,JuxtaSpikesTimes(juxtaInx),juxtadata.data(z)); %Took this out
hold(ax2,'off')
xlim(ax2,[lowWinBound upWinBound]);

initPointsRast = scatter(ax1,JuxtaSpikesTimes(:),(JuxtaSpikesTimes(:)*0)+1,2000,'|','LineWidth',1.25);%Took this out
setappdata(fig_PointClick,'initPointsRast', initPointsRast);
% % % xline(ax1,JuxtaSpikesTimes(:),'b');
% xline(ax1,JuxtaSpikesTimes(juxtaInx),'b');
% xline(juxtaSpikes.times{1}(juxtaInx2),'g');
xlim(ax1,[lowWinBound upWinBound]);
setappdata(fig_PointClick,'theseJuxtas',theseJuxtas);

end

