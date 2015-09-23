function meg_localiz_forwardMRI(mripath, megpath, forwopt)


fprintf('\n\n\t-------\nVolume conduction model preparation\n\t-------\n')

% Read segmented MRI of the subject

[pmriresl,nmriresl] = dirlate(mripath,'mriResl*.mat');
[pmriseg,nmriseg] = dirlate(mripath,'mriSeg*.mat');

if ~isempty(pmriresl) && ~isempty(pmriseg)
    disp(' '), disp(['--> ',mripath])
    disp(['Read resliced MRI ',nmriresl,'...'])
    mriResl = loadvar(pmriresl,'mriResl*');  
    disp(['Read segmented MRI ',nmriseg,'...']), disp(' ')
    mriSeg = loadvar(pmriseg,'mriSeg*');
    segpath = pmriseg;
    ok=1;
else
    % Lecture image...
    if ~isempty(forwopt.formimg)
        % Search for MRI file
        [pmrimg, nmrimg] = find_mrifile(mripath);
    else
        [pmrimg, nmrimg] = dirlate(mripath,['*.',forwopt.formimg]);
    end
    if isempty(pmrimg)
        ok=0;
    else
        disp(['Reslice and segment ',nmrimg])
        [mriResl, mriSeg] = meg_mri_reslseg(pmrimg,1);
        [pmriseg, nmriseg]=dirlate(mripath,'mriSeg*.mat');
        segpath = pmriseg;
        ok=1;
    end
end

% Construct of realistic model (using singleshell method)
if ok
    
    disp('Construct realistic model by SingleShell method')
    cfg = [];
    cfg.method = 'singleshell';
    volcondmodel = ft_prepare_headmodel(cfg,mriSeg);
    save([mripath,filesep,'volcond_',nmriseg],'volcondmodel') 

    % Assuming there is no modification of gradiometers positions
    % from one run to another for the same subject
    % Defined associated raw MEG dataset (on the directory corresponding to
    % the first Run of MEG recording)

    draw = filepath4d(megpath);
    if ~isempty(draw)
        Sgrad = ft_read_sens(draw);
        meg_volmodelchan_fig(volcondmodel,Sgrad,segpath,mripath)
    else
        disp('Unable to find raw dataset inside this directory :')
        disp(megpath)
    end
    
    disp('Create subject specific grid using template grid')
    
    
    % Create the subject specific grid using the template grid
    disp('Apply non-linear normalization to adjust grid to the subject MRI')
    cfg = [];
    cfg.grid.warpmni  = 'yes';
    cfg.grid.template = forwopt.tempgrid;  
    cfg.grid.nonlinear = 'yes'; 
    cfg.mri = mriResl; %%% Assuming it's the resliced one...
    subj_grid = ft_prepare_sourcemodel(cfg);
    % Figure
    meg_subjgrid_fig(volcondmodel,subj_grid,segpath,mripath)
    save([mripath,filesep,'subj_grid_temp',nmriresl],'subj_grid')
end