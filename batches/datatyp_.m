
% Detection of the data type according to the 
% 
% Data that are processed by ft_CREx toolbox are FieldTrip data structures 
% that could be substructures of a structure containing Condition names as
% first field level :
% Example considering a design with two conditions, "Morpho" and "Ortho"
% allTrials.Morpho = {ft_struct with time and trial fields...}
% allTrials.Ortho = {ft_struct with time and trial fields...}
% That is the case once the trials are extracted from the continuous data
% set.
%
% Continuous data 