function PointAndClick_Added(pAdded,pop,x,y)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

addedJuxtas     = pAdded.addedJuxtas;  
addedScatters   = pAdded.addedScatters;
addedRasters    = pAdded.addedRasters;
xAdded          = pAdded.xAdded;
yAdded          = pAdded.yAdded;
botAx           = pop.ax1;
topAx           = pop.ax2;
daFig           = pop.fig;

if(isempty(find(abs(addedJuxtas-x)< 0.000001,1)))
    addedJuxtas = [addedJuxtas x];
    setappdata(daFig,'addedJuxtas',addedJuxtas);
    
    xAdded = [xAdded x];
    yAdded = [yAdded y];
    setappdata(daFig,'xAdded',xAdded);
    setappdata(daFig,'yAdded',yAdded);
    
    if (~isempty(addedScatters))
        delete(addedScatters);
        delete(addedRasters);
    end
    
    hold(topAx, 'on')
    addedScatters = scatter(topAx,xAdded,yAdded,40,...
              'MarkerEdgeColor',[0 .8 0],...
              'MarkerFaceColor',[0 .9 0],...
              'LineWidth',1.5);   
    hold(topAx, 'off')
    hold(botAx, 'on')
    addedRasters = scatter(botAx,xAdded,1,2000,'|','MarkerEdgeColor',[0 .9 0],'LineWidth',1.25);
    hold(botAx, 'off')
    setappdata(daFig,'addedScatters',addedScatters);
    setappdata(daFig,'addedRasters',addedRasters);

elseif (~isempty(find(abs(addedJuxtas-x)< 0.000001,1)))
    addedScatters = getappdata(daFig,'addedScatters');
    addedRasters = getappdata(daFig,'addedRasters');

    xAdded(find(abs(addedJuxtas-x)< 0.000001,1)) = [];
    yAdded(find(abs(addedJuxtas-x)< 0.000001,1)) = [];
    setappdata(daFig,'xAdded',xAdded);
    setappdata(daFig,'yAdded',yAdded);
    addedJuxtas(find(abs(addedJuxtas-x)< 0.000001)) = [];
    setappdata(daFig,'addedJuxtas',addedJuxtas);
    
    delete(addedScatters);
    delete(addedRasters);
    hold(topAx, 'on')
    addedScatters = scatter(topAx,xAdded,yAdded,40,...
              'MarkerEdgeColor',[0 .8 0],...
              'MarkerFaceColor',[0 .9 0],...
              'LineWidth',1.5);   
    hold(topAx, 'off')
    hold(botAx, 'on')
    addedRasters = scatter(botAx,xAdded,1,2000,'|','MarkerEdgeColor',[0 .9 0],'LineWidth',1.25);
    hold(botAx, 'off')
    setappdata(daFig,'addedScatters',addedScatters);
    setappdata(daFig,'addedRasters',addedRasters);
%     getappdata(daFig,'addedJuxtas')
end


end

