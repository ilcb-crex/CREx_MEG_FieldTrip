function meg_loc_compare_volmodel(vol_1, vol_2, opt)
% Display the superimposition of two volume models (mesh of skull)
%
% Inputs :
%   vol_1 and vol_2 : the two fieldtrip structures of volume to superimpose
%   opt : optional structure containing these informations :
%       opt.volname_1 : name of the first volume (will be specified on the
%                       figure) [default : 'Volume-1']
%       opt.volname_2 : name of the second volume (will be specified on the
%                       figure) [default : 'Volume-2']
%       opt.savpath : direction path for saving the figures [default : pwd]
%       opt.bkgcolor : background color : 'w' (white) or 'k' (black -
%       default)
%___CREx 140828


%----
% Check for inputs

% Volumes
if nargin <= 1
    disp('Hum... Not enough input arguments')
    disp('This function requires 2 volume models')
    disp('as the first two arguments in order to')
    disp('display the superimpmosition... ')
    return;
end
if ~isfield(vol_1,'bnd')
    disp('Volume structure (first arg) not valid')
    disp('Must contain the field "bnd"')
    return;
end
if ~isfield(vol_2,'bnd')
    disp('Volume structure (first arg) not valid')
    disp('Must contain the field "bnd"')
    return;
end

% Options
defopt = struct('volname_1','Volume-1','volname_2','Volume-2','savpath',pwd,'bkgcolor','k');
if nargin < 3
    opt = defopt;
else
    fn = fieldnames(defopt);
    for n = 1:length(fn)
        if ~isfield(opt,fn{n}) || isempty(opt.(fn{n})) || ~ischar(opt.(fn{n}))
            opt.(fn{n}) = defopt.(fn{n});
        end
    end
end

%----
% Display superimpositions

% Define some stuffs...

% - Legend names
legnam = {opt.volname_1 ; opt.volname_2};

% - A part of figure file name
vn_1 = opt.volname_1; 
vn_2 = opt.volname_2;

% Crop name of figure file if too long
nc = 22;
if length(vn_1) > nc
    vn_1 = vn_1(1:nc);
end
if length(vn_2) > nc
    vn_2 = vn_2(1:nc);
end
savnam = name_save([vn_1,'_vs_',vn_2]);

% - Title color regarding to background one

if opt.bkgcolor == 'k'
    bkk = true;
    coltit = 'w';
else
    bkk = false;
    coltit = 'k';
end

%---- GO ! ----

%---- 1
% A big one that can be check with mouse and rotate3d on (saved in .fig)

figure
set(gcf,'units','centimeters','position',[7 5 20 20.8])
set(gca,'position',[ 0.0145 0.0216 0.9313 0.9034])
hold on

p1 = patch('vertices', vol_1.bnd.pnt, 'faces', vol_1.bnd.tri);
set(p1,'edgecolor',[.2 .8 .2],'facecolor',[.2 .9 .2],'edgealpha',.5,'facealpha',.5)
p2 = patch('vertices', vol_2.bnd.pnt, 'faces', vol_2.bnd.tri);
set(p2,'edgecolor',[.8 .2 .2],'facecolor',[.9 .2 .2],'edgealpha',.5,'facealpha',.5)

axis tight
axis off
h_leg = legend([p1, p2], legnam);
set(h_leg,'interpreter','none');
set(h_leg,'fontsize',12,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])
set(h_leg,'position',[0.76 0.73 0.16 0.16]); %
hold off

if bkk
	set(gcf,'color','k')
    set(gca,'color','k')
end

annotation(gcf,'textbox','String', 'Volume model meshs comparison','interpreter','none',...
        'FontSize',16,'fontname','AvantGarde','color',coltit,...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.0013 0.9364 0.9934 0.0581]);

export_fig([opt.savpath, filesep, 'Superimp2Vol_',savnam,'_3Ddisp.jpeg'],'-m1.5')
saveas(gcf,[opt.savpath, filesep, 'Superimp2Vol_',savnam,'_3Ddisp.fig'])
close

%---- 2
% Figure with 3 views

figure
set(gcf,'units','centimeters','position',[7 5 20 20.8])

gc = zeros(3,1);

% From the right
gc(1) = subplot(2,2,1);
hold on
p1 = patch('vertices', vol_1.bnd.pnt, 'faces', vol_1.bnd.tri);
set(p1,'edgecolor',[.2 .8 .2],'facecolor',[.2 .9 .2],'edgealpha',.5,'facealpha',.5)
p2 = patch('vertices', vol_2.bnd.pnt, 'faces', vol_2.bnd.tri);
set(p2,'edgecolor',[.8 .2 .2],'facecolor',[.9 .2 .2],'edgealpha',.5,'facealpha',.5)
view(0,0)
xlabel('x (mm)'), zlabel('z (mm)')
set(gca,'fontsize',10)
title('View 1','fontsize',12, 'color', coltit)
axis tight

% Behind
gc(2) = subplot(2,2,2);
hold on
p1 = patch('vertices', vol_1.bnd.pnt, 'faces', vol_1.bnd.tri);
set(p1,'edgecolor',[.2 .8 .2],'facecolor',[.2 .9 .2],'edgealpha',.5,'facealpha',.5)
p2 = patch('vertices', vol_2.bnd.pnt, 'faces', vol_2.bnd.tri);
set(p2,'edgecolor',[.8 .2 .2],'facecolor',[.9 .2 .2],'edgealpha',.5,'facealpha',.5)
view(90,0)
ylabel('y (mm)'), zlabel('z (mm)')
set(gca,'fontsize',10)
title('View 2','fontsize',12, 'color', coltit)
axis tight

% Above
gc(3) = subplot(2,2,3);
hold on
p1 = patch('vertices', vol_1.bnd.pnt, 'faces', vol_1.bnd.tri);
set(p1,'edgecolor',[.2 .8 .2],'facecolor',[.2 .9 .2],'edgealpha',.5,'facealpha',.5)
p2 = patch('vertices', vol_2.bnd.pnt, 'faces', vol_2.bnd.tri);
set(p2,'edgecolor',[.8 .2 .2],'facecolor',[.9 .2 .2],'edgealpha',.5,'facealpha',.5)
view(90,90)
xlabel('x (mm)'), ylabel('y (mm)')
set(gca,'fontsize',10)
title('View 3','fontsize',12, 'color', coltit)
axis tight

subplot(2,2,4)
pos = get(gca,'position');
h_leg = legend([p1, p2], legnam);
set(h_leg,'interpreter','none');
set(h_leg,'fontsize',12,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])
set(h_leg,'position',[pos(1)+pos(3)./4 pos(2)+pos(4)-0.16 0.16 0.16]); 
axis off

% Put the subplot to the bottom
for i = 1:3
    gpos = get(gc(i), 'position');
    set(gc(i), 'position',  [gpos(1) gpos(2)-0.03 gpos(3:4)])
    if bkk
        if i==1
            set(gcf,'color','k')
        end
        set(gc(i),'color','k','xcolor','w','ycolor','w','zcolor','w')
    end
end

annotation(gcf,'textbox','String', 'Volume model meshs comparison','interpreter','none',...
        'FontSize',16,'fontname','AvantGarde','color',coltit,...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.0013 0.9364 0.9934 0.0581]);

export_fig([opt.savpath, filesep, 'Superimp2Vol_',savnam,'_3subp.jpeg'],'-m1.5')
close 
