function [filtData,filtopt] = meg_filt_dataset(rawData,filtopt)
% Sub-function to launch the filtering by ft_preprocessing FieldTrip function
% The order of the filters are included as fixed parameters with a value = 2.
% If no cut-off frequency is given in the filtopt.fc field or if only one
% value is store for band-pass filter, the missing values are asking on the 
% command windows.
%
%-CREx 20140520 
%-CREx-BLRI-AMU project: https://github.com/blri/CREx_MEG_FieldTrip

filtData = [];
if nargin<2 || ~isfield(filtopt,'type')
    filtopt = meg_filtopt('ask');
end
if ~isfield(filtopt,'fc') || isempty(filtopt.fc) || ...
    (numel(filtopt.fc)==1 && filtopt.fc==0)...
    || numel(filtopt.fc) > 2
    filtopt = meg_filtopt(filtopt);
end

fc = filtopt.fc;
fopt = filtopt.type;

cfg=[];

switch lower(fopt)
    case 'none'     
        return
    case 'hp'
        if numel(fc)==2
            fc=fc(1);
        end
        cfg.hpfilter = 'yes';
        cfg.hpfiltord = 2;
        cfg.hpfreq   = fc;
    case 'lp'
        if numel(fc)==2
            fc=fc(2);
        end     
        cfg.lpfilter = 'yes';
        cfg.lpfiltord = 2;
        cfg.lpfreq   = fc;
    case 'bp'
        if numel(fc)<2
            [T,fc] = meg_filtopt(fopt); %#ok
        end     
        cfg.bpfilter = 'yes';
        cfg.bpfiltord = 2;
        cfg.bpfreq   = fc;    
end

filtData = ft_preprocessing(cfg,rawData);