function meg_extract_rmbad(datapath, badtrials)
% Remove bad trials
fprintf('\nProcessing of data in :\n%s\n\n------\n', datapath);
fprintf('Removing of bad trials\n\n');
if ~nargin
    datapath = pwd;
end
    
% Check if data matrix is available
[pmat, nmat] = dirlate(datapath,'allTrials*.mat');

if isempty(pmat)
    disp('!!! Trials data ''allTrials*.mat'' not found in the directory')
    return
end

% User must enter bad trial indices for each conditions if badtrials
% structure is not provided
if nargin < 2 
    [rmT, allTrials] = rmbad_select(pmat);
    rmTrials = rmT; %#ok
    % Save rmTrials data (could be use for further epoching)
    save([datapath, filesep, 'rmTrials'], 'rmTrials')
else
    rmT = badtrials;         
end

% Load trials dataset

nrm = sum_badtrial(rmT);

if  nrm > 0
    if ~exist('allTrials','var')
        allTrials = load_trials(pmat);
    end
    ftrial = fieldnames(rmT);
    fini = fieldnames(allTrials);
    % Number of effective removed trials
    neff = 0;
    % Remove bad trials from the data
    for j = 1 : length(ftrial)  
        fcond = ftrial{j};
        if (~isempty(rmT.(fcond))) && (sum(strcmp(fini, fcond))==1)         
            trials = allTrials.(fcond);
            Nt = length(trials.trial);
            ibadt = rmT.(fcond);
            igoodt = setdiff(1:Nt, ibadt);
            
            fprintf('\n--------\nBad trials removing from data...\n--------\n');
            
            cfg = [];
            cfg.trials = igoodt;
            trials = ft_redefinetrial(cfg, trials);
            allTrials.(fcond) = trials;
            neff = neff + length(ibadt);
        end
        disp(' ')
    end
    
    % Save new trials structure
    if neff > 0
        cleanTrials = allTrials;   %#ok
        suff = [num2str(neff),'rmT'];
        newsuff = meg_matsuff(nmat,suff);
        save([datapath,filesep,'cleanTrials_',newsuff], 'cleanTrials', 'rmT')
        disp('New trials dataset save as :')
        disp([datapath, filesep, 'cleanTrials_', newsuff])
    else
        disp('No trial was removed')
    end
end

%-- Load trials structure ('allTrials*.mat')
function allT = load_trials(pmat)

fprintf('\n--------\nLoad of allTrials*.mat\n--------\n');
    if ~isempty(pmat)
        allT = loadvar(pmat,'*Trial*');
        disp(' '), disp('Input data :')
        disp(pmat), disp(' ')
    else
        allT = [];
    end
    
%-- Return bad trials indices structure and trials dataset structure
function [Sbad, allTrials] = rmbad_select(pmat)
    
    fprintf('\nTrials data :\n%s\n\n------\n', pmat);
    disp('Remove trial(s) -> 1')
    disp('Keep all trials -> 2')
    
    rep = input('                -> ');
    
    if rep==1
        allTrials = load_trials(pmat);
        if ~isempty(allTrials)
            ftrial = fieldnames(allTrials);
        else
            ftrial = [];
        end

        % Enter bad trials indices for each condition
        Sbad = struct;
        for j = 1 : length(ftrial)
            fcond = ftrial{j};
            Nt = length(allTrials.(fcond).trial);

            % Bad trial indices
            ibadt = input_badtrial(fcond, Nt); 

            Sbad.(fcond) = ibadt;
        end
    end

%-- Enter bad trials and confirm selection
function ibadtrials = input_badtrial(fcond, ntrials)

doagain = 0;
while doagain==0
    fprintf('\n\n-------\n');
    disp(['Trials for condition : ', fcond])
    disp(['Number of trials = ',num2str(ntrials)])
    disp(' ')
    disp(' Reject one or more trials (1)')
    goon = input('       or keep all of them (0) : ');
    
    % Initialisation
    % Bad trial indices 
    ibadtrials = zeros(1, ntrials);
    k = 1;
    while goon
        disp(' ')
        btr = input(['Enter bad trial n°',num2str(k),' : ']);
        if ~isempty(btr) && btr~=0            
            ibadtrials(k) = btr;
            k = k + 1;     
        end
        disp(' ')
        disp('Enter a new bad trial (1)')
        goon = input('          or stop now (0) : ');
    end
    
    ibadtrials = unique(ibadtrials(1 : k-1));
    % Return empty matrix if no trials selected
    
    fprintf('\nBad trials summary for condition : %s\n', fcond);
    if isempty(ibadtrials)
        disp('No one selected')
    else
        disp(ibadtrials)
    end
    fprintf('\nConfirm this selection (1)');
    doagain = input('     Or enter a new one (0): ');
end
fprintf('-------\n\n');

%-- Count total number of trials to remove
function nTtot = sum_badtrial(Sbad)
    nTtot = 0;
    if ~isempty(Sbad) && isstruct(Sbad)
        fnames = fieldnames(Sbad);    
        for j = 1 : length(fnames)
            cond = fnames{j};
            if ~isempty(Sbad.(cond))
                ibad = Sbad.(cond);
                nTtot = nTtot + length(ibad(ibad > 0));
            end
        end
    end
    