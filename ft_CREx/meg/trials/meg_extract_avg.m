function meg_extract_avg(dpath, trialopt)
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

    ftrial=fieldnames(Strial);
else
    ftrial=[];
end

avgTrialsCond = struct;
for j=1:length(ftrial)
    trials = Strial.(ftrial{j});

    fprintf('\n\n')
    disp('-------')
    disp(['Trials for condition : ',ftrial{j}])
    disp(['Number of trials = ',num2str(length(trials.trial))])
    disp(' ')
    fprintf('\n--------\nAverage all of them by ft_timelockanalysis...\n--------\n');
     try
        cfg=[];
        cfg.keeptrials = 'no';
        cfg.removemean = 'no'; % Already done
        avgT = ft_timelockanalysis(cfg,trials);
        if isfield(trials,'fsample')
            avgT.fsample = trials.fsample;
        else
            avgT.fsample = fsample(avgT.time);
        end
        % Post-process trials data as specified in trialopt
        % structure
        [avgT, trialopt, strproc] = meg_trials_preproc(avgT, trialopt);
        if j==1
            fdos = make_dir([dpath,filesep,'TrialsAvg_plots',strproc],1);
        end

        meg_avgtrial_fig(avgT,pmat,ftrial{j},fdos)
        avgTrialsCond.(ftrial{j}) = avgT;
    catch
        disp('Problem with average...')
    end
end
if ~isempty(fieldnames(avgTrialsCond))
    suff = meg_matsuff(nmat);
    if ~isempty(suff)
        suff=['_',suff]; 
    end
    save([dpath, filesep, 'avgTrials', strproc,suff],'avgTrialsCond')
    disp(' '), disp('Averaged trials saved here :')
    disp([dpath, filesep, 'avgTrials', strproc,suff,'.mat'])
else
    disp('BiG proBleM')
end