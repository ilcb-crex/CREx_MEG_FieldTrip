function meg_loc_headmodel(mripath, megpath, forwopt)
% Define the head model from the segmented MRI of the subject
% Define the dipole grid from a template grid forwopt.tempgrid
% by applying a non-linear tranformation to fit the subject using the reslice 
% MRI

fprintf('\n\n\t-------\nVolume conduction model preparation\n\t-------\n')

%-- Load the preprocessed MRI (reslice and segmented by FieldTrip)

% Use the raw MRI to process them if matrices are not found in the MRI
% directory.

% Found the reslice one
[presl,nresl] = dirlate(mripath,'mriResl*.mat');

% Found the segmented one
[pseg,nseg] = dirlate(mripath,'mriSeg*.mat');

segpath = [];

% If the 2 are found inside the directory, they are loaded. Otherwise, they
% are process using meg_mri_reslseg that interface FieldTrip function
if ~isempty(presl) && ~isempty(pseg)
    disp(' '), disp(['--> ',mripath])
    disp(['Read resliced MRI ',nresl,'...'])
    mriResl = loadvar(presl,'mriResl*');  
    disp(['Read segmented MRI ',nseg,'...']), disp(' ')
    mriSeg = loadvar(pseg,'mriSeg*');
    segpath = pseg;
    
else
    % Lecture image...
    if ~isempty(forwopt.formimg)
        % Search for MRI file
        [pmrimg, nmrimg] = find_mrifile(mripath);
    else
        [pmrimg, nmrimg] = dirlate(mripath,['*.',forwopt.formimg]);
    end
    if ~isempty(pmrimg)
        disp(['Reslice and segment ',nmrimg])
        [mriResl, mriSeg] = meg_mri_reslseg(pmrimg,1);
        [pseg, nseg] = dirlate(mripath,'mriSeg*.mat');
        segpath = pseg;
    end
end

%-- Construct of realistic model (using singleshell method)

if ~ismepty(segpath)
    
    disp('Construct realistic model by SingleShell method')
    cfg = [];
    cfg.method = 'singleshell';
    subj_vol = ft_prepare_headmodel(cfg, mriSeg);
    % Assuming there is no modification of gradiometers positions
    % from one run to another for the same subject
    % Defined associated raw MEG dataset (on the directory corresponding to
    % the first Run of MEG recording)

    %-- Draw figure with MEG channels + head conduction volume
    
    draw = filepath4d(megpath);
    if ~isempty(draw)
        Sgrad = ft_read_sens(draw);
        meg_volmodelchan_fig(subj_vol, Sgrad, segpath, mripath)
    else
        disp('Unable to find raw dataset inside this directory :')
        disp(megpath)
    end
    
    
    %-- Create the subject specific grid using the template grid
    
    disp('Create subject specific grid using template grid')
    disp('Apply non-linear normalization to adjust grid to the subject MRI')
    
    cfg = [];
    cfg.grid.warpmni  = 'yes';
    cfg.grid.template = forwopt.tempgrid;  
    cfg.grid.nonlinear = 'yes'; 
    cfg.mri = mriResl; %%% Assuming it's the resliced one...
    subj_grid = ft_prepare_sourcemodel(cfg);
    % Figure
    meg_subjgrid_fig(subj_vol, subj_grid,segpath,mripath)

    save([mripath, filesep, 'headModel_', nseg], 'subj_grid', 'subj_vol')
end