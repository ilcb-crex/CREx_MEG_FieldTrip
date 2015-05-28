function meg_loc_map_hdmYH(megpath, opt, trialopt)

%- Check options
defopt = struct('win', struct('slidwin',[], 'lgwin', []),...
    'cond', [], 'tempmri', [], 'savepath', megpath);
if nargin < 2
    opt = defopt;
else
    opt = check_opt(opt, defopt);
end

% Search SourceModel data obtained from previous calculation on 
% preprocessing trials
% Trials preprocessing options
if nargin < 3 || isempty(trialopt)
    trialopt = struct('redef',struct('do',0), 'LPfilt',struct('do',0),...
        'resamp', struct('do',0));
end
[T, TT,strproc] = meg_trials_preproc([],trialopt);   %#ok compat M7
% We will looking for SourceModel data which contain strproc suffix

cond = opt.cond;
templateMRI = opt.tempmri;
winopt = opt.win;
spath = opt.savepath;

if isempty(templateMRI)
    template_name = 'Colin27_BS.nii';
    % Search for MRI template
    pMRI = which(template_name);
    if isempty(pMRI)
        disp(' ')
        disp('!!!!!')
        disp([template_name,' not found in Matlab path...'])
        disp('Impossible to edit map of localisation')
        return;
    end
    templateMRI = ft_read_mri(pMRI);
end

% Search for SourceModel*.mat : source signals from beamforming
disp(['Search of source signals : SourceModel_hdmYH*',strproc,'*.mat'])        
[pSo, nSo] = dirlate(megpath,['SourceModel*',strproc,'*.mat']);

if isempty(pSo)
    disp('!!! Source signals MAT data file not found in directory')
    disp(['--> ',megpath])
    return;
end

% Search for HeadModel*.mat : need of M1 trasformation matrix
disp('Search of M1 transformation matrix in HeadModel_hdmYH_Colin27BS.mat')        
[pHdm, nHdm] = dirlate(megpath,'HeadModel_hdmYH_Colin27BS*.mat');

if isempty(pHdm)
    disp('!!! HeadModel MAT data file not found in directory')
    disp(['--> ',megpath])
    return;
end

%____ GO !

disp(['Load source signals from ', nSo])
load( pSo, 'sourceCond')

fcond = fieldnames(sourceCond);
if ~isempty(cond)
    fcond = cond;
end

disp(['Load M1 from head model ', nHdm])
load( pHdm, 'M1')

mrireal = templateMRI; 
mrireal.transform = inv(M1)*templateMRI.transform; %#ok
mrireal.coordsys = 'ctf';       

fmap = make_dir([spath, filesep,'SourceMap_Znorm',strproc],1);
      
for nc = 1:length(fcond)
    fnam = fcond{nc};
    dos = make_dir([fmap, filesep, 'Frames_',fnam],0);
    sourC = sourceCond.(fnam);
    figopt = struct;
    figopt.param = 'z2';
    figopt.fname = fnam;
    figopt.savpath = dos;
    figopt.matpath = pSo;
    figopt.slidwin = winopt.slidwin;
    figopt.lgwin = winopt.lgwin;
    meg_loc_map_framefig(sourC, mrireal, figopt)
end


%--- Check figopt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end