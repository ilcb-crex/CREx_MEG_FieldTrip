function [filtData,filtopt] = meg_filt_dataset(rawData,filtopt)

filtData=[];
if nargin<2 || ~isfield(filtopt,'type')
    filtopt = meg_filtopt('ask');
end
if ~isfield(filtopt,'fc') || isempty(filtopt.fc) || ...
    (numel(filtopt.fc)==1 && filtopt.fc==0)...
    || numel(filtopt.fc)>2
    filtopt = meg_filtopt(filtopt);
end

fc=filtopt.fc;
fopt=filtopt.type;

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