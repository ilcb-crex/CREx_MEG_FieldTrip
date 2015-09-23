function template_grid = meg_create_template_grid(savpath)
% CREATE_TEMPLATE_GRID
% Construction d'un modele de source (grille) base sur un volume MRI 
% de reference. Trois etapes sont executees pour obtenir ce template a
% partir des fonctions FieldTrip :
% 1) Segmentation du volume de reference par ft_volumesegment
% 2) Creation du modele de conduction par ft_prepare_headmodel
%    avec la methode "singleshell" (realisically shaped single shell 
%    approximation, based on the implementation from Guido Nolte)
% 3) Construction du modele de source (grille 3D) a partir de la fonction
%    ft_prepare_sourcemodel. Ces parametres sont modifiable en debut de script  :
%   - unitgrid : unite pour la grille ('mm')
%   - XYZgrid : matrice representant les points de definition de la grille
%            ([-200:10:200 ; -200:10:200 ; -200:10:200])
%   - tempMRIpath : chemin d'acces complet au template MRI a utiliser
%   - savpath : chemin pour la sauvegarde du modele de source (template_grid.mat).
%
% Ce template peut ensuite etre utilise pour permettre une correspondance
% des points du cerveau entre chaque sujet. La meme grille de reference est
% alors deformee non lineairement pour s'ajuster au volume de chaque cerveau.
% Notes supplementaires de JBM
% voir l'exemple sur le site de FieldTrip :
% http://fieldtrip.fcdonders.nl/example/create_single-subject_grids_in_
% individual_head_space_that_are_all_aligned_in_mni_space
% JMB juin 2013
% version fieldtrip 20130319

% ________
% Parameters to adjust

% Chemin du volume MRI de reference
tempMRIpath = 'C:\Program Files\MATLAB\R2013a\toolbox\fieldtrip\external\spm8\templates\T1.nii';

% Systeme de coordonnees du volume MRI de reference a indique a la fonction FieldTrip ft_volumesegment
coordsys = 'spm'; 

% Units for the model grid
unitgrid = 'mm';  

% Grid definition 
XYZgrid = [-200:10:200 ; -200:10:200 ; -200:10:200];

% Save path
if nargin==0
    savpath = pwd;
end
% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

% ________
% Read the MRI template volume
template = ft_read_mri(tempMRIpath);
template.coordsys = coordsys; % Specify the system of coordinates

% ________
% Reslice the mri volume
%temprs = ft_volumereslice([],template);

% ________
% Segment the mri volume
template_seg = ft_volumesegment([], template);
 
% ________
% Construct the volume conduction model with singleshell method
cfg          = [];
cfg.method   = 'singleshell';
template_vol = ft_prepare_headmodel(cfg, template_seg);
 
% ________
% Construct the dipole grid
cfg = [];
cfg.grid.xgrid  = XYZgrid(1,:);
cfg.grid.ygrid  = XYZgrid(2,:);
cfg.grid.zgrid  = XYZgrid(3,:);
cfg.grid.unit   = unitgrid;
cfg.grid.tight  = 'yes';
cfg.inwardshift = -15.0;        % depth of the bounding layer for the source space, relative to the head model surface (default = 0)
cfg.vol        = template_vol;  % decreasing inwardshift = reduce the size of the source area compare to the head surface (template or specific MRI)
template_grid  = ft_prepare_sourcemodel(cfg);


figure
set(gcf,'units','centimeters','position',[5 6 20 18])
subplot(221), ft_plot_vol(template_vol)
hold on, ft_plot_mesh(template_grid)
view(0,0), axis on, grid on
title('From the right'), xlabel('x (mm)')
zlabel('z (mm)')

subplot(222), ft_plot_vol(template_vol)
hold on, ft_plot_mesh(template_grid);
view(90,0), axis on, grid on 
title('Behind'), ylabel('y (mm)')
zlabel('z (mm)')
% BUG avec cette vue : les points de la grille n'apparaissent pas sur le 
% volume. Resolu avec set(gcf,'renderer','opengl') mais l'enregistrement
% avec export_fig (meme avec l'option '-opengl') fait reapparaitre le BUG.

subplot(223), ft_plot_vol(template_vol)
hold on, ft_plot_mesh(template_grid)
view(90,90), axis on, grid on
title('Above'), ylabel('y (mm)')
xlabel('x (mm)')


for s=1:3
    subplot(2,2,s), posa=get(gca,'position');
    set(gca,'position',[posa(1) posa(2)-0.03 posa(3:4)])
end

titfig = {'Template head model and dipole grid construct from :'; tempMRIpath};
annotation(gcf,'textbox','String',titfig,'interpreter','none',...
    'FontSize',10,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);


[T,nam]=fileparts(tempMRIpath); %#ok
namfig=['TemplateGrid_',nam];
export_fig([savpath,filesep,namfig,'.jpeg'],'-m1.5')
close

save([savpath,filesep,'template_',nam],'template_grid','template_vol')
