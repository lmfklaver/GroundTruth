function [fig_PointClick,btnStruct,ax1,ax2,txa1,txa2,lbl4] = EA_MakePointClickFig(numButton)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

fig_PointClick = uifigure;

set(0,'units','pixels')  ;
Pix_SS = get(0,'screensize');
figLength = Pix_SS(3);
figWidth = Pix_SS(4) - 70;
fig_PointClick.Position(1:4) = [0,40,figLength, figWidth];
figGrid.x = ((1:20)*figLength)/20;
figGrid.y = ((1:20)*figWidth)/20;

ax1 = uiaxes(fig_PointClick,'Position',[figGrid.x(2) figGrid.y(1) figGrid.x(1)*17 figGrid.y(1)*3]);
setappdata(fig_PointClick,'ax1',ax1);
ax2 = uiaxes(fig_PointClick,'Position',[figGrid.x(2) figGrid.y(1)*4.25 figGrid.x(1)*17 figGrid.y(1)*15]);
txa1 = uitextarea(fig_PointClick);
txa1.Position = [round(figGrid.x(1)*0.25), figGrid.y(1)*(2*(numButton + 1)+1.25),...
                round(figGrid.x(1)*0.25)*6,figGrid.y(1)*1.5];
txa2 = uitextarea(fig_PointClick);
txa2.Position = [round(figGrid.x(1)*0.25), figGrid.y(1)*(2*(numButton + 0)+1.25),...
                round(figGrid.x(1)*0.25)*6,figGrid.y(1)*0.5];
lbl1 = uilabel(fig_PointClick);
lbl1.Text = 'Message Readout:';
lbl1.Position = [round(figGrid.x(1)*0.25), figGrid.y(1)*(2*(numButton + 1)+2.75),...
                round(figGrid.x(1)*0.25)*6,figGrid.y(1)*0.5];
lbl2 = uilabel(fig_PointClick);
lbl2.Text = 'Input Time-Point:';
lbl2.Position = [round(figGrid.x(1)*0.25), figGrid.y(1)*(2*(numButton + 0)+1.75),...
                round(figGrid.x(1)*0.25)*6,figGrid.y(1)*0.5];
lbl3 = uilabel(fig_PointClick);
lbl3.Text = 'Current Spike:';
lbl3.Position = [figGrid.x(1)*2.5 figGrid.y(1)*19.3 figGrid.x(1) figGrid.y(1)*0.5];
lbl4 = uilabel(fig_PointClick);
lbl4.Text = '1/1000';
lbl4.Position = [figGrid.x(1)*3.5 figGrid.y(1)*19.3 figGrid.x(1) figGrid.y(1)*0.5];


setappdata(fig_PointClick,'ax2',ax2);
plot(ax1,[]);
plot(ax2,[]);

for iBtn = 1:numButton
    
    numStr = num2str(iBtn);
    btnStr = [ 'a' numStr];
    
    btn = uibutton(fig_PointClick,'push','Position',[round(figGrid.x(1)*0.25),...
    figGrid.y(1)*(2*(numButton - iBtn)+1.25),...
    round(figGrid.x(1)*0.25)*6,...
    figGrid.y(1)]);
    btnStruct.(btnStr) = btn;
    
    
end



end

