fig = openfig('testfig.fig')
%%
fig = gcf;
axObjs = fig.Children;
dataObjs = axObjs.Children;
% dataObjs = findobj(fig,'-property','YData')
lineObjs = findobj(dataObjs, 'type', 'line')
%xdata = get(lineObjs, 'XData');

ydata = [];
ydata = get(lineObjs, 'YData');

newY = [];
for i = 1:length(ydata)
    newY(i,:) = ydata{i}
end