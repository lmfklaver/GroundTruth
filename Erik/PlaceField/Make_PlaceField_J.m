function [outputArg1,outputArg2] = Make_PlaceField_J(inputArg1,inputArg2)
%UNTITLED4 Summary of this function goes here

% All this function should take is the LapCounter start/stop times,
% JuxtaData.times, and JuxtaSpikes.times

% All this function should output is 1) a figure displaying the spike count
% across position bins for each lap 2) a cumulative spike count across the
% same positions across all laps. 3) a struct containing 3a1) a cell array
% containing a cell for each lap where each cell holds an nx2 matrix of the
% position bin and the spike count. 3a2) the same but with spike count
% adjusted for occupancy. 3b1) an nx2 matrix of the position bin and the
% spike count 3b2) the same but with spike count adjusted for occupancy.

getWheelTrials(analogin)


outputArg1 = inputArg1;
outputArg2 = inputArg2;

end

