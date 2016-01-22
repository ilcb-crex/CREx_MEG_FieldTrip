% ________
% Parameters to adjust
%p0='F:\Catsem';
%p0='\\Filer\home\Personnels\zielinski\Mes documents\_Docs_\OnTheRoad\MEG\MEG_process\Tests\Test_LocalSpheres\Tests_Sophie'; %'F:\Catsem';
p0 = 'G:\Catsem'; 
p1 = cell(1,2);
p1{1,1} = {p0};    p1{1,2}= 0;
p1{2,1} = {'S08'};   p1{2,2}= 0; 
%p1{3,1} = {'S02'};   p1{3,2}= 0; 
%p1{4,1}= {'MRI'};  p1{4,2}= 0; 


% Architecture des dossiers a partir des chemins Subject (p1)
% 1) Pour la MEG
pmeg=cell(1,2);
pmeg{1,1}={''};         pmeg{1,2}= 0;
pmeg{2,1}={'MEG'};      pmeg{2,2}= 0;
pmeg{3,1}= {'Run*Visu'};	pmeg{3,2}= 1;

% 2) Pour l'IRM
pmri=cell(1,2);
pmri{1,1}={''};     pmri{1,2}= 0;
pmri{2,1}={'MRI'}; 	pmri{2,2}= 0;

formimg='mri';

prestim = 0; %-0.3;
tempgridpath = [pwd,filesep,'template_Colin27_BS.mat']; %'template_T1.mat'];
% tempgridpath = [] : grid created from 
% 'C:\Program Files\MATLAB\R2013a\toolbox\fieldtrip_20130825\external\spm8\templates\T1.nii';
vsdo = [];  
% Vecteur des indices des donnees a traiter
% vsdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vsdo = 1:10; => sur les 10 premieres donnees
% vsdo=17; : sur la 17eme donnees
doVolCond = 0;
doLoc = 0;
dofigLoc = 1;
doClassLoc = 0;

conditions = {'Visu_Corps'};

forwopt.formimg = 'mri';

% Option for preprocessed trials used for localisation algorithms
trialopt=struct;
% Redefined trial window 
trialopt.redef.do=0;      % 0 : don't redefined, 1 : redefined according to redef.win new time window
trialopt.redef.win=[-0.2 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)
% Apply Low-Pass filter
trialopt.LPfilt.do=1;   % 0 : don't filter ; 1 : do it with cut-off frequency LPfilt.fc 
trialopt.LPfilt.fc=25;   % Low-pass frequency
% Resample trials
trialopt.resamp.do=0;   % 0 : don't resample ; 1 : resample according to resamp.fs new frequency
trialopt.resamp.fs=240;   % New sample frequency
% Resampling can reduce some aberrant covariance values

%--- Sliding windows options for map representations
% Mean values of source signals are calculated according to windows
% definition and duration
winopt = struct;
winopt.slidwin = -0.200 : 0.010 : 0.820; % -0.3 : 0.01 : 0.650;   % Starts of each window
winopt.lgwin = 0.02 ;                   % Duration of each window

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

allsubjp=make_pathlist(p1);

if isempty(vsdo)
    vsdo=1:length(allsubjp);
end

% Check options of preprocessing for trials before applying it
if doLoc==1 || doClassLoc==1
    [~,trialopt,~] = meg_trials_preproc([],trialopt);
end
%_____
% Volume conduction model preparation and ajusted MNI grid (from template)
if doVolCond==1

    if ~exist('tempgridpath','var') || isempty(tempgridpath) || isempty(dir(tempgridpath))
        template_grid = meg_create_template_grid(pwd);
    else
        disp(tempgridpath)
        template_grid = loadvar(tempgridpath,'template_grid*');
    end
    forwopt.tempgrid = template_grid;
    for ns=vsdo 
        disp(['--> ',allsubjp{ns}])
        pmri{1,1}=allsubjp{ns};
        mripath=make_pathlist(pmri);
        mripath=mripath{1};

        pmeg{1,1}=allsubjp{ns};
        megpth_allrun = make_pathlist(pmeg);
        megpath = megpth_allrun{1};
        
        meg_localiz_forwardMRI(mripath, megpath, forwopt)

    end
        
end

%_____
% Process modeling of source location
% Beamforming with Z calculations = Jean-Michel Badier's method
if doLoc==1
    for ns=vsdo 
        disp(['--> ',allsubjp{ns}])
        fprintf('\n\n\t-------\nProcess modeling of sources\n\t-------\n')
        % Read volume conduction model
        pmri{1,1}=allsubjp{ns};
        mripath=make_pathlist(pmri);
        mripath=mripath{1};
        [pvol,nvol]=dirlate(mripath,'volcond_*.mat');
        [pgrd,ngrd]=dirlate(mripath,'subj_grid*.mat');
        if ~isempty(pvol) && ~isempty(pgrd)            
            % Volume conduction model obtained from the singleshell method 
            % apply to the reslice and segmented mri of the subject :
            disp(['--> ',mripath])
            disp(['Read volume conduction model ',nvol])
            vol = loadvar(pvol,'volcondmodel*');
            % The deformed template grid, ajusted to the head model of the
            % subject :
            disp(['Read subject grid ',ngrd])
            subj_grid = loadvar(pgrd,'subj_grid*');
                 
            pmeg{1,1}=allsubjp{ns};
            megpth = make_pathlist(pmeg);

            for nrun=1:length(megpth)
                disp(' ')
                disp(['--> ',megpth{nrun}])
                % Load all trials
                [pTmat,nTmat]=dirlate(megpth{nrun},'cleanTrials*.mat');
                if isempty(pTmat)
                    [pTmat,nTmat]=dirlate(megpth{nrun},'allTrials*.mat');
                end
                if ~isempty(pTmat)
                    disp(['Read MEG trials ',nTmat])
                    SallT = loadvar(pTmat,'*Trial*');
                    fn=fieldnames(SallT);
  %!!!                  %%%%%%%%
  %                  fn = fn(1:end-1);
                    Sgrad=SallT.(fn{1}).grad;
                    Chan = SallT.(fn{1}).label';
                    nampath4fig = pTmat; % Path as put in the title of figures
                    ok=1;
                else
                    ok=0;
                end
                if ok
                    % Create lead field = forward solution
                    disp(' '),disp('Create lead field (forward solution)')
                    cfg = [];
                    cfg.grad = Sgrad;
                    cfg.vol = vol;
                    cfg.grid = subj_grid;
                    cfg.reducerank = 2;
                    cfg.channel = Chan;  % Check if it is a good definition of channels 
                    leadfield_grd = ft_prepare_leadfield(cfg);
                    cfg_lf=cfg;
                    % Ici on n'a pas sous echantillonne l'IRM du sujet
                    
                    % Pre-process trials data as specified in trialopt
                    % structure
                    strproc='';
                    for nc=1:length(fn)
                        [SallT.(fn{nc}),trialopt,strproc] = meg_trials_preproc(SallT.(fn{nc}),trialopt);
                    end
                    % Keep information of the filtering or/and resampling
                    % operation by added strproc string inside the name
                    % of the trial data path (which will appear on the
                    % figures of localization)
                    if ~isempty(strproc)
                        nampath4fig=[fileparts(pTmat),filesep,' [',strproc(2:end),'] ',nTmat];
                    end
                    fdos=make_dir([megpth{nrun},filesep,'SourceLocMom_Z',strproc],1);
                    
                    % Concatenate trials of all conditions
                    dataAll=SallT.(fn{1});
                    for i=2:length(fn)
                        dataAll = ft_appenddata([],dataAll,SallT.(fn{i}));
                    end

                    % Average of all trials 
                    disp('Averaging trials')
                    cfg = [];
                    cfg.keeptrials = 'no';  
                    cfg.covariance = 'yes';
                    cfg.removemean = 'no';  % Baseline correction already done
                    cfg.covariancewindow = 'all';
                    avgTrialsAll = ft_timelockanalysis(cfg,dataAll);
                    cfg.keeptrials = 'yes';
                    avgTrialsCond=struct;
                    % Average of trials per condition
                    for j=1:length(fn)
                        avgTrialsCond.(fn{j})=ft_timelockanalysis(cfg,SallT.(fn{j}));
                    end
                    clear dataAll    
                    % LCMV calculus from all average trials of all
                    % conditions
                    disp('LCMV source analysis')
                    cfg        = [];
                    cfg.method = 'lcmv';
                    cfg.grid   = leadfield_grd;
                    cfg.vol    = vol;
                    cfg.lcmv.lambda = '5%';
                    cfg.lcmv.keepfilter = 'yes';
                    cfg.lcmv.fixedori = 'yes'; % L'orientation est calculee via une ACP // orientation 3 dipoles
                    sourceAll  = ft_sourceanalysis(cfg,avgTrialsAll);
                    %if length(fn)>1 % Plusieurs conditions etudiees     
                        % Apply the filter from modeling of all average to
                        % each condition
                        cfg.grid.filter = sourceAll.avg.filter;
                    %end
                    disp('Calculate normalized Z values')
                    sourceCond=struct;
                    for j = 1:length(fn)
                        fnam=fn{j};
                        sourC = ft_sourceanalysis(cfg,avgTrialsCond.(fnam));
                        mom=sourC.avg.mom;
                        time=sourC.time;
                        
                        % Normalized by remove mean value of the baseline
                        % and divide by its standard deviation
                        
                        sourC.avg.z = mom;
                        sourC.avg.z2 = mom;
                        for n=1:length(mom)
                            if ~isempty(mom{n})
                                sourC.avg.z{n} = (mom{n} - mean(mom{n}(time<prestim)))/std(mom{n}(time<prestim));
                                sourC.avg.z2{n}=sourC.avg.z{n}.^2;                                    
                            end
                        end
                        sourceCond.(fnam)=sourC;

                        % Figures of the Z representation
                     %   meg_loc_momZfig(sourC,fnam,fdos,nampath4fig)
                    end

                    suff=meg_find_matsuffix(nTmat,strproc);
                    if ~isempty(suff)
                        suff=['_',suff]; %#ok
                    end
                    save([megpth{nrun},filesep,'SourceModel',suff],'sourceCond')%,'sourceAll')
                    save([megpth{nrun},filesep,'avgTrials',suff],'avgTrialsCond')%,'avgTrialsAll')
                    save([mripath,filesep,'leadfield_grd'],'leadfield_grd','cfg_lf')
                    fprintf('\n-----------\nSource results saved in :\n')
                    disp(megpth{nrun})
                    disp(['as : ','SourceModel',suff])
                    fprintf('\n-----------\nAssociated figures in :\n')
                    disp(fdos)
                end
            end
        end
    end
end

% Make figure of modeling results : localization regarding to latence
% windows 
if dofigLoc==1
    % Need : allSourceData_*.mat and latwin specification
    % MRI reslice of the subject (don't work with MNI template)
   for ns=vsdo 
       disp(['--> ',allsubjp{ns}])
       fprintf('\n\n\t-------\nSources locations results\n\t-------\n')
       pmri{1,1}=allsubjp{ns};
       mripath=make_pathlist(pmri);
       mripath=mripath{1};
       [pmriresl,nmriresl]=dirlate(mripath,'mriResl*.mat');
       pmeg{1,1}=allsubjp{ns};
       megpth = make_pathlist(pmeg);
       if ~isempty(pmriresl) && ~isempty(megpth)
           disp('Read resliced MRI')
           disp(pmriresl)
           mriResl = loadvar(pmriresl,'mriResl*');    
           disp('Read source modeling results')
           for nrun=1:length(megpth)    
                % Load allSourceData_*.mat
                [pso,nsourcmat]=dirlate(megpth{nrun},'SourceModel*.mat');
                disp(pso)
                if ~isempty(pso)
                    sourCond = loadvar(pso,'sourceCond*');
                    fcond=fieldnames(sourCond);
                    % Find suffix corresponding to special preprocessing of trials
                    suff = meg_find_trialprocsuffix(nsourcmat);
                    if ~isempty(suff)
                        suff=['_',suff]; %#ok
                    end
                    fdos=make_dir([megpth{nrun},filesep,'SourceLocMap_Z',suff],1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    for nc=1:1 %length(fcond)
                        fnam=fcond{nc};
                        sourC=sourCond.(fnam);
%                         fcondos=make_dir([fdos,filesep,fnam],0);
%                         meg_loc_map(sourC,mriResl,latwin,fnam,fcondos,pso)
                        
                        dos=make_dir([fdos,filesep,'Frames_',fnam],0);
                        [path,mat]=fileparts(pso);
                        pSmat=[path,filesep,'SourceModel.mat'];
                        
                        opt = [];
                        opt.slidwin = winopt.slidwin;
                        opt.lgwin = winopt.lgwin;
                        opt.fname = fnam;
                        opt.savpath = dos;
                        opt.matpath = pSmat;
                        opt.param = 'z2';

                        meg_loc_map_framefig(sourC, mriResl, opt)
                    end
                end
           end
       end
   end
end

if doClassLoc==1
    % Need : latwin = windows definitions
    for ns=vsdo 
        disp(['--> ',allsubjp{ns}])
        fprintf('\n\n\t-------\nProcess modeling of sources\n\t-------\n')
        % Read volume conduction model
        pmri{1,1} = allsubjp{ns};
        mripath = make_pathlist(pmri);
        mripath = mripath{1};
        [pvol,nvol] = dirlate(mripath,'volcond_*.mat');
        [pgrd,ngrd] = dirlate(mripath,'subj_grid*.mat');
        [pmriresl,nmriresl] = dirlate(mripath,'mriResl*.mat');
        pmeg{1,1} = allsubjp{ns};
        megpth = make_pathlist(pmeg);
        if ~isempty(pvol) && ~isempty(pgrd) && ~isempty(pmriresl) && ~isempty(megpth)
            % Volume conduction model obtained from the singleshell method 
            % apply to the reslice and segmented mri of the subject :
            disp(['--> ',mripath])
            disp(['Read volume conduction model ',nvol])
            vol = loadvar(pvol,'volcondmodel*');
            % The deformed template grid, ajusted to the head model of the
            % subject :
            disp(['Read subject grid ',ngrd])
            subj_grid = loadvar(pgrd,'subj_grid*');
            
            disp('Read resliced MRI')
            disp(pmriresl)
            mriResl = loadvar(pmriresl,'mriResl*'); 
            
            for nrun = 1:length(megpth)
                disp(' ')
                disp(['--> ',megpth{nrun}])
                % Load all trials
                [pTmat,nTmat]=dirlate(megpth{nrun},'cleanTrials*.mat');
                if isempty(pTmat)
                    [pTmat,nTmat]=dirlate(megpth{nrun},'allTrials*.mat');
                end
                if ~isempty(pTmat)
                    disp(['Read MEG trials ',nTmat])
                    SallT = loadvar(pTmat,'*Trial*');
                    fn=fieldnames(SallT);
                    Sgrad=SallT.(fn{1}).grad;
                    Chan = SallT.(fn{1}).label';
                    
                    % Create lead field = forward solution
                    disp(' '),disp('Create lead field (forward solution)')
                    cfg = [];
                    cfg.grad = Sgrad;
                    cfg.vol = vol;
                    cfg.grid = subj_grid;
                    cfg.reducerank = 2;
                    cfg.channel = Chan;  % Check if it is a good definition of channels 
                    leadfield_grd = ft_prepare_leadfield(cfg);

                    % Ici on n'a pas sous echantillonne l'IRM du sujet
                    
                    % Pre-process trials data as specified in trialopt
                    % structure
                    strproc='';
                    sourceCondCBF_meth1=struct;
                    sourceCondCBF_meth2=struct;
                    for nc=1:length(fn)
                        fnam=fn{nc};
                        
                        [SallT.(fn{nc}),trialopt,strproc] = meg_trials_preproc(SallT.(fn{nc}),trialopt);
                        %%sourC = meg_loc_beamfpow(SallT.(fn{nc}),leadfield_grd,vol,latwin);
                        %sourC = meg_loc_beamfpow_slidwin(SallT.(fn{nc}),leadfield_grd,vol);
                        sourC = meg_loc_beamfpow_slidwin_meth2(SallT.(fn{nc}),leadfield_grd,vol);
%                         % Keep information of the filtering or/and resampling
%                         % operation by added strproc string inside the name
%                         % of the trial data path (which will appear on the
%                         % figures of localization)
%                         if nc==1 
%                             nampath4fig=[fileparts(pTmat),filesep,' [',strproc(2:end),'] ',nTmat];
%                             if ~isempty(strproc)
%                                 suff=['_',strproc];
%                             else
%                                 suff='';
%                             end
%                             fdos=make_dir([megpth{nrun},filesep,'SourceLocCBF',suff],1);
%                         end                     
%                         % Figures
%                         meg_loc_beamfpow_map(sourC,mriResl,latwin,fnam,fdos,nampath4fig)
                        %sourceCondCBF_meth1.(fnam)=sourC{1};
                        %sourceCondCBF_meth2.(fnam)=sourC{2};
                        sourceCondCBF_meth2.(fnam)=sourC{1};
                    end
                    
                    suff=meg_find_matsuffix(nTmat,strproc);
                    if ~isempty(suff)
                        suff=['_',suff]; %#ok
                    end
                    %namsav1=['SourceModCBF_meth1',suff];
                    %save([megpth{nrun},filesep,namsav1],'sourceCondCBF_meth1')
                    namsav2=['SourceModCBF_meth2',suff];
                    save([megpth{nrun},filesep,namsav2],'sourceCondCBF_meth2')
                    
                    fprintf('\n-----------\nSource results saved in :\n')
                    disp(megpth{nrun})
                    %disp(['as : ',namsav1])
                    disp(['and : ',namsav2])
                    fprintf('\n-----------\nAssociated figures in :\n')
                   % disp(fdos)
                end
            end
        end
    end
end
 

                        
                        
                
    


