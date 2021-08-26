function PointAndClick_Removed(pRemoved,pop,x,y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

removedJuxtas     = pRemoved.removedJuxtas;  
removedScatters   = pRemoved.removedScatters;
removedRasters    = pRemoved.removedRasters;
xRemoved          = pRemoved.xRemoved;
yRemoved          = pRemoved.yRemoved;
botAx             = pop.ax1;
topAx             = pop.ax2;
daFig             = pop.fig;
txa1              = pop.txa1;

if (~isempty(find(abs(pop.jSpkTimes-x) < 0.000001,1)))
    xStr = num2str(x,8);
    txa1.Value = ['Removing Spike Time: ' xStr ' (s)']; 
else
    xStr = num2str(x,8);
    txa1.Value = ['Time: ' xStr ' (s)' ' is not a Spike'];
    return
end

if(isempty(find(abs(removedJuxtas-x)< 0.000001,1)))
    removedJuxtas = [removedJuxtas x];
    setappdata(daFig,'removedJuxtas',removedJuxtas);
    
    xRemoved = [xRemoved x];
    yRemoved = [yRemoved y];
    setappdata(daFig,'xRemoved',xRemoved);
    setappdata(daFig,'yRemoved',yRemoved);
    
    if (~isempty(removedScatters))
        delete(removedScatters);
        delete(removedRasters);
    end
    
    hold(topAx, 'on')
    removedScatters = scatter(topAx,xRemoved,yRemoved,40,...
              'MarkerEdgeColor',[0.8 0 0],...
              'MarkerFaceColor',[0.9 0 0],...
              'LineWidth',1.5);   
    hold(topAx, 'off')
    hold(botAx, 'on')
    removedRasters = scatter(botAx,xRemoved,1,2000,'|','MarkerEdgeColor',[0.9 0 0],'LineWidth',1.25);
    hold(botAx, 'off')
    setappdata(daFig,'removedScatters',removedScatters);
    setappdata(daFig,'removedRasters',removedRasters);

elseif (~isempty(find(abs(removedJuxtas-x)< 0.000001,1)))
    removedScatters = getappdata(daFig,'removedScatters');
    removedRasters = getappdata(daFig,'removedRasters');

    xRemoved(find(abs(removedJuxtas-x)< 0.000001,1)) = [];
    yRemoved(find(abs(removedJuxtas-x)< 0.000001,1)) = [];
    setappdata(daFig,'xRemoved',xRemoved);
    setappdata(daFig,'yRemoved',yRemoved);
    removedJuxtas(find(abs(removedJuxtas-x)< 0.000001)) = [];
    setappdata(daFig,'removedJuxtas',removedJuxtas);
    
    delete(removedScatters);
    delete(removedRasters);
    hold(topAx, 'on')
    removedScatters = scatter(topAx,xRemoved,yRemoved,40,...
              'MarkerEdgeColor',[0.8 0 0],...
              'MarkerFaceColor',[0.9 0 0],...
              'LineWidth',1.5);   
    hold(topAx, 'off')
    hold(botAx, 'on')
    removedRasters = scatter(botAx,xRemoved,1,2000,'|','MarkerEdgeColor',[0.9 0 0],'LineWidth',1.25);
    hold(botAx, 'off')
    setappdata(daFig,'removedScatters',removedScatters);
    setappdata(daFig,'removedRasters',removedRasters);
%     getappdata(daFig,'addedJuxtas')
end

end

