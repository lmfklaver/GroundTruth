function PointAndClickCursor(obj,event_obj)
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

disp('cursor Working!');

% If there is a z value, display it:
if length(pos) > 2
    output_txt{end+1} = ['Z',formatValue(pos(3),event_obj)];
end

