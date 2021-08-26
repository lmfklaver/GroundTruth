function EA_AddButtonFunc(pop,btnStruct,btnHandle)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
fig_PointClick      = pop.fig;
txa1                = pop.txa1;
thisButton = btnStruct.(btnHandle);

PointerFuncState = getappdata(fig_PointClick,'PointerFuncState');
if strcmp(PointerFuncState,'add')
    PointerFuncState = 'neutral';
set(thisButton,'Backgroundcolor',[0.94 0.94 0.94])
    txa1.Value = 'State set to Neutral';
else
PointerFuncState = 'add';
set(thisButton,'Backgroundcolor','g');
txa1.Value = 'Click to Add Juxtas';
end


setappdata(fig_PointClick,'PointerFuncState',PointerFuncState);
end

