function meg_extract_avg(dpath, trialopt)
% ERF/ERP computation for time-locked analysis
% Average the trials per channels and per conditions
%
fprintf('\nProcessing of data in :\n%s\n\n',dpath);

disp('Average of trials per condition')
fprintf('\n--------\nLoad of *Trials*.mat\n--------\n');
[pmat,nmat] = dirlate(dpath,'cleanTrials*.mat');
if isempty(pmat)
    [pmat,nmat] = dirlate(dpath,'allTrials*.mat');
end
if ~isempty(pmat)
    Strial = loadvar(pmat,'*Trial*');
    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')

    fcond = fieldnames(Strial);
else
    fcond = [];
end

Nc = length(fcond);
avgTrialsCond = [];
for j = 1 : Nc
    cond = fcond{j};
    trials = Strial.(cond);

    fprintf('\n\n')
    disp('-------')
    disp(['Trials for condition : ',cond])
    disp(['Number of trials = ',num2str(length(trials.trial))])
    disp(' ')
    fprintf('\n--------\nAverage all of them by ft_timelockanalysis...\n--------\n');

    cfg = [];
    cfg.keeptrials = 'no';
    cfg.removemean = 'no'; % Already done
    avgT = ft_timelockanalysis(cfg, trials);
    if isfield(trials,'fsample')
        avgT.fsample = trials.fsample;
    else
        avgT.fsample = fsample(avgT.time);
    end
    % Post-process average trials as specified in trialopt
    % structure
    [avgT, trialopt, strproc] = meg_trials_preproc(avgT, trialopt);
    avgTrialsCond.(cond) = avgT;
    
    if j==1
        fdos = make_dir([dpath,filesep,'TrialsAvg_plots',strproc],1);
    end
    
    
    % - Figures of ERF/P ou ER-Component
    meg_avgtrial_fig(avgT, pmat, cond, fdos)
end

if ~isempty(fieldnames(avgTrialsCond))
    suff = meg_matsuff(nmat);
    if ~isempty(suff)
        suff = ['_',suff]; 
    end
    dtyp = strsplitt(nmat, '_');
    if strcmp(dtyp{2}, 'ICAcomp')
        prefix = ['avgComp_ICA', dtyp{1}];
        % Keep track of which data where used to process ICA component (ex.
        % ICAcleanData)
    else
        prefix = ['avgTrials_', dtyp{1}];
    end
        
    save([dpath, filesep, prefix, strproc, suff], 'avgTrialsCond')
    disp(' '), disp('Averaged trials saved here :')
    disp([dpath, filesep, prefix, strproc, suff,'.mat'])
else
    disp('BiG proBleM')
end