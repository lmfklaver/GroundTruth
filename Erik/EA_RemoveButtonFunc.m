function EA_RemoveButtonFunc(pop,btnStruct,btnHandle)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
fig_PointClick      = pop.fig;
txa1                = pop.txa1;
thisButton = btnStruct.(btnHandle);

PointerFuncState = getappdata(fig_PointClick,'PointerFuncState');
if strcmp(PointerFuncState,'remove')
    PointerFuncState = 'neutral';
set(thisButton,'Backgroundcolor',[0.94 0.94 0.94])
    txa1.Value = 'State set to Neutral';
else
PointerFuncState = 'remove';
set(thisButton,'Backgroundcolor','r');
txa1.Value = 'Click to Remove Juxtas';
end


setappdata(fig_PointClick,'PointerFuncState',PointerFuncState);
end

