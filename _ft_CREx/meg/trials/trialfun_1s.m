function [trl, event] = trialfun_1s(cfg)

% sets one event with trigger value 1 at the beggining of the data
% may be usefull for reading the whole data as one epoch or short data for
% head model requirements. yuval, Nov 2010
%
% needed
% cfg.dataset : file name
% cfg.trialdef.poststim : length of epoch, default - whole length.

hdr = ft_read_header(cfg.dataset);

event.type='TRIGGER';
event.sample=1;
event.value=1;
event.offset=[];
event.duration=[];


trl = [1 round(hdr.Fs) 0];

