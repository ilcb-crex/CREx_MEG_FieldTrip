function meg_extract_rmbad(path)
fprintf('\nProcessing of data in :\n%s\n\n',path);
disp('------')
disp(' ')
disp('Remove bad trials')
disp(' ')
disp('Remove trial(s) -> 1')
disp('Keep all trials -> 2')
rep = input('                -> ');
if rep == 1
    fprintf('\n--------\nLoad of allTrials*.mat\n--------\n');
    [pmat,nmat]=dirlate(path,'allTrials*.mat');
    if ~isempty(pmat)
        allTrials = loadvar(pmat,'*Trial*');
        disp(' '), disp('Input data :')
        disp(pmat), disp(' ')
        ftrial=fieldnames(allTrials);
    else
        ftrial=[];
    end

    tot=1;
    rmT=struct;
    for j=1:length(ftrial)
        trials = allTrials.(ftrial{j});
        fprintf('\n\n')
        disp('-------')
        disp(['Trials for condition : ',ftrial{j}])
        disp(['Number of trials = ',num2str(length(trials.trial))])
        disp(' ')
        disp(' Reject one or more trials (1)')
        goon=input('       or keep all of them (0) : ');

        vt=1:length(trials.trial);
        nb=1;
        badt=zeros(1,length(trials.trial));
        while goon
            disp(' ')
            badt(nb)=input(['Enter bad trial n°',num2str(nb),' : ']);
            vt=vt(vt~=badt(nb));
            disp(' ')
            disp('Enter a new bad trial (1)')
            goon=input('          or stop now (0) : ');
            nb=nb+1;
            tot=tot+1;
        end
        if nb-1>0
            rmT.(ftrial{j})=badt(1:nb-1);
        else
            rmT.(ftrial{j})=[];
        end
        disp('-------'), disp(' ')
        if nb>1
            %badtoplot=badt(1:nb-1);          
            fprintf('\n--------\nBad trials removing from data...\n--------\n');
            cfg=[];
            cfg.trials=vt;
            trials = ft_redefinetrial(cfg,trials);
            allTrials.(ftrial{j})=trials;
        end
        disp(' ')
    end
    if tot>1
        cleanTrials = allTrials;   %#ok
        suff=[num2str(tot-1),'rmT'];
        newsuff = meg_matsuff(nmat,suff);
        save([path,filesep,'cleanTrials_',newsuff],'cleanTrials','rmT')
        disp('New trials dataset save as :')
        disp([path,filesep,'cleanTrials_',newsuff])
    else
        disp('None trial was removed')
    end
end