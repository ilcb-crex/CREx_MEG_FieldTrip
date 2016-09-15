function fs = sampfreq(timevect)
% Compute the sampling frequency from a time vector
% If timevect is a cell, only the first element (timevect{1}) is used for
% sample frequency calculation
%
% -- CREx 2012 
% https://github.com/chris-zielinski/MEG_FieldTrip_CREx

if iscell(timevect)
    timevect = timevect{1};
end

try
    fs = (length(timevect)-1)/(max(timevect)-min(timevect));
catch 
    fs = [];
    disp('Impossible to compute sample frequency from the input time vector')
end
