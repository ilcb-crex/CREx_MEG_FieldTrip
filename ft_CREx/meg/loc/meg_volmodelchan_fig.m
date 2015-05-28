function meg_volmodelchan_fig(volmodel,Sgrad,segpath,savpath)

if nargin<3
    segpath=[];
end
if nargin<4
    sav=0;
else
    sav=1;
end
clab=char(Sgrad.label);
chanposmm=Sgrad.chanpos.*1000; % passage m en mm
idplot=strfind(clab(:,1)','A');
chanposmm=chanposmm(idplot,:);

figure
set(gcf,'units','centimeters','position',[5 6 20 18])
subplot(221), ft_plot_vol(volmodel), axis on, grid on
hold on, p=plot3(chanposmm(:,1),chanposmm(:,2), chanposmm(:,3),'o');
set(p,'markersize',4,'markerfacecolor','b')
view(0,0)
title('From the right'), xlabel('x (mm)')
zlabel('z (mm)')

subplot(222), ft_plot_vol(volmodel), axis on, grid on
hold on, p=plot3(chanposmm(:,1),chanposmm(:,2), chanposmm(:,3),'o');
set(p,'markersize',4,'markerfacecolor','b')
view(90,0)
title('Behind'), ylabel('y (mm)')
zlabel('z (mm)')

subplot(223), ft_plot_vol(volmodel), axis on, grid on
hold on, p=plot3(chanposmm(:,1),chanposmm(:,2), chanposmm(:,3),'o');
set(p,'markersize',4,'markerfacecolor','b')
view(90,90)
title('Above'), ylabel('y (mm)')
xlabel('x (mm)')

for s=1:3
    subplot(2,2,s), posa=get(gca,'position');
    set(gca,'position',[posa(1) posa(2)-0.03 posa(3:4)])
end

titfig = {'MEG channels & Head model (brain surface) obtained from segmented MRI :';segpath};
annotation(gcf,'textbox','String',titfig,'interpreter','none',...
    'FontSize',12,'fontname','AvantGarde','fontweight','bold',...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);

if sav
    namfig='VolModel_Chanpos';
    export_fig([savpath,filesep,namfig,'.jpeg'],'-m1.5')
    close
end