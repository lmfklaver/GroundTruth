function EA_PointAndClickAdventure(JuxtaSpikesTimes,basename)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

samplingFreq = 30000;
driftAdjFactor = 3;

if exist([basename '.juxtadata.mat'],'file')
    load([basename '.juxtadata.mat'],'juxtadata');
end

driftAdj = 1;
if driftAdj == 1
    JuxtaSpikesTimes = JuxtaSpikesTimes + (driftAdjFactor*(1/samplingFreq));
end

%% creating the uifigure
[fig_PointClick,btnStruct,ax1,ax2,txa1,txa2,lbl4] = EA_MakePointClickFig(5);

%% assigning functions to buttons

setappdata(fig_PointClick,'btnTestVar',3);
% btnnn = getappdata(fig_PointClick,'btnTestVar');


% btnnn = getappdata(fig_PointClick,'btnTestVar');

pop.fig         = fig_PointClick;
pop.sampFreq    = samplingFreq;
pop.jSpkTimes   = JuxtaSpikesTimes;
pop.jData       = juxtadata;
pop.ax1         = ax1;
pop.ax2         = ax2;
pop.txa1        = txa1;
pop.txa2        = txa2;
pop.rWinEdge    = 0.05;
pop.lWinEdge    = 0.1;
pop.basename    = basename;
pop.lbl4        = lbl4;

iSpikeInit = 1;
pop.lbl4.Text = [num2str(iSpikeInit) '/' num2str(length(pop.jSpkTimes))];
setappdata(fig_PointClick,'iSpike',iSpikeInit);
EA_PopulatePointClick(pop);
% EA_PopulatePointClick(fig_PointClick,samplingFreq,JuxtaSpikesTimes,juxtadata,ax1,ax2)

set(btnStruct.a1,'Text','NextCluster')
set(btnStruct.a1,'ButtonPushedFcn',@(btn,event) EA_NextButtonFunc(pop))
set(btnStruct.a2,'Text','PreviousCluster')
set(btnStruct.a2,'ButtonPushedFcn',@(btn,event) EA_PrevButtonFunc(pop))
set(btnStruct.a3,'Text','AddJuxtas');
set(btnStruct.a3,'ButtonPushedFcn',@(btn,event) EA_AddButtonFunc(pop,btnStruct,'a3'))
set(btnStruct.a4,'Text','RemoveJuxtas');
set(btnStruct.a4,'ButtonPushedFcn',@(btn,event) EA_RemoveButtonFunc(pop,btnStruct,'a4'))
set(btnStruct.a5,'Text','SaveJuxtas');
set(btnStruct.a5,'ButtonPushedFcn',@(btn,event) EA_SaveButtonFunc(pop))
% set(dcm_obj)
% set(txa2);
set(pop.txa2,'ValueChangedFcn',@(textarea,event) EA_TextAreaFunc(pop))

setappdata(fig_PointClick,'PointerFuncState','neutral');%default pointer state

setappdata(fig_PointClick,'addedJuxtas',[]);
setappdata(fig_PointClick,'addedScatters',[]);
setappdata(fig_PointClick,'xAdded',[]);
setappdata(fig_PointClick,'yAdded',[]);
setappdata(fig_PointClick,'addedRasters',[]);

setappdata(fig_PointClick,'removedJuxtas',[]);
setappdata(fig_PointClick,'removedScatters',[]);
setappdata(fig_PointClick,'xRemoved',[]);
setappdata(fig_PointClick,'yRemoved',[]);
setappdata(fig_PointClick,'removedRasters',[]);

dcm_obj = datacursormode(fig_PointClick);
dcm_obj.Enable = 'on';
set(dcm_obj,'updatefcn', {@myfunction,pop})

function output_txt = myfunction(~,event_obj,pop)
    % Display data cursor position in a data tip
    % obj          Currently not used
    % event_obj    Handle to event object
    % output_txt   Data tip text, returned as a character vector or a cell array of character vectors

    pos = event_obj.Position;
    

    %********* Define the content of the data tip here *********%

    % Display the x and y values:
    output_txt = {['X',formatValue(pos(1),event_obj)],...
        ['Y',formatValue(pos(2),event_obj)]};
    %***********************************************************%
    
    
    % If there is a z value, display it:
    if length(pos) > 2
        output_txt{end+1} = ['Z',formatValue(pos(3),event_obj)];
    end
    x = pos(1);
    y = pos(2);
    
    if (event_obj.Target.Parent == pop.ax1)
        y = pop.jData.data(find(abs(pop.jData.times - x) < 0.000001));
    end

    daFig = pop.fig;
    botAx = pop.ax1;
    topAx = pop.ax2;

    PointerFuncState = getappdata(daFig,'PointerFuncState');

    initPointsScatt = getappdata(daFig,'initPointsScatt');
    initPointsRast = getappdata(daFig,'initPointsRast');
    pAdded.addedJuxtas = getappdata(daFig,'addedJuxtas');    
    pAdded.addedScatters = getappdata(daFig,'addedScatters');
    pAdded.xAdded = getappdata(daFig,'xAdded');
    pAdded.yAdded = getappdata(daFig,'yAdded');
    pAdded.addedRasters = getappdata(daFig,'addedRasters');

    pRemoved.removedJuxtas = getappdata(daFig,'removedJuxtas');
    pRemoved.removedScatters = getappdata(daFig,'removedScatters');
    pRemoved.xRemoved = getappdata(daFig,'xRemoved');
    pRemoved.yRemoved = getappdata(daFig,'yRemoved');
    pRemoved.removedRasters = getappdata(daFig,'removedRasters');
    
    if strcmp(PointerFuncState,'add')
        PointAndClick_Added(pAdded,pop,x,y);
    elseif strcmp(PointerFuncState,'remove')
        PointAndClick_Removed(pRemoved,pop,x,y)
    elseif strcmp(PointerFuncState,'neutral')
    end

%     disp('cursor Working!');
%     initPointsRast.XData(end+1) = x;
%     disp(x)
%     disp(t)
%     didThisWork = getappdata(daFig,'addedJuxtas');
%     disp(didThisWork);
end

%***********************************************************%

function formattedValue = formatValue(value,event_obj)
% If you do not want TeX formatting in the data tip, uncomment the line below.
% event_obj.Interpreter = 'none';
if strcmpi(event_obj.Interpreter,'tex')
    valueFormat = ' \color[rgb]{0 0.6 1}\bf';
    removeValueFormat = '\color[rgb]{.25 .25 .25}\rm';
else
    valueFormat = ': ';
    removeValueFormat = '';
end
formattedValue = [valueFormat num2str(value,10) removeValueFormat];

end

end

