function meg_loc_hdmYH_M1step_fig(Sdat, savpath)

opengl('OpenGLWobbleTesselatorBug',1)

vview = [-180 0 ; 90 0 ; -180 90];
titview = {'[ View 1 ]'; '[ View 2 ]'; '[ View 3 ]'};

for v = 1:length(vview(:,1))
    figure, set(gcf,'visible','off','units','centimeters', 'position', [3 10 38 10])
    nbstep = length(Sdat.names);
    for n = 1 : nbstep
        subplot(1, nbstep, n)
        allp = disp_all(Sdat.sources{n}, Sdat.target);
        view(vview(v,1),vview(v,2))
        axis tight
        title(Sdat.names{n},'fontsize',13)  
    end

    lg = legend(allp, 'MRI (target)','MEG (source)','MRI-fid','MRI-NZ','MEG-fid');
    set(lg, 'position', [0.002 0.3641 0.0967 0.2593])
    set(lg,'fontsize',10,'color', [.95 .9 .9], 'edgecolor', [.95 .9 .9],'ticklength',[0 0])

    annotation(gcf,'textbox','String', titview{v},'interpreter','none',...
            'FontSize',16,'fontname','AvantGarde',...
            'LineStyle','none','HorizontalAlignment','center',...
            'FitBoxToText','off','Position',[ 0.008 0.8651 0.0825 0.1243])

    annotation(gcf,'textbox','String', 'Displays of M1 calculation steps','interpreter','none',...
        'FontSize',11,'fontname','AvantGarde','fontweight','bold',...
        'LineStyle','none','HorizontalAlignment','left',...
        'FitBoxToText','off','Position',[0.0107 0.6693 0.0818 0.1852])
    
    fignam = ['M1calc_',num2str(nbstep),'step_',datestr(now,'yymmdd_HHMM'),'_view',num2str(v)];
    export_fig(fullfile(savpath,[fignam,'.png']),'-m1.5')

    close
end

function allp = disp_all(Fmeg, Fmri)
hold on

% Fmri (target) surface

pt = patch('vertices', Fmri.pnt, 'faces', Fmri.tri);
set(pt,'facecolor',[.2 .9 .2],'facealpha',.5, 'edgecolor', 'none') %'edgealpha',.5 % Maybe the guilty of crash problem

% Avoid OpenGL error causing Matlab crash
Smri = reducepatch(Fmri.tri, Fmri.pnt, 0.2); % We only keep 20% of original faces 
patch(Smri, 'facecolor', 'none', 'edgecolor', [.2 .8 .2], 'edgealpha', .5);

% Headshape (MEG source)
ps = plot3(Fmeg.pnt(:,1), Fmeg.pnt(:,2), Fmeg.pnt(:,3),'kd');
set(ps,'markerfacecolor',[.85 0 0],'markersize',5)

% Add fiducials

% MRI - Highlight Nasion by adding * marker
ptf = plot3(Fmri.fid.pnt(:,1), Fmri.fid.pnt(:,2), Fmri.fid.pnt(:,3),'d');
set(ptf,'markerfacecolor',[0 .4 .9],'markersize',12)
ptfn = plot3(Fmri.fid.pnt(1,1), Fmri.fid.pnt(1,2), Fmri.fid.pnt(1,3),'m*');
set(ptfn,'markersize',14)

% MEG
psf = plot3(Fmeg.fid.pnt(:,1), Fmeg.fid.pnt(:,2), Fmeg.fid.pnt(:,3),'o');
set(psf,'markerfacecolor',[.9 .75 0],'markersize',12)

set(gca,'fontsize',8)
xlabel('x (mm)'), ylabel('y (mm)'), zlabel('z (mm)')

allp = [ pt ; ps ; ptf ; ptfn ; psf ];