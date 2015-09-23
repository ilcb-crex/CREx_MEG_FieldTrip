function meg_extract_epoch(dpath, dftopt)

%______
% Check for input

% Default parameters
dftopt_def = struct('trialfun','ft_trialfun_general',...
                    'trigfun','define_default_triggevent',...
                    'prestim',.5,...
                    'postim',1,...
                    'bsl',[],...
                    'dofig',1);
                
if nargin <2 || isempty(dftopt)==1
    dftopt = dftopt_def;
else
    dftopt = check_opt(dftopt,dftopt_def);
end

if dftopt.prestim < 0
    dftopt.prestim = abs(dftopt.prestim);
end

if dftopt.postim < 0
    dftopt.postim = abs(dftopt.postim);
end
    
if isempty(dftopt.bsl)
    BSL = [-1*dftopt.prestim 0];
else
    BSL = dftopt.bsl;
end
freadevent = str2func(dftopt.trigfun);

disp('Extraction of trials according to trigger values')
fprintf('\n--------\nEvents reading\n--------\n');


% Load cfg_event if existing
pmat = dirlate(dpath,'cfg_event.mat');
if isempty(pmat)
    datafile = filepath4d(dpath);
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
    datafile = [];
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

    fprintf('\n-------\nLoad of clean dataset\n-------\n')

    [pdat,ndat]=dirlate(dpath, 'cleanData*.mat');

    if ~isempty(pdat)
        ok=1;
    else
        [pdat,ndat]=dirlate(dpath, 'filtData*.mat');
        if ~isempty(pdat)
            ok=1;
        else
            disp('!!!')
            disp('Continuous dataset not found (cleanData*.mat or filtData*.mat)')
            disp(' ')
            ok=0;
        end
    end
    if isempty(triggevent(1).name)
        ok=0;
        disp('!!! Problem with trigger values')
        disp('No one good value found...')
    end
    if ok
        disp(' '),disp('Input dataset :')
        disp(ndat), disp('---------')
        if dftopt.dofig
            fdos = make_dir([dpath, filesep,'Trials_plots'],1);
        end
        cleanData = loadvar(pdat,'*Data*');


        allTrials=struct;
        for nc = 1:length(triggevent)
            dftopt.trig = triggevent(nc);
            if ~isempty(datafile)
                dftopt.datafile = datafile;
            end
            trials = meg_extrtrials(dftopt, cfg_event, cleanData);

            % Remove baseline  
            cfg = [];
            cfg.demean = 'yes'; 
            cfg.baselinewindow = BSL; 
            trials = ft_preprocessing(cfg,trials);

            if dftopt.dofig
                % Plot and save figures of each trial 
                meg_trials_fig(trials, pdat, triggevent(nc).name, fdos)
            end

            allTrials.(triggevent(nc).name) = trials;
        end
        suff = meg_matsuff(ndat,[num2str(dftopt.prestim+dftopt.postim),'s']);
        if ~isempty(suff)
            suff=['_',suff]; 
        end
        save([dpath,filesep,'allTrials',suff,'.mat'],'allTrials')
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

