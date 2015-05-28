function [subj_vol, subj_grid, M1] = meg_loc_headmodel_hdmYH(megpath, savpath)
% Adapte du code headmodel_BIU de Yuval Harpaz
% Le template IRM Colin27_BS.nii modifie depuis 
% spm/canonical/single_subj_T1.nii sur Brainstorm en reperant les points
% fiduciaux est utilise
% Restreint au modele de tete obtenu par ces deux etapes :
% - la segmentation SPM du template pour definir le volume correspondant
% au crâne (skull)
% - la coregistration par SPM du template IRM avec le headshape en utilisant
% les points fiduciaux 
%
% La grille de dipole est celle obtenue a partir du template puis
% transformee pour correspondre avec l'espace du sujet (donnees MEG) grace
% a la matrice de transformation M1 obtenue apres la coregsitration par
% SPM.
%
% creates volume for source localizaton.
% Nolte models based on 'scalp', 'iskull' (default) or 'ctx' (not
% recommended).
% source- name of data file (c,rfhp0.1Hz is the default). hs_file
% has to be there too. uses template MRI unless specify MRI='anat.nii'. MRI
% can be nii or img format. for AFNI files use 3dAFNItoNIFTI for
% conversion.
% res- resolution, 5 or 10mm (default).
% model='singleshell' or localspheres'
% fidORhs - template MRI to fiducials only or also to headshape

disp(' ')
disp('Head model computation using Colin27_BS.nii template MRI')
disp('and SPM coregistration')
disp('--------'), disp(' ')

%------
% Initialize
[subj_vol, subj_grid, M1] = deal([]);

%------
% Check for inputs

if nargin==0
    disp('Raw MEG data path is missing as first argument function')
    return;
end
if nargin == 1
    savpath = megpath;
end

%------
% Parameters (fixed)

template_name = 'Colin27_BS.nii'; 
volType = 'iskull';
% Dipole grid definition that suits to Colin template
XYZgrid = {-70:10:70 ; -105:10:75 ; -60:10:80};

%------
% Check if required data are available
% -> MEG data, headshape file and template MRI

pMEG = filepath4d(megpath); 
if isempty(pMEG)
    disp('Raw MEG data not found in MEG path directory')
    disp(['--> ',megpath])
    return;
end

headshapefile = [megpath, filesep, 'hs_file'];
if isempty(dir(headshapefile))
    disp('Head shape file not found in MEG data directory')
    disp(['--> ',megpath])
    disp('Attempt to find hs_file file')
    return;
else
    hs = ft_read_headshape([megpath, filesep, 'hs_file']);
    if isempty(hs) || isempty(hs.pnt)
        disp('!!! hs_file corrupt : ')
        disp('Impossible to compute head model')
        disp(['--> ',megpath])
        return
    end
end

pMRI = which(template_name);
if isempty(pMRI)
    disp(' ')
    disp('!!!!!')
    disp([template_name,' not found in Matlab path...'])
    disp('Using of single_subj_T1.nii canonical SPM template')
end

%_____ GO !

%----
% Extract of MEG data (1 s)

cfg = [];        
cfg.dataset = pMEG;
cfg.trialfun = 'trialfun_1s';  % Fonction de BIUtool pour extraire 1 s de donnees
cfg = ft_definetrial(cfg);     
ftData = ft_preprocessing(cfg);

ftData.grad = ft_convert_units(ftData.grad,'mm');

if ~isfield(ftData,'dimord')
    ftData.dimord = 'chan_time';
end

% Add SPM8 toolbox to Matlab path
if ~spmpath('add')
    return;
end

%----
% Convert to SPM format
spmData = spm_eeg_ft2spm(ftData,'spmTempfile');

% Include headshape and fiducial informations
cfg = [];
cfg.D = spmData;
cfg.task = 'headshape';
cfg.headshapefile = headshapefile;
cfg.source = 'convert';
cfg.regfid{1, 1} = 'NZ';
cfg.regfid{1, 2} = 'NZ';

cfg.regfid{2, 1} = 'L';
cfg.regfid{2, 2} = 'L';

cfg.regfid{3, 1} = 'R';
cfg.regfid{3, 2} = 'R';

cfg.regfid{4, 1} = 'fiducial4';
cfg.regfid{4, 2} = 'fiducial4';
cfg.regfid{5, 1} = 'fiducial5';
cfg.regfid{5, 2} = 'fiducial5';
cfg.save = 1;
spmData = spm_eeg_prep(cfg);

spmData.inv = {struct('mesh', [])};
spmData.inv{1}.date    = char(date,datestr(now,15));
spmData.inv{1}.comment = {''};
% Adding mesh (put in MNI space)
spmData.inv{1}.mesh = spm_eeg_inv_mesh_hdmYH(pMRI, 2); 
% default 'single_subj_T1.nii', mesh of size 2 
% Canonical cortical mesh => filename  = fullfile(Cdir, 'cortex_8196.surf.gii');
% Include new tragus definition according to MEG center - Marseille customs

template_mesh = spmData.inv{1}.mesh;

%----
% Coregistration with template MRI

% Fiducials
MEGfid = spmData.fiducials; % MEG subject space
MRIfid = template_mesh.fid; % MNI template space
MEGfid.fid.pnt   = MEGfid.fid.pnt(1:3,:);
MEGfid.fid.label = MEGfid.fid.label(1:3,:);
MRIfid.fid.pnt   = MRIfid.fid.pnt(1:3,:);
MRIfid.fid.label = MEGfid.fid.label(1:3,:);

cfg =[];
cfg.sourcefid = MEGfid;
cfg.targetfid = MRIfid;
cfg.useheadshape = 1;
cfg.template = 2;
[M1, Sdat] = spm_eeg_inv_datareg_hdmYH(cfg); % MEG --> MNI

% Display of M1 calculation step
meg_loc_hdmYH_M1step_fig(Sdat, savpath)

spmData.inv{1}.datareg = struct;
spmData.inv{1}.datareg.sensors = spmData.sensors('MEG');
spmData.inv{1}.datareg.fid_eeg = cfg.sourcefid;
spmData.inv{1}.datareg.fid_mri = ft_transform_headshape(inv(M1), cfg.targetfid); 
spmData.inv{1}.datareg.toMNI = template_mesh.Affine*M1;
spmData.inv{1}.datareg.fromMNI = inv(spmData.inv{1}.datareg(1).toMNI);
spmData.inv{1}.datareg.modality = 'MEG';


datareg = spmData.inv{1}.datareg;

% Mesh - MEG subject space : MNI --> MEG
subj_mesh = spm_eeg_inv_transform_mesh(inv(M1), template_mesh);

% Figures of coregistration 
figopt = struct;
figopt.savpath = savpath;
figopt.mripath = pMRI;
figopt.megpath = pMEG;

spmeg_checkdatareg(datareg, subj_mesh, figopt); 

% Build vol
template_vol_spm = export(gifti(template_mesh.(['tess_',volType])), 'spm');

template_vol=[];
template_vol.bnd = export(gifti(template_vol_spm), 'ft');
template_vol.type = 'nolte';

% Adding cortex volume 
template_ctx_spm = export(gifti(template_mesh.tess_ctx), 'spm');
template_ctx=[];
template_ctx.bnd = export(gifti(template_ctx_spm), 'ft');


subj_vol_spm = subj_mesh.(['tess_',volType]);
subj_vol = [];
subj_vol.bnd = export(gifti(subj_vol_spm), 'ft');
subj_vol.type = 'nolte';

%----
% Construct the dipole grid
cfg = [];
cfg.grid.xgrid  = XYZgrid{1};
cfg.grid.ygrid  = XYZgrid{2};
cfg.grid.zgrid  = XYZgrid{3};
cfg.grid.unit   = 'mm';
% cfg.grid.tight  = 'yes';
cfg.inwardshift = -1.5;        % depth of the bounding layer for the source space, relative to the head model surface (default = 0)
cfg.vol        = template_vol;  % decreasing inwardshift = reduce the size of the source area compare to the head surface (template or specific MRI)
template_grid  = ft_prepare_sourcemodel(cfg);


% Changing position of grid point from MNI to individual positions.
subj_grid         = template_grid;
subj_grid.pos     = spm_eeg_inv_transform_points(inv(M1), template_grid.pos);

figopt.istemplate = 1;
meg_loc_checkvolgrid(template_vol, template_grid, figopt)

figopt.istemplate = 0;
meg_loc_checkvolgrid(subj_vol, subj_grid, figopt)

spmpath('rm');

[T,templname] = fileparts(pMRI); %#ok

save([savpath,filesep,'template_',templname],'template_grid','template_vol','template_ctx')

delete('spmTempfile*')

