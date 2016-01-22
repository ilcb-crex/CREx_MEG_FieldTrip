function meg_loc_checkvolgrid(Svol, Sgrid, opt)

%----
% Check for input options

defopt = struct('istemplate',0,'mripath',[], 'megpath',[], 'savpath', pwd);
if nargin < 3 || isempty(opt) || ~isstruct(opt)
    opt = defopt;
else
    fn = fieldnames(defopt);
    for j = 1:length(fn)
        if ~isfield(opt, fn{j})
            opt.(fn{j}) = defopt.(fn{j});
        end
    end
end
            
%----
% Define path informations that will be added to the figure

datapath = def_datapath(opt);


vert = Svol.bnd.pnt;
face = Svol.bnd.tri;
gins = Sgrid.pos(Sgrid.inside,:);
% gout = Sgrid.pos(Sgrid.outside,:);

%----
% A big one that can be check with mouse and rotate3d on (saved in .fig)
figure
set(gcf,'visible','off','units','centimeters','position',[7 5 20 20.8])
set(gca,'position',[ 0.0145 0.0216 0.9313 0.9034])
hold on
h_vol = patch('vertices',vert, 'faces',face);
set(h_vol, 'EdgeColor',[1 .7 .55],'FaceColor',[1 .7 .55],'facealpha',.05, 'edgealpha', .05)
h_gi = plot3(gins(:,1), gins(:,2), gins(:,3),'ok');
set(h_gi,'MarkerFaceColor',[0 .6 .6],'MarkerSize',6);

view(92,26)  % Why not ?
axis tight
axis off
h_leg = legend([h_vol, h_gi],{'Volume' ; 'Grid (inside)'});
set(h_leg,'fontsize',12,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])
set(h_leg,'position',[0.76 0.73 0.16 0.16]); %
hold off

annotation(gcf,'textbox','String', 'Mesh of volume model and dipole grid','interpreter','none',...
        'FontSize',13,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.0013 0.9364 0.9934 0.0581]);

annotation(gcf,'textbox','String', datapath,'interpreter','none',...
    'FontSize',11,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','left',...
    'FitBoxToText','off','Position',[0.0367 0.8575 0.6991 0.0687]);


if opt.istemplate == 1
    addt = '_template_';
else
    addt = '_subj_';
end
% Adding MRI name to the figure file if specified in opt structure
if ~isempty(opt.mripath)
    [T,nam] = fileparts(opt.mripath); %#ok
    addt = [addt,nam,'_'];
end
export_fig([opt.savpath, filesep, 'CheckVolGrid',addt,'3Ddisp_',datestr(now,'yymmdd_HHMM'),'.png'],'-m1.5')
saveas(gcf,[opt.savpath, filesep, 'CheckVolGrid',addt,'3Ddisp_',datestr(now,'yymmdd_HHMM'),'.fig'])
close

%----
% Figure with 3 views

figure
set(gcf,'visible','off','units','centimeters','position',[7 5 20 20.8])

gc = zeros(3,1);

% From the right
gc(1) = subplot(2,2,1);
hold on
h_vol = patch('vertices',vert, 'faces',face);
set(h_vol, 'EdgeColor',[1 .7 .55],'FaceColor',[1 .7 .55],'facealpha',.05, 'edgealpha', .05)
h_gi = plot3(gins(:,1), gins(:,2), gins(:,3),'ok');
set(h_gi,'MarkerFaceColor',[0 .6 .6],'MarkerSize',6);
view(0,0)
xlabel('x (mm)'), zlabel('z (mm)')
set(gca,'fontsize',10)
title('View 1','fontsize',12)
axis tight

% Behind
gc(2) = subplot(2,2,2);
hold on
h_vol = patch('vertices',vert, 'faces',face);
set(h_vol, 'EdgeColor',[1 .7 .55],'FaceColor',[1 .7 .55],'facealpha',.05, 'edgealpha', .05)
h_gi = plot3(gins(:,1), gins(:,2), gins(:,3),'ok');
set(h_gi,'MarkerFaceColor',[0 .6 .6],'MarkerSize',6);
view(90,0)
ylabel('y (mm)'), zlabel('z (mm)')
set(gca,'fontsize',10)
title('View 2','fontsize',12)
axis tight

% Above
gc(3) = subplot(2,2,3);
hold on
h_vol = patch('vertices',vert, 'faces',face);
set(h_vol, 'EdgeColor',[1 .7 .55],'FaceColor',[1 .7 .55],'facealpha',.05, 'edgealpha', .05)
h_gi = plot3(gins(:,1), gins(:,2), gins(:,3),'ok');
set(h_gi,'MarkerFaceColor',[0 .6 .6],'MarkerSize',6);
view(90,90)
xlabel('x (mm)'), ylabel('y (mm)')
set(gca,'fontsize',10)
title('View 3','fontsize',12)
axis tight

subplot(2,2,4)
pos = get(gca,'position');
h_leg = legend([h_vol, h_gi],{'Volume' ; 'Grid (inside)'});
set(h_leg,'fontsize',12,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])
set(h_leg,'position',[pos(1)+pos(3)./4 pos(2)+pos(4)-0.16 0.16 0.16]); 
axis off

% Put the subplot to the bottom
for i = 1:3
    gpos = get(gc(i), 'position');
    set(gc(i), 'position',  [gpos(1) gpos(2)-0.03 gpos(3:4)])
end

annotation(gcf,'textbox','String', 'Mesh of volume model and dipole grid','interpreter','none',...
        'FontSize',14,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.0013 0.9364 0.9934 0.0581]);

annotation(gcf,'textbox','String', datapath,'interpreter','none',...
    'FontSize',8,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','left',...
    'FitBoxToText','off','Position',[0.5042 0.0840 0.4443 0.1314]);

export_fig([opt.savpath, filesep, 'CheckVolGrid',addt,'3subp_',datestr(now,'yymmdd_HHMM'),'.png'],'-m1.5')
close 

%----
% Define path informations that will be added to the figure :
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
        if opt.istemplate==0
            datapath{2} = 'Unknown MEG data path';
        end
    end
