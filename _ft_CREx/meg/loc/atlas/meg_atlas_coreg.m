% To obtain the transformation matrix (to coregister atlas with template
% Colin27_BS used for localisation) : SPM coregistration between FT volume
% (from fieldtrip/template/single_subj_T1.nii segmentation) and BS volume.

ft_defaults

%---- Load the template used for localisation
Stemp = load('template_Colin27_BS.mat');
Vol_BS = struct('vertices', Stemp.template_vol.bnd.pnt,...
    'faces', Stemp.template_vol.bnd.tri);
Ctx_BS = struct('vertices', Stemp.template_ctx.bnd.pnt,...
    'faces', Stemp.template_ctx.bnd.tri);
           
%---- Read the atlas
pAtlas = 'atlas_aal_ROI_MNI_V4_FT.nii';
atlas = ft_read_atlas(pAtlas);

%---- Define atlas coordinates as a N*3 matrix (N = prod(dim) = 902629) 
dim = atlas.dim;
[X, Y, Z]  = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
Apos   = [X(:) Y(:) Z(:)];

%---- Apply transform to put atlas position in head coordinates
% Left and Right become like fieldtrip and BS convention
Mtr = atlas.transform; 
pos = Apos;
pos(:,4) = 1;
pos = pos * Mtr';
pos = pos(: , 1:3);

%---- Load the template template_Colin27_FT.mat process by SPM (meg_loc_headmodel_hdmYH)
% It contain volume that fits to the atlas inside FieldTrip toolbox
% template/atlas/aal/ROI_MNI_V4.nii
Satl = load('template_Colin27_FT.mat');
Vol_A = struct('vertices', Satl.template_vol.bnd.pnt,...
    'faces', Satl.template_vol.bnd.tri);

%---- Fiducials definition for the FieldTrip template single_subject_T1.nii
%(fieldtrip\template\anatomy\) - same as MNI atlas (pos coordinates)
FTfid_mni = [ 1 83 -41 ; -88 -24 -53 ; 88 -24 -55];

%---- Fiducials definition of Colin template from BraiStorm
%(template_Colin_BS.nii, used for the localisation)

% Coordinates already in MNI space
BSfid_mni = [1 82.5 -43 ; -88 -24.5 -54 ; 89 -23.5 -56] ;

%---- Realign (by SPM co-registration)

spmpath('add')   

BStemp = struct('fid', []); % MEG subject space
BStemp.fid.pnt   = BSfid_mni;
BStemp.fid.label = {'nas';'lpa';'rpa'};
BStemp.pnt = Vol_BS.vertices;
BStemp.tri = Vol_BS.faces;

Atemp = struct('fid', []);
Atemp.fid.pnt   = FTfid_mni;
Atemp.fid.label = {'nas';'lpa';'rpa'};
Atemp.pnt = Vol_A.vertices;
Atemp.tri = Vol_A.faces;

cfg =[];
cfg.sourcefid = Atemp;  
cfg.targetfid = BStemp; 
cfg.useheadshape = 1;
cfg.template = 2;
[M1, Sdat] = spm_eeg_inv_datareg_hdmYH(cfg); 
meg_loc_hdmYH_M1step_fig(Sdat, pwd)

spmpath('rm')

%---- Apply transform to put atlas in BS template coordinates
pos2 = pos;
pos2(:,4) = 1;
pos2 = pos2 * M1';
pos2 = pos2(: , 1:3);

%---- Associate tissue identification number
id_tis = atlas.tissue(:); %  902629x1 

%---- Figure

Alab = atlas.tissuelabel;

Ntis = length(Alab);
colc = color_group(Ntis);

figure, 
set(gcf,'units','centimeters', 'position', [10 7 28 20],'color',[0 0 0])
set(gca,'color',[0 0 0], 'position',[0.005 0.00 .99 .92])

hold on

patch(Vol_BS,'edgecolor','none','facecolor',[0 .9 .9],'facealpha',.1,...
    'facelighting','gouraud','hittest','off');
patch(Ctx_BS,'edgecolor','none','facecolor',[1 .8 0],'facealpha',.15,...
    'facelighting','gouraud','hittest','off');

for n = 1 : Ntis
    ig = find(id_tis == n);
    plot3(pos2(ig,1), pos2(ig,2), pos2(ig,3),'o','markersize',4,...
        'markerfacecolor',colc(n,:),'markeredgecolor','none',...
        'displayname',Alab{n})
end
view(90, 90)
lightangle(140, 50)
axis tight equal off;
set(gcf, 'WindowButtonDownFcn', @dispname);

saveas(gcf,'atlas_coreg_Colin27_BS.fig')

atlas.transform_ini = atlas.transform;
atlas.transform = M1 * Mtr;
atlas.pos = pos2;

save('atlas_Colin27_BS','atlas')
