
% ________
% Parameters to adjust
% Data path architect
p0 = 'C:\Users\zielinski\_Docs_\OnTheRoad\MEG\MEG_process\work\bapa_seeg';
p1 = {  {p0}, 0
        {'SEEG'}, 0 
        {'S'}, 1     
        {'Run'}, 1
        };

% pmeg(3,:)= {{'S'}, 1}; 

% Vecteur des indices des donnees a traiter
% vdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vdo = 1:10; => sur les 10 premieres donnees
% vdo=17; : sur la 17eme donnee
vdo = []; 

% Calculs a effectuer
doExtract = 1;
doRmBadT = 1;
doRmBadChan = 0;
doAvgT = 0;
doExtractICA = 0;
doSupAvgICA = 0;

% Parametres des calculs
% freadevent = @define_bapa_triggevent; %@define_catsem_triggevent; % %@define_adys_triggevent;

%_ doExtract : epochs characteristics 
dftopt = struct;
dftopt.trigfun = 'define_bapa_triggevent'; % Function to define triggers codes     
dftopt.trialfun = [];       % Special function to sort events depending on responses (ex. : 'ADys_trialfun';)

dftopt.prestim = 0.250;     % Pre-stimulus time (s): duration before stimulus onset - positive number
dftopt.postim = 0.700;      % Post-stimulus time (s) : duration after stimulus onset

dftopt.bsl = [-0.250 0];    % Baseline use to demean (ex. ADys : [-0.5 -0.3])
dftopt.dofig = 0;           % Flag to generate figures of epochs

%_doExtract & _doAvgT : postprocessing options to apply to trials 
trialopt = struct;
% Redefined trial window 
trialopt.redef.do = 0;      % 0 : don't redefined, 1 : redefined according to redef.win new time window
trialopt.redef.win = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)
% Apply Low-Pass filter
trialopt.LPfilt.do = 0; %0;   % 0 : don't filter ; 1 : do it with cut-off frequency LPfilt.fc 
trialopt.LPfilt.fc = 40; %40;   % Low-pass frequency
% Resample trials
trialopt.resamp.do = 1;   % 0 : don't resample ; 1 : resample according to resamp.fs new frequency
trialopt.resamp.fs = 200;   % New sample frequency
% Resampling can reduce some aberrant covariance values

%_doRmBadT : how to indicate bad trial numbers to remove from dataset
rmtopt = [];
rmtopt.input = 'mat'; %'manual'; 
% 'mat' % Search for rmTrials mat save at a previously epoching
% or 'manual' : for each dataset, user enter the trial identification number
% to remove

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp = make_pathlist(p1);


if isempty(vdo)
    vdo = 1:length(alldp);
end

if doExtract == 1 || doAvgT == 1 
    [T, trialopt] = meg_trials_preproc([],trialopt);
end

if doExtract==1
    % Add trialopt parameters
    dftopt.trialopt = trialopt;
    for np=vdo
        disp_progress(np, vdo);
        fprintf('\nProcessing of data in :\n%s\n\n',alldp{np});
        meg_extract_epoch(alldp{np}, dftopt)
    end                        
end 

% ________
% Reject bad channels 
% 
if doRmBadChan==1
    badopt = struct; % Initialisation
    for np = vdo
        disp_progress(np, vdo);
        
        badopt = meg_extract_badchan(alldp{np}, badopt);
    end
end

% ________
% Reject of bad trials
% 
if doRmBadT==1
    
    %--- First, enter bad trials indices for each condition and data set
    firstload = 1;
    allbadt = cell(length(vdo), 1);
    b = 1;
    for np = vdo
        dpath = alldp{np};
        disp_progress(np, vdo);
        fprintf('\nProcessing of data in :\n%s\n\n', dpath);

        % Load the first available trials dataset to know the conditions names (fieldnames)
        [pmat, nmat] = dirlate(dpath,'allTrials*.mat');
        if ~isempty(pmat)
            if firstload || ~exist('fnames','var')
                allT = loadvar(pmat,'*Trial*');
                fnames = fieldnames(allT);
                firstload = 0;
                fprintf('The detected conditions are');
            end
            man = 1;
            if strcmp(rmtopt.input, 'mat')
                disp('Search for previously bad trial structure "rmTrials.mat"')
                [pbad, nbad] = dirlate(dpath, 'rmTrials.mat');
                if ~isempty(pbad)
                    man = 0;
                    load(pbad)
                    allbadt{b} = rmTrials;
                else
                    disp('Trial structure not found, enter bad trial manually')
                end
            end
            if man==1
                allbadt{b} = meg_rmtrials_input(pmat, fnames);
                % Save it as "rmTrials.mat" for further epoching !
                rmTrials = allbadt{b}; 
                % Save rmTrials data (could be use for further epoching)
                save([dpath, filesep, 'rmTrials'], 'rmTrials')
            end
        else
            allbadt{b} = [];
        end
        
        b = b + 1;
    end
    
    %--- Then, remove the bad trials    
    b = 1;
    for np = vdo
        disp_progress(np, vdo);
        fprintf('\nProcessing of data in :\n%s\n\n', alldp{np});
        meg_extract_rmbad(alldp{np}, allbadt{b})
        b = b + 1;
    end
end
            

% ________
% Average trials per condition
% 
if doAvgT==1
    for np = vdo
        disp_progress(np, vdo);
        meg_extract_avg(alldp{np}, trialopt)
    end
end


if doExtractICA==1
    for np = vdo
        disp_progress(np, vdo);
        fprintf('\nProcessing of data in :\n%s\n\n',alldp{np});
        
        datafile = filepath4d(alldp{np});
        
        disp('Extraction of trials according to trigger values')
        fprintf('\n--------\nEvents reading\n--------\n');
        
        [pmat,nmat] = dirlate(alldp{np},'cfg_event.mat');
        if isempty(pmat)
            fprintf('Reading of events by ft_definetrial\n\n') 
            cfg_rawData = meg_disp_event(datafile);
            cfg_event = cfg_rawData.event;
        else
            load(pmat)
        end

        % Specific function to define events (events name and associated
        % values)
        freadevent = str2func(dftopt.trigfun);
        triggevent = freadevent(cfg_event);

        fprintf('\n-------\nLoad of ICA components dataset\n-------\n')
        [pdat,ndat] = dirlate(alldp{np},'ICAcomp*.mat');
        if ~isempty(pdat) && ~isempty(triggevent(1).name)
            ok=1;
        else
            ok=0;
        end

        if ok
            disp(' '),disp('Input dataset :')
            disp(ndat), disp('---------')
            comp_MEGdata = loadvar(pdat,'comp*');
            fres = make_dir([alldp{np},filesep,'ICACompAvgT'],1);
            avgComp=struct;
            for nc=1:length(triggevent)
                
                condnam=triggevent(nc).name;
                
                fprintf('\n\n')
                disp('-------')
                disp(['Extract trials for condition : ',condnam])
                disp(' ')
                fprintf('\n--------\nAverage all of them by ft_timelockanalysis...\n--------\n');
                try          
                    dftopt.trig = triggevent(nc);
                    dftopt.datafile = datafile;
                    trials = meg_extrtrials(dftopt, cfg_event, comp_MEGdata);
                    
                    disp(' ')
                    disp(['Number of trials = ',num2str(length(trials.trial))]), disp(' ')

                    cfg=[];
                    cfg.keeptrials='no';
                    avgcomp = ft_timelockanalysis([],trials); % By default : cfg.removemean = 'yes';
                    
                    fdos=make_dir([fres,filesep,name_save(condnam)],0);
                    
                    meg_ICAavg_fig(comp_MEGdata,avgcomp,condnam,fdos,pdat)
                    
                    avgComp.(condnam) = avgcomp;
                catch
                    disp('Problem with average...')
                end
            end
            suff=meg_find_matsuffix(ndat);
            if ~isempty(suff)
                suff=['_',suff]; %#ok
            end
            save([fres,filesep,'avgComp',suff,'.mat'],'avgComp')
            disp(' '), disp('Averaged components saved here :')
            disp([fres,filesep,'avgComp',suff,'.mat'])
        end
    end                        
end 

if doSupAvgICA==1
    ICAdir='ICACompAvgT*';
    ICAdat='avgComp*.mat';
    for np = vdo
        disp_progress(np, vdo);
        fprintf('\nProcessing of data in :\n%s\n\n',alldp{np});
        ok=0;
        
        % Need ICA components to view the map
        [pcomp,ncomp] = dirlate(alldp{np},'ICAcomp*.mat');

        % Search for average ICA data, inside specific directory (ICAdir)
        disp(' '),disp(['Search for ',ICAdir,' directory and ',ICAdat])
        davg=dir([alldp{np},filesep,ICAdir]);
        
        if ~isempty(pcomp) && ~isempty(davg)
            dcel=struct2cell(davg);
            % Which are folders ?
            isd=cell2mat(dcel(4,:));
            idxf=find(isd==1);
            if ~isempty(idxf)
                disp(' ')
                if length(idxf)>1
                    % More than one directory
                    % Take the lastest one
                    dat=cell2mat(dcel(5,idxf));
                    j=find(dat==max(dat));
                    disp('More than one folder found')
                    disp('The recent one is chosen :')
                    dnam=dcel{1,idxf(j(1))};
                    disp(dnam)
                else
                    disp('This folder found :')
                    dnam=dcel{1,idxf};
                    disp(dnam)
                end
                pres=[alldp{np},filesep,dnam];
                % Is ICAComp*.mat inside the directory ?
                [pavg,navg] = dirlate(pres,ICAdat);
                if ~isempty(pavg)
                    ok=1;
                end
            end
        end
            
  
        if ok
            fprintf('\n-------\nLoad of ICA components dataset\n-------\n')
            disp(' '),disp('Input component dataset :')
            disp(ncomp), disp('---------')               
            comp_MEGdata = loadvar(pcomp,'comp*');
            
            fprintf('\n-------\nLoad of average ICA components dataset\n-------\n')
            disp(' '),disp('Input dataset :')
            disp(navg), disp('---------')
            
            avgComp = loadvar(pavg,'avgComp*');
            fres = make_dir([pres,filesep,'SuperimpCond'],1);
            
            fnam=fieldnames(avgComp);
            meg_ICAavg_sup_fig(comp_MEGdata,avgComp,fres,pcomp)
            disp(' ')
            disp('----- Figures saved here :')
            disp(fres)
        end
        
    end                        
end 