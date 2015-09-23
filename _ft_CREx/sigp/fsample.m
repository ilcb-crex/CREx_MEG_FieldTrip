function fs = fsample(timevect)

if iscell(timevect)
    timevect = timevect{1};
end

try
    fs = (length(timevect)-1)/(max(timevect)-min(timevect));
catch 
    fs = [];
    disp('Impossible to compute sample frequency from input time vector')
end
