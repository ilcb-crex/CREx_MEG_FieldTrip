
% ________
% Parameters to adjust
% Data path architect
p0 = 'G:\bapa_mseeg'; 
p1 = {  {p0}, 0
        {'S01'}, 1 
        {'MEG'}, 0
        };

% pmeg(3,:)= {{'S'}, 1}; 

% Vecteur des indices des donnees a traiter
% vdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vdo = 1:10; => sur les 10 premieres donnees
% vdo=17; : sur la 17eme donnee
vdo = []; 

% Calculs a effectuer
doExtract = 0;
doRmBadT = 0;
doRmBadChan = 0;
doAvgT = 0;
doExtractICA = 0;
doICAonT = 1;
doSupAvgICA = 0;


% Parametres des calculs
% freadevent = @define_bapa_triggevent; %@define_catsem_triggevent; % %@define_adys_triggevent;

%_ doExtract : epochs characteristics 
dftopt = struct;
dftopt.datatyp = 'filt'; % ICAcomp
dftopt.trigfun = 'define_bapaseeg_triggevent'; % Function to define triggers codes    
% define_bapaseeg_triggevent
dftopt.trialfun = [];       % Special function to sort events depending on responses (ex. : 'ADys_trialfun';)

dftopt.prestim = 0.250;     % Pre-stimulus time (s): duration before stimulus onset - positive number
dftopt.postim = 0.700;      % Post-stimulus time (s) : duration after stimulus onset

dftopt.bsl = [-0.250 0];    % Baseline use to demean (ex. ADys : [-0.5 -0.3])
dftopt.dofig = 0;           % Flag to generate figures of epochs

%_doExtract & _doAvgT : postprocessing options to apply to trials 
trialopt = [];
% Redefined trial window 
trialopt.redef.do = 0;      % 0 : don't redefined, 1 : redefined according to redef.win new time window
trialopt.redef.win = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)
% Apply Low-Pass filter
trialopt.LPfilt.do = 0; %0;   % 0 : don't filter ; 1 : do it with cut-off frequency LPfilt.fc 
trialopt.LPfilt.fc = 40; %40;   % Low-pass frequency
% Resample trials
trialopt.resamp.do = 0;   % 0 : don't resample ; 1 : resample according to resamp.fs new frequency
trialopt.resamp.fs = 200;   % New sample frequency
% Resampling can reduce some aberrant covariance values

%_doRmBadT : how to indicate bad trial numbers to remove from dataset
rmtopt = [];
rmtopt.input = 'mat'; %'manual'; 
% 'mat' % Search for rmTrials mat save at a previously epoching
% or 'manual' : for each dataset, user enter the trial identification number
% to remove

% ICA on epoching data
icaopt = [];
icaopt.datatyp = 'allTrials_'; % + ajouter preproc to find
icaopt.numcomp = 'all'; % 'all'
% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory


datapaths = make_pathlist(p1);
if ~isempty(vdo)
    datapaths = datapaths(vdo);
end
Ndp = length(datapaths);


if doExtract == 1 || doAvgT == 1 
    [T, trialopt] = meg_trials_preproc([],trialopt);
end

if doExtract==1
    % Add trialopt parameters
    dftopt.trialopt = trialopt;
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        fprintf('\nProcessing of data in :\n%s\n\n',datapaths{np});
        meg_extract_epoch(datapaths{np}, dftopt)
    end                        
end 

% ________
% Reject bad channels 
% 
if doRmBadChan==1
    badopt = struct; % Initialisation
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        
        badopt = meg_extract_badchan(datapaths{np}, badopt);
    end
end

% ________
% Reject of bad trials
% 
if doRmBadT==1
    
    %--- First, enter bad trials indices for each condition and data set
    allbadt = meg_rmtrials_gathering(datapaths, rmtopt);

    
    %--- Then, remove the bad trials    
    b = 1;
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        fprintf('\nProcessing of data in :\n%s\n\n', datapaths{np});
        meg_extract_rmbad(datapaths{np}, allbadt{b})
        b = b + 1;
    end
end
            

% ________
% Average trials per condition
% 
if doAvgT==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        meg_extract_avg(datapaths{np}, trialopt)
    end
end


% ________
% ICA processing : analysis of ICA component to remove artefacts
% 
if doICAonT==1
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        compData = meg_ica_proc(datapaths{np}, icaopt);
    end
end

if doSupAvgICA==1
    ICAdir = 'ICACompAvgT*';
    ICAdat = 'avgComp*.mat';
    for np = 1 : Ndp
        disp_progress(np, Ndp);
        fprintf('\nProcessing of data in :\n%s\n\n',datapaths{np});
        ok=0;
        
        % Need ICA components to view the map
        [pcomp,ncomp] = dirlate(datapaths{np},'ICAcomp*.mat');

        % Search for average ICA data, inside specific directory (ICAdir)
        disp(' '), disp(['Search for ',ICAdir,' directory and ',ICAdat])
        davg = dir([datapaths{np},filesep,ICAdir]);
        
        if ~isempty(pcomp) && ~isempty(davg)
            dcel = struct2cell(davg);
            % Which are folders ?
            isd = cell2mat(dcel(4,:));
            idxf = find(isd==1);
            if ~isempty(idxf)
                disp(' ')
                if length(idxf)>1
                    % More than one directory
                    % Take the lastest one
                    dat = cell2mat(dcel(5,idxf));
                    j = find(dat==max(dat));
                    disp('More than one folder found')
                    disp('The recent one is chosen :')
                    dnam = dcel{1,idxf(j(1))};
                    disp(dnam)
                else
                    disp('This folder found :')
                    dnam = dcel{1,idxf};
                    disp(dnam)
                end
                pres=[datapaths{np},filesep,dnam];
                % Is ICAComp*.mat inside the directory ?
                [pavg,navg] = dirlate(pres,ICAdat);
                if ~isempty(pavg)
                    ok = 1;
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
            
            fnam = fieldnames(avgComp);
            meg_ICAavg_sup_fig(comp_MEGdata,avgComp,fres,pcomp)
            disp(' ')
            disp('----- Figures saved here :')
            disp(fres)
        end
        
    end                        
end 
