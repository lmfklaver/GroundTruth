function [outputArg1,outputArg2] = Make_PlaceField_EC(inputArg1,inputArg2)
%UNTITLED8 Summary of this function goes here
%   Detailed explanation goes here

% All this function takes in is the Spikes struct, the JuxtaData.times, and
% the LapCounter start/stop times

% All this function outputs is 1) a figure which displays the spike count
% per time bin for each cell. Each row will contain the cumulative spike
% count from all laps.
% Here we also account for occupancy. 2) a struct which contains 2a) a cell
% array where each cell represents a unit
% and contains an nx2 matrix for the spike count of each time bin. 2b) the
% same but accounting for occupancy.


%  a seperate nested function should be charged with sorting the spike
%  times of each unit into a position bin 

  




outputArg1 = inputArg1;
outputArg2 = inputArg2;
end

