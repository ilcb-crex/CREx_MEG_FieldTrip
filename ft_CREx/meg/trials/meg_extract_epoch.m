function meg_extract_epoch(dpath, dftopt)
% Epoching of continuous data
% Baseline correction is done for each trial if dftopt.bsl is not empty 
% (not done otherwise)
% 
% as well as preprocessing

fprintf('\n------\nData set epoching\n-----\n\n');
fprintf('\nProcessing of data in :\n%s\n\n', dpath);
%______
% Check for input

% Default parameters
dftopt_def = struct('datatyp', {'clean', 'filt'},...
                    'trialfun','ft_trialfun_general',...
                    'trigfun','define_default_triggevent',...
                    'prestim',0.5,...
                    'postim',1,...
                    'bsl',[],...
                    'dofig',1,...
                    'trialopt', []);
                
if nargin < 2 || isempty(dftopt)==1
    dftopt = dftopt_def;
else
    dftopt = check_opt(dftopt,dftopt_def);
end

% Chack for parameters
% Pre-stimulus duration to extract
if dftopt.prestim < 0
    dftopt.prestim = abs(dftopt.prestim);
end

% Post-stimulus duration
if dftopt.postim < 0
    dftopt.postim = abs(dftopt.postim);
end

% Baseline for baseline correction (empty : no correction)
if isempty(dftopt.bsl) || length(dftopt.bsl)==1
    BSL = [];
    % BSL = [-1*dftopt.prestim 0];
else
    BSL = dftopt.bsl;
end

% Function that define trigger type and values
freadevent = str2func(dftopt.trigfun);

% Structure of trial processing parameters (filtering, resampling)
trialopt = dftopt.trialopt;
strproc = [];

% Data type to find in data directory for epoching carnage
if ischar(dftopt.datatyp)
    datatyp = {dftopt.datatyp};
else
    datt = dftopt.datatyp;
    if length(datt)==2
        if strcmp(datt{2}, 'clean') && strcmp(datt{1}, 'filt')
            datatyp = datt([2 1]);
        end
    else
        % Let it be
        datatyp = datt;
    end
end

%_____________ GO

fprintf('\nExtraction of trials according to trigger values');
fprintf('\n--------\nEvents reading\n--------\n');


% Load cfg_event if existing
pmat = dirlate(dpath,'cfg_event.mat');
datafile = filepath4d(dpath);
if isempty(pmat)   
    if ~isempty(datafile)        
        disp(' ')
        disp('Read trigger values from raw data set')
        disp(' ')
        cfg_rawData = meg_disp_event(datafile);
        cfg_event = cfg_rawData.event;
        save([dpath, filesep, 'cfg_event.mat'],'cfg_event')
        save([dpath, filesep, 'cfg_rawData.mat'],'cfg_rawData')
        extr = true;
    else
        disp('!!!')
        disp('Impossible to exctract trigger values')
        disp(' ')
        extr = false;
    end
else
    disp(' ')
    disp('Read trigger values from cfg_event.mat structure')
    disp('(previously saved)')
    disp(' ')
    extr = true;
    load(pmat)
end

if extr
    % Specific function to define events (events name and associated
    % values)
    triggevent = freadevent(cfg_event); 

    fprintf('\n-------\nLoad of dataset to epoch\n-------\n')
    dataopt = [];
    dataopt.datatyp = datatyp;
    [pdat, ndat] = find_datamat(dpath, dataopt); 
    
    if ~isempty(pdat)
        ok = 1;
    else
        ok = 0;
        disp('!!!')
        disp('Continuous dataset not found (cleanData*.mat or filtData*.mat)')
        disp(' ')
    end
    
    if isempty(triggevent(1).name)
        ok = 0;
        disp('!!! Problem with trigger values')
        disp('No one good value found...')
    end
    if ok
        disp(' '),disp('Input dataset :')
        disp(ndat), disp('---------')
        if dftopt.dofig
            ppdir = make_dir(fullfile(dpath, '_preproc'), 0);
            fdos = make_dir([ppdir, filesep,'Trials_plots'],1);
        end
        cleanData = loadvar(pdat,'*Data*');


        allTrials = struct;
        for nc = 1:length(triggevent)
            dftopt.trig = triggevent(nc);
            if ~isempty(datafile)
                dftopt.datafile = datafile;
            end
            trials = meg_extrtrials(dftopt, cfg_event, cleanData);

            % Apply post-processing
            if ~isempty(trialopt)
                [trials, ~, strproc] = meg_trials_preproc(trials, trialopt);
            end
            
            % Remove baseline  
            if ~isempty(BSL)
                cfg = [];
                cfg.demean = 'yes'; 
                cfg.baselinewindow = BSL; 
                trials = ft_preprocessing(cfg,trials);
            end

            if dftopt.dofig
                % Plot and save figures of each trial 
                % Put figures directory in the general "Preproc_fig" directory
               
                meg_trials_fig(trials, pdat, triggevent(nc).name, fdos)
            end

            allTrials.(triggevent(nc).name) = trials;
        end
        
        %suff = ['_', num2str(dftopt.prestim + dftopt.postim),'s', strproc];
        %suff(suff=='.') = 'p';
        suff = meg_matsuff(ndat,[num2str(dftopt.prestim+dftopt.postim),'s', strproc]);
        if ~isempty(suff)
            suff = ['_',suff]; 
        end
        dtyp = strsplitt(ndat, '_');
        
        save([dpath,filesep,'allTrials_',dtyp{1},suff,'.mat'],'allTrials')
    end
end

%______
% Check for input options
function dftopt = check_opt(dftopt, dftopt_def)

    fopt = fieldnames(dftopt_def);
    for i = 1 : length(fopt)
        if ~isfield(dftopt, fopt{i}) || isempty(dftopt.(fopt{i}))
            dftopt.(fopt{i}) = dftopt_def.(fopt{i});
        end     
    end

