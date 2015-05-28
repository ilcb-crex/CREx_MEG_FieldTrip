function meg_subjgrid_fig(volcondmodel,subj_grid,segpath,savpath)

if nargin<3
    segpath=[];
end
if nargin<4
    sav=0;
else
    sav=1;
end

% Determine units and convert data in order to display both grid and volume
% in mm
subj_grid = set_units_mm(subj_grid);
volcondmodel = set_units_mm(volcondmodel);
    
figure
set(gcf,'units','centimeters','position',[5 6 20 18])
subplot(221), ft_plot_vol(volcondmodel, 'facecolor',[.15 .15 .15],'edgecolor', 'none'); 
alpha 0.4;  
hold on, p=ft_plot_mesh(subj_grid.pos(subj_grid.inside,:));
set(p,'marker','o','markersize',2,'markeredgecolor','none','markerfacecolor','b')
view(0,0)
axis on; grid on;
title('From the right'), xlabel('x (mm)')
zlabel('z (mm)')

subplot(222), ft_plot_vol(volcondmodel, 'facecolor',[.15 .15 .15],'edgecolor', 'none'); 
alpha 0.4; 
hold on, p=ft_plot_mesh(subj_grid.pos(subj_grid.inside,:));
set(p,'marker','o','markersize',2,'markeredgecolor','none','markerfacecolor','b')
view(90,0)
axis on; grid on;
title('Behind'), ylabel('y (mm)')
zlabel('z (mm)')

subplot(223), ft_plot_vol(volcondmodel, 'facecolor',[.15 .15 .15],'edgecolor', 'none'); 
alpha 0.4;
hold on, p=ft_plot_mesh(subj_grid.pos(subj_grid.inside,:));
set(p,'marker','o','markersize',2,'markeredgecolor','none','markerfacecolor','b')
view(90,90)
axis on; grid on;
title('Above'), ylabel('y (mm)')
xlabel('x (mm)')

for s=1:3
    subplot(2,2,s), posa=get(gca,'position');
    set(gca,'position',[posa(1) posa(2)-0.03 posa(3:4)])
end

titfig = {'Subject conduction model and ajusted template grid - from segmented MRI :';segpath};
annotation(gcf,'textbox','String',titfig,'interpreter','none',...
    'FontSize',12,'fontname','AvantGarde','fontweight','bold',...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);

if sav
    namfig='VolModel_GridTemp';
    export_fig([savpath,filesep,namfig,'.jpeg'],'-m1.5')
    disp(' '), disp('Saved image :')
    disp([savpath,filesep,namfig,'.jpeg'])
    close
end

function Sdata = set_units_mm(Sdata)
if isfield(Sdata,'unit')
    if strcmp(Sdata.unit,'mm') == 0
        try
            Sdata = ft_convert_units(Sdata, 'mm');
        catch
            disp('Unable to convert units in ''mm''')
            disp('Original units will be kept')
        end
    end
else
    disp('No field ''units'' in Sdata structure')
    disp('Units assumes to be ''mm''')
end

% function scalfactor = det_scalefactor_mm(Sdata)
% if isfield(Sdata,'units')
%     switch Sdata.unit
%         case 'mm'
%             scalfactor = 1;
%         case 'cm'
%             scalfactor = 10;
%         case 'm'
%             scalfactor = 1000;
%     end
% else
%     disp('No field ''units'' in Sdata structure')
%     disp('Units assumes to be ''mm''')
%     scalfactor = 1;
% end