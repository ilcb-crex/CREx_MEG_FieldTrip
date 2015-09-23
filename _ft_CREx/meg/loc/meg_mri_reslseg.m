function [mriResl,mriSeg] = meg_mri_reslseg(mripath,savopt)
% Realign, reslice & segment MRI anatomic volume (brain)
% savopt = 1 : save Matlab file and figures of resliced and 
% segmented images (don't save otherwise)
if nargin<2 || savopt~=1
    savopt=0;
end
[mridir,nmri] = fileparts(mripath);
try
    mri=ft_read_mri(mripath);
    
    % Realign according to fiducial coordinates 
    if isfield(mri,'hdr') && isfield(mri.hdr,'fiducial')...
            && isfield(mri.hdr.fiducial,'mri')
        cfg=[];
        cfg.coordsys = 'ctf';
        cfg.fiducial.nas = mri.hdr.fiducial.mri.nas;
        cfg.fiducial.lpa = mri.hdr.fiducial.mri.lpa; 
        cfg.fiducial.rpa = mri.hdr.fiducial.mri.rpa;
        mriReal = ft_volumerealign(cfg,mri);
        if savopt
            save([mridir,filesep,'mriReal'],'mriReal')
        end
        mri = mriReal;
    end

    % Reslice  
    cfg=[];
    cfg.coordsys='ctf';
    mriResl = ft_volumereslice(cfg,mri); % => coordsys: 'spm'
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % cfg=[];
   % cfg.coordsys = 'ctf';
   % mriResl = ft_volumenormalise(cfg,mriResl);  % ADD
    
    % Figure of resliced volume
    if savopt
        cfg = [];
        cfg.interactive   = 'no';
        ft_sourceplot(cfg,mriResl);
        export_fig([mridir, filesep, 'mriResl_',nmri,'.jpeg'],'-m1.5')
        close
        save([mridir,filesep,'mriResl'],'mriResl')
    end
    
    % Volume segmentation
    cfg = [];
    cfg.output= {'brain'}; %,'skullstrip'};
    mriSeg = ft_volumesegment(cfg, mriResl);
    % Figure of segmentation result
    if savopt
        save([mridir,filesep,'mriSeg'],'mriSeg') 
        mri_combine = mriResl;
        mri_combine.seg  = double(mriSeg.brain);
        mri_combine.mask = mri_combine.seg(mri_combine.seg>0);
        cfg = [];
        cfg.interactive   = 'no';
        cfg.funparameter  = 'seg';
        cfg.funcolormap   = 'jet';
        cfg.opacitylim    = [0 1.5];
        cfg.maskparameter = 'mask';
        cfg.location = 'center';
        ft_sourceplot(cfg,mri_combine);  
        export_fig([mridir,filesep,'mriSegBrain_',nmri,'.jpeg'],'-m1.5')
        close
    end
catch 
    disp('Impossible to work with file :')
    disp(mripath)
end
