
% ________
% Parameters to adjust
%p0='G:\Catsem';
p0='H:\ADys';
p1=cell(1,2);
p1{1,1}= {p0};    p1{1,2}= 0;
p1{2,1}= {'CAC'};   p1{2,2}= 0; 
p1{3,1}= {'S02'};  p1{3,2}= 0; 
p1{4,1}= {'Run_2'}; p1{4,2}= 0;
  
% p0='Tests\Test_LocalSpheres\Tests_Sophie'; %'F:\ADys';
% p1=cell(1,2);
% p1{1,1}= {p0};    p1{1,2}= 0;
% p1{2,1}= {'MEGdata'};   p1{2,2}= 0; 

freadevent = @define_adys_triggevent; %@define_catsem_triggevent; %@define_adysBaPa_triggevent; %@define_adys_triggevent;

dftopt = struct;
dftopt.trialfun = 'ADys_trialfun'; % []
dftopt.prestim = 0.5; %2; % Pre-stimulus time (s)
dftopt.postim = 1; %2;   % Post-stimulus time (s)
dftopt.trigfun = 'define_adys_triggevent'; % 'define_catsem_triggevent'; % 'define_sophie_triggevent';
dftopt.bsl = [-0.5 -0.3];
dftopt.dofig = 0;

vdo = []; %[]; 
% Vecteur des indices des donnees a traiter
% vdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vdo = 1:10; => sur les 10 premieres donnees
% vdo=17; : sur la 17eme donnee

doExtract = 1;
doRmBadT = 0;
doRmBadChan = 0;
doAvgT = 1;
doExtractICA = 0;
doSupAvgICA = 0;


% Postprocessing options applied to trials (after averaging)
trialopt=struct;
% Redefined trial window 
trialopt.redef.do = 0;      % 0 : don't redefined, 1 : redefined according to redef.win new time window
trialopt.redef.win = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)
% Apply Low-Pass filter
trialopt.LPfilt.do = 0; %0;   % 0 : don't filter ; 1 : do it with cut-off frequency LPfilt.fc 
trialopt.LPfilt.fc = 25; %40;   % Low-pass frequency
% Resample trials
trialopt.resamp.do = 0;   % 0 : don't resample ; 1 : resample according to resamp.fs new frequency
trialopt.resamp.fs = 240;   % New sample frequency
% Resampling can reduce some aberrant covariance values

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp = make_pathlist(p1);


if isempty(vdo)
    vdo=1:length(alldp);
end

if doAvgT==1
    [T,trialopt] = meg_trials_preproc([],trialopt);
end

if doExtract==1
    for np=vdo
        fprintf(['\n-------------------------[',num2str(np),']----------------']);
        fprintf('\nProcessing of data in :\n%s\n\n',alldp{np});
        meg_extract_epoch(alldp{np}, dftopt)
    end                        
end 

% ________
% Reject bad channels 
% 
if doRmBadChan==1
    badopt = struct; % Initialisation
    for np=vdo
        fprintf(['\n-------------------------[',num2str(np),']----------------\n']);
        fprintf('\nProcessing of data in :\n%s\n\n',alldp{np});
        badopt = meg_extract_badchan(alldp{np}, badopt);
    end
end

% ________
% Reject of bad trials
% 
if doRmBadT==1
    for np=vdo
        fprintf(['\n-------------------------[',num2str(np),']----------------\n']);
        fprintf('\nProcessing of data in :\n%s\n\n',alldp{np});
        meg_extract_rmbad(alldp{np})
    end
end
            

% ________
% Average trials per condition
% 
if doAvgT==1
    for np=vdo
        fprintf(['\n-------------------------[',num2str(np),']----------------']);
        meg_extract_avg(alldp{np},trialopt)
    end
end


if doExtractICA==1
    for np=vdo
        fprintf(['\n-------------------------[',num2str(np),']----------------']);
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
            suff = meg_find_matsuff(ndat);
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
    for np=vdo
        fprintf(['\n-------------------------[',num2str(np),']----------------']);
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