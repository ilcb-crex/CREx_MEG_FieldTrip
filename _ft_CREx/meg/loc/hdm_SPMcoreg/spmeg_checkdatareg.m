function spmeg_checkdatareg(datareg, mesh, figopt) 
% Modifier a partir de spm_eeg_inv_checkdatareg(mesh, sensors)
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
% Jeremie Mattout
% $Id: spm_eeg_inv_checkdatareg.m 3388 2009-09-11 08:44:35Z vladimir $
%
% Display of the coregistred meshes and sensor locations in MRI space for
% quality check by eye.
% Fiducials which were used for rigid registration are also displayed
%
% --- Adapt CREx 140826
% Figure representant les vertices des differents tissus + les capteurs +
% fiduciaux + headshape arrangee pour faciliter la verification de la
% coregistration par SPM.
% Une figure additionnelle est realisee avec les trois vues en plan (coronale,
% axiale, frontale).
%
% figopt contient les informations sur les chemins des donnees MEG et de 
% l'IRM utilise pour la coregistration (figopt.mripath et figopt.megpath) :
% si ces champs sont renseignes, ils sont apposes sur la figure
% Le dossier de destination des figures est renseigne dans figopt.savpath

%----
% Check for input options

defopt = struct('mripath',[], 'megpath',[], 'savpath', pwd);
if nargin < 3 || isempty(figopt) || ~isstruct(figopt)
    figopt = defopt;
else
    fn = fieldnames(defopt);
    for j = 1:length(fn)
        if ~isfield(figopt, fn{j})
            figopt.(fn{j}) = defopt.(fn{j});
        end
    end
end
            
%----
% Define path informations that will be added to the figure

datapath = def_datapath(figopt);


%----
% Figure with the big 3D view

figure
set(gcf,'visible','off','units','centimeters','position',[7 5 20 20.8])
set(gca,'position',[ 0.0145 0.0216 0.9313 0.9034])
hold on

[h, leg] = disp_all(datareg, mesh);

view(92,26)
axis tight
axis off
h_leg = legend(h, leg);
set(h_leg,'fontsize',8,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])
set(h_leg,'position',[0.76 0.73 0.16 0.16]); %
hold off

annotation(gcf,'textbox','String', '3D-Display of SPM co-registration','interpreter','none',...
        'FontSize',13,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.0013 0.9364 0.9934 0.0581]);

annotation(gcf,'textbox','String', datapath,'interpreter','none',...
    'FontSize',11,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','left',...
    'FitBoxToText','off','Position',[0.0367 0.8575 0.6991 0.0687]);

export_fig([figopt.savpath, filesep, 'CheckDataReg_CoregSPM_3Ddisp_',datestr(now,'yymmdd_HHMM'),'.png'],'-m1.5')
saveas(gcf, [figopt.savpath, filesep, 'CheckDataReg_CoregSPM_3Ddisp_',datestr(now,'yymmdd_HHMM'),'.fig'])
close

%----
% Figure with 3 views

figure
set(gcf,'visible','off','units','centimeters','position',[7 5 20 20.8])

gc = zeros(3,1);

% From the right
gc(1) = subplot(2,2,1);
hold on
disp_all(datareg, mesh);
view(0,0)
xlabel('x (mm)'), zlabel('z (mm)')
set(gca,'fontsize',10)
title('From the right','fontsize',12)
axis tight

% Behind
gc(2) = subplot(2,2,2);
hold on
disp_all(datareg, mesh);
view(90,0)
ylabel('y (mm)'), zlabel('z (mm)')
set(gca,'fontsize',10)
title('Behind','fontsize',12)
axis tight

% Above
gc(3) = subplot(2,2,3);
hold on
[h, leg] = disp_all(datareg, mesh);
view(90,90)
xlabel('x (mm)'), ylabel('y (mm)')
set(gca,'fontsize',10)
title('Above','fontsize',12)
axis tight

subplot(2,2,4)
pos = get(gca,'position');
h_leg = legend(h, leg);
set(h_leg,'fontsize',8,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])
set(h_leg,'position',[pos(1)+pos(3)./4 pos(2)+pos(4)-0.16 0.16 0.16]); 
axis off

% Put the subplot to the bottom
for i = 1:3
    gpos = get(gc(i), 'position');
    set(gc(i), 'position',  [gpos(1) gpos(2)-0.03 gpos(3:4)])
end

annotation(gcf,'textbox','String', '3D-Display of SPM co-registration','interpreter','none',...
        'FontSize',14,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.0013 0.9364 0.9934 0.0581]);

annotation(gcf,'textbox','String', datapath,'interpreter','none',...
    'FontSize',8,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','left',...
    'FitBoxToText','off','Position',[0.5042 0.0840 0.4443 0.1314]);

export_fig([figopt.savpath, filesep, 'CheckDataReg_CoregSPM_3subp_',datestr(now,'yymmdd_HHMM'),'.png'],'-m1.5')
close

%----
% Make the drawing
% Display meshs, headshape, sensors and fidicials
function [h, leg] = disp_all(datareg, mesh) 

    % --- DISPLAY ANATOMY ---
    %==========================================================================
    Mcortex = mesh.tess_ctx;
    Miskull = mesh.tess_iskull;
    Mscalp  = mesh.tess_scalp;

    % Cortical Mesh
    %--------------------------------------------------------------------------
    face    = Mcortex.face;
    vert    = Mcortex.vert;
    h_ctx   = patch('vertices',vert,'faces',face,'EdgeColor','b','FaceColor','b');


    % Inner-skull Mesh
    %--------------------------------------------------------------------------
    face    = Miskull.face;
    vert    = Miskull.vert;
    h_skl   = patch('vertices',vert,'faces',face,'EdgeColor','r','FaceColor','none');

    % Scalp Mesh
    %--------------------------------------------------------------------------
    face    = Mscalp.face;
    vert    = Mscalp.vert;
    h_scp   = patch('vertices',vert,'faces',face,'EdgeColor',[1 .7 .55],'FaceColor',[1 .7 .55]); %'none');
    set(h_scp, 'facealpha',.2, 'edgealpha', .2)

    % --- DISPLAY SETUP ---
    %==========================================================================
    Lhsp    = datareg.fid_eeg.pnt;
    Lfidmri = datareg.fid_mri.fid.pnt;
    Lfid    = datareg.fid_eeg.fid.pnt(1:size(Lfidmri, 1), :);
    [Lsens, Llabel]   = spm_eeg_layout3D(datareg.sensors, datareg.modality);

    % headshape locations
    %--------------------------------------------------------------------------
    if ~isempty(Lhsp)
        h_hsp   = plot3(Lhsp(:,1),Lhsp(:,2),Lhsp(:,3),'dk');
        set(h_hsp,'MarkerFaceColor',[0 .6 .6],'MarkerSize',4);
    end

    % Sensors (coreg.)
    %--------------------------------------------------------------------------
    % Remove reference channels -- CREx 2014
    clab = char(Llabel);
    clab = cellstr(clab(:,1));
    ia = find(strcmp(clab,'A')==1);

    h_sens  = plot3(Lsens(ia,1),Lsens(ia,2),Lsens(ia,3),'ro');
    set(h_sens,'MarkerFaceColor','g','MarkerSize', 6);
    
    % Add sensor
    iD = find(strcmp(Llabel,'A228')==1);
    h_A228 = plot3(Lsens(iD,1),Lsens(iD,2), Lsens(iD,3),'ro');
    set(h_A228,'markersize',8,'markerfacecolor','r')

    % EEG fiducials or MEG coils (coreg.)
    %--------------------------------------------------------------------------
    h_fid   = plot3(Lfid(:,1),Lfid(:,2),Lfid(:,3),'o');
    set(h_fid,'MarkerFaceColor','c','MarkerSize',12);

    % MRI fiducials
    %--------------------------------------------------------------------------
    h_fidmr = plot3(Lfidmri(:,1),Lfidmri(:,2),Lfidmri(:,3),'d');
    set(h_fidmr,'MarkerFaceColor','m','MarkerSize',12);

    leg={'Cortex'; 'Skull'; 'Scalp'; 'Headshape'; 'Sensors'; 'A228' ; 'MEG fiducials'; 'MRI fiducials'};
    h = [h_ctx ; h_skl ; h_scp ; h_hsp ; h_sens ; h_A228 ; h_fid ; h_fidmr];


%----
% Define path informations that will be adding to the figure :
% MEG data path and MRI data path
function datapath = def_datapath(opt)

    datapath = cell(2,1);
    if ~isempty(opt.mripath)
        % Reduce string size if too long
        if length(opt.mripath) > 50;
            opt.mripath = [opt.mripath(1:3),'~',opt.mripath(end-50:end)];
        end
        datapath{1}=['MRIpath : ',opt.mripath];

    else
        datapath{1} = 'Default MRI : spm/canonical/single_subj_T1.nii';
    end

    if ~isempty(opt.megpath)
        % Reduce string size if too long
        if length(opt.megpath) > 50;
            opt.megpath = [opt.megpath(1:3),'~',opt.megpath(end-50:end)];
        end
        datapath{2}=['MEGpath : ',opt.megpath];
    else
        datapath{2} = 'Unknown MEG data path';
    end