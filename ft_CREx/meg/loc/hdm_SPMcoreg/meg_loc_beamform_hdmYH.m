function meg_loc_beamform_hdmYH(megpath, trialopt, fnames, tBSL)

%----
% Parse inputs

% Start stimulus time (baseline end)
if nargin<4 || isempty(tBSL)
    tBSL = 0;
end

% Trials fields using in trials multi-condition structures
if nargin <3 || isempty(fnames) 
    fnames = '';
    cmod = 1;
else
    if isnumeric(fnames)
        cmod = 2;
    else
        cmod = 3;
    end
end

% Trials preprocessing options
if nargin < 2 || isempty(trialopt)
    trialopt = struct('redef',struct('do',0), 'LPfilt',struct('do',0),...
        'resamp', struct('do',0));
end

% Search of trials data
[pTmat,nTmat] = dirlate(megpath,'cleanTrials*.mat');
if isempty(pTmat)
    [pTmat,nTmat] = dirlate(megpath,'allTrials*.mat');
end
if isempty(pTmat)
    disp('!!! MEG data *Trials*.mat not found in directory')
    disp(['--> ',megpath])
    return;
end

% Check for HeadModel*.mat : head model
[pHdm, nHdm] = dirlate(megpath,'HeadModel*.mat');
if isempty(pHdm)
    [pHdm, nHdm] = dirlate(megpath,'volcond*.mat');  % Previous name
end
if isempty(pHdm)
    disp('!!! Head model MAT data file not found in directory')
    disp(['--> ',megpath])
    return;
end

%____GO !


% Keep information of the trials preprocessing on figure titles
[T, trialopt, strproc] = meg_trials_preproc([],trialopt);  %#ok compat M7

fpath = fileparts(pTmat);
if ~isempty(strproc)    
    addonfig = [fpath, filesep, '[ ',strproc(2:end),' ]',nTmat]; 
else
    addonfig = pTmat;
end

disp(['Load head model ', nHdm])
load( pHdm, 'subj_vol','subj_grid')

disp(['Read MEG trials ',nTmat])
SallT = loadvar(pTmat,'*Trial*');

fcond = det_fnames(cmod, fieldnames(SallT), fnames);

Sgrad = SallT.(fcond{1}).grad;
Chan = SallT.(fcond{1}).label'; 
% ftTuto : "essential to indicate removing sensors when calculating the lead fields"
Sgrad = ft_convert_units(Sgrad,'mm');

%----
% Create lead field = forward solution
disp(' '),disp('Create lead field (forward solution)')
cfg = [];
cfg.grad = Sgrad;
cfg.vol = subj_vol;
cfg.grid = subj_grid;
cfg.reducerank = 2;
cfg.channel = Chan;  % Check if it is a good definition of channels 
leadfield_grd = ft_prepare_leadfield(cfg);

%----
% Pre-process trials data as specified in trialopt
% structure

if ~isempty(strproc)
    for nc = 1 : length(fcond)
        SallT.(fcond{nc}) = meg_trials_preproc(SallT.(fcond{nc}), trialopt);
    end
end

% Concatenate trials of all conditions
dataAll = SallT.(fcond{1});
for i = 2 : length(fcond)
    dataAll = ft_appenddata([], dataAll, SallT.(fcond{i}));
end

% Average of all trials 
disp('Averaging trials')
cfg = [];
cfg.keeptrials = 'no';  
cfg.covariance = 'yes';
cfg.removemean = 'no';  % Baseline correction already done
cfg.covariancewindow = 'all';
avgTrialsAll = ft_timelockanalysis(cfg, dataAll);

cfg.keeptrials = 'yes';

% Average of trials per condition
avgTrialsCond = struct;
for j=1:length(fcond)
    avgTrialsCond.(fcond{j}) = ft_timelockanalysis(cfg, SallT.(fcond{j}));
end

%----
% LCMV calculus from all average trials of all
% conditions
disp('LCMV source analysis')
cfg        = [];
cfg.method = 'lcmv';
cfg.grid   = leadfield_grd;
cfg.vol    = subj_vol;
cfg.lcmv.lambda     = '5%';
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.fixedori   = 'yes'; % L'orientation est calculee via une ACP // orientation 3 dipoles
sourceAll  = ft_sourceanalysis(cfg, avgTrialsAll);

% Apply the filter from modeling of all average to
% each condition
cfg.grid.filter = sourceAll.avg.filter;

%----

disp('Compute source signal and Z-normalization')
fdos = make_dir([megpath,filesep,'SourceSup_Znorm',strproc],1);

sourceCond = struct;
for j = 1:length(fcond)
    cond = fcond{j};
    sourC = ft_sourceanalysis(cfg, avgTrialsCond.(cond));
    mom = sourC.avg.mom;
    time = sourC.time;
    iBSL = find(time > tBSL(1) & time < tBSL(2));
    % Normalized by remove mean value of the baseline
    % and divide by its standard deviation
    sourC.avg.z = mom;
    sourC.avg.z2 = mom;
    for n = 1:length(mom)
        if ~isempty(mom{n})
            sourC.avg.z{n} = ( mom{n} - mean(mom{n}(iBSL)) ) / std( mom{n}(iBSL) );
            sourC.avg.z2{n} = sourC.avg.z{n}.^2;                                    
        end
    end
    sourceCond.(cond)=sourC;

    % Figures of the superimposed source signals
    meg_loc_sourcesup_fig(sourC, tBSL, cond, fdos, addonfig)
    
    avgTrialsCond.(cond).cfg.previous = [];
end

%----
% Save source signals, leadfield and average trials

suff = meg_matsuff(nTmat, strproc);
if ~isempty(suff)
    suff=['_',suff];
end
save([megpath,filesep,'SourceModel_hdmYH_Colin27BS',suff],'sourceCond')
save([megpath,filesep,'avgTrials',suff],'avgTrialsCond')
save([megpath,filesep,'LeadField_hdmYH_Colin27BS'],'leadfield_grd')


%
function fnames = det_fnames(cmod, allfnames, snames)
% Search trials fields to considere
switch cmod
    case 1                  % All fieldnames
        fnames = allfnames;
    case 2                  % Fieldnames according to snames index
        ifn = snames;
        if max(ifn) <= length(allfnames)
            fnames = allfnames(ifn);
        else
            fnames = allfnames;
            disp('All conditions will be taken into consideration')
        end
    case 3                  % Match search names snames to data fieldnames 
        ifn = zeros(length(allfnames),1);
        for n = 1 : length(allfnames)
            idx = find(strcmp(snames, allfnames{n})==1);
            if ~isempty(idx)
                ifn(n) = idx;
            end
        end
        if sum(ifn)==0
            disp('All conditions in data set will be taken into consideration')
            disp(allfnames')
            fnames = allfnames;
        else
            fnames = allfnames(ifn(ifn>0));
        end
end

