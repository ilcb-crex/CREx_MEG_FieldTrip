function allbadt = meg_rmtrials_gathering(datapaths, rmtopt)
% Store all bad trial numbers to remove per condition, for all the datasets 
% specified by datapaths
% Bad trials are specified by a manual input or automatically by the load 
% of the rmbadT matrix

%--- First, enter bad trials indices for each condition and data set
firstload = 1;
Ndp = length(datapaths);
allbadt = cell(Ndp, 1);
b = 1;
for np = 1 : Ndp
    dpath = datapaths{np};
    disp_progress(np, Ndp);
    fprintf('\nProcessing of data in :\n%s\n\n', dpath);

    % Load the first available trials dataset to know the conditions names (fieldnames)
    pmat = dirlate(dpath,'allTrials*.mat');
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
            pbad = dirlate(dpath, 'rmTrials.mat');
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