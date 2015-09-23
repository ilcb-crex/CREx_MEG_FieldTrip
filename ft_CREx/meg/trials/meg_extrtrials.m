function trials = meg_extrtrials(dft, Sevent, contData)

% Field of specific options needed for ft_definetrial
% dft.trialfun : name of specific function [default :'ft_trialfun_general']
% dft.datafile : data path, mandatory if the default trialfun is using
% dft.prestim : time before stimulus (s) [default : .5]
% dft.postim : time after stimulus (s) [default : 1]
% dft.trig : structure of trigger definition with fields :
%           value     : trigger values **
%           eventyp   : type of events [default : 'TRIGGER']
%           rightresp : code of trigger for right responses if needed
%
% Sevent : structures of events as obtained by ft_read_event **
% contData : continuous data **
%
% (** Mandatory variables)
% ---

%---
% Check dft structure - put default value if missing field 

defdft = struct('prestim',.5,'postim',1,'trialfun','ft_trialfun_general',...
    'eventyp','TRIGGER','resptyp','RESPONSE');
fnames = fieldnames(defdft);
for n = 1:length(fnames)
    if ~isfield(dft,fnames{n}) || isempty(dft.(fnames{n}))==1
        dft.(fnames{n}) = defdft.(fnames{n});
    end
end

% fsample needed for custom determination of trials to keep
if isfield(contData,'fsample')
    fsample = contData.fsample;
elseif isfield(contData,'hdr') && isfield(contData.hdr,'Fs')
        fsample = contData.hdr.Fs;
else
    disp('fsample not found...')
    tim = contData.time{1};
    fsample = (length(tim)-1)./(tim(end) - tim(1));
end

cfg = [];
cfg.event = Sevent;
cfg.trialfun = dft.trialfun ; 
if strcmp(dft.trialfun, 'ft_trialfun_general')==1
    cfg.datafile = dft.datafile;
end
cfg.trialdef.eventvalue = dft.trig.value; % Code du type d'evenement considere
cfg.trialdef.prestim    = dft.prestim;
cfg.trialdef.poststim   = dft.postim;
cfg.trialdef.eventtype  = dft.trig.eventyp;  % Name of the trigger channel to extract
cfg.trialdef.resptype  = dft.trig.resptyp;

if isfield(dft.trig,'rightresp') && ~isempty(dft.trig.rightresp)
    cfg.trialdef.rightresp  = dft.trig.rightresp;
end

cfg.fsample = fsample;

cfg_trial   = ft_definetrial(cfg);

% Ajout verification si longueur donnees > indice des essais dans
% cfg_trial.trl
if any(cfg_trial.trl(:,2)>length(contData.time{1}))
    disp(' ')
    disp('!!! Continuous data length inferior to trials indices definition')
    disp(['Data length : ',num2str(length(contData.time{1})),' points'])
    disp('Trials that fall outside :')
    disp('Onset   End')
    disp(num2str(cfg_trial.trl(cfg_trial.trl(:,2)>length(contData.time{1}),1:2)))
    disp('---')
    nbt = length(cfg_trial.trl(:,1));
    nbi = length(cfg_trial.trl(cfg_trial.trl(:,2)<length(contData.time{1}),1));
    disp(['Keeping ',num2str(nbi),' / ',num2str(nbt),' trials']), disp(' ')
    cfg_trial.trl = cfg_trial.trl(cfg_trial.trl(:,2)<length(contData.time{1}),:);
end
cfg=[];
cfg.trl = cfg_trial.trl;  
trials = ft_redefinetrial(cfg, contData); 

