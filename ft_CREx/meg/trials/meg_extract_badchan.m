function badopt = meg_extract_badchan(dpath,badopt)

disp('------')
fprintf('\n\nCheck for trials - Input of bad channel\n\n')

fprintf('\nProcessing of data in :\n%s\n\n', dpath);

badopt.disptool.name = 'none';
badopt.dirpath = dpath;

if isfield(badopt,'prevCHANstr') && length(badopt.prevCHANstr)>1
    disp(' '), disp('----')
    disp('Channels selection for the previous data set :')
    disp(badopt.prevCHANstr(2:end)), disp(' ')
    disp(' ')
    disp('For this new recording :')
    disp('Keep this selection   -> 1')
    disp('Select a new one      -> 2')
    rep = input('                      -> ');
    disp(' ')
    if rep==1
        CHANstr = badopt.prevCHANstr;
    else
        CHANstr = meg_check_chan(badopt);
    end
else
    CHANstr = meg_check_chan(badopt);
end

badopt.prevCHANstr = CHANstr;


if length(CHANstr)>1  % Seulement s'il faut oter des capteurs
    fprintf('\n\t-------\nLoad dataset\n\t-------\n')
    pdat = dirlate(badopt.dirpath,'cleanTrials*.mat');
    if isempty(pdat)
        pdat = dirlate(badopt.dirpath,'allTrials*.mat');
        badopt.datatyp = 'all';
    else
        badopt.datatyp = 'clean';
    end
    if ~isempty(pdat)
        allTrials = loadvar(pdat,'*Trial*');
    else
        disp('!!! No data set with trials found')
        CHANstr = [];
    end
end


if length(CHANstr)>1
    fnames = fieldnames(allTrials);
    cfg = [];
    cfg.channel = CHANstr;
    if sum(strcmp(fnames,'time'))>0
        % Structure allTrials contient directement la structure fieldtrip
        % des essais
        allTrialsOK = ft_preprocessing(cfg,allTrials);  
        allTrialsOK.newCHANstr = CHANstr;
    else
        % Structures contenant les essais stockees dans chaque champ
        % "condition" de allTrials
        % Initialisation nouvelle structure
        allTrialsOK = allTrials;
        for nc = 1:length(fnames)
            allTrialsOK.(fnames{nc}) = ft_preprocessing(cfg,allTrials.(fnames{nc})); 
            allTrialsOK.(fnames{nc}).newCHANstr = CHANstr;
        end
    end
    
    %_____
    % Save new data
    
    namsav=['_',num2str(length(CHANstr)-1),'rmS'];
    [T,nmat] = fileparts(pdat); %#ok
    newsuff = meg_matsuff(nmat,namsav);
    S = struct;
    S.([badopt.datatyp,'Trials_',newsuff]) = allTrialsOK; %#ok
    save([dpath,filesep,badopt.datatyp,'Trials_',newsuff],'-struct','S') 
    disp(' '),disp('New data saved as ----')
    disp(['----> ',dpath,filesep,badopt.datatyp,'Trials_',newsuff]),disp(' ')
end



