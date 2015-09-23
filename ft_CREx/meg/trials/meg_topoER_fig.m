function meg_topoER_fig(Savgtrial,namcond,fdos,pathavgtrial)

if nargin<2
    namcond='Cond';
end
if nargin<3
    fdos=pwd;
end
if nargin<4
    pathavgtrial='Unknwpath';
end

vect=-.1:.05:.9; % Fixed values to ensure good dimension for subplot
nlig=ceil((length(vect)-1)./5);
if nlig<=4
    H=23;
else
    H=28;
end
namcondf=['[ ',namcond,' ]'];

Savgtrial.dimord='chan_time';
avg=Savgtrial.avg;
time=Savgtrial.time;

% Adjustment of the colormap limits values (zlimcol)
avgmeanwin=zeros(length(avg(:,1)),length(vect)-1);
for w=1:length(vect)-1
    avgmeanwin(:,w)=mean(avg(:,time>=vect(w) & time<=vect(w+1)),2);
end
    
zlimcol=[min(min(avgmeanwin)) max(max(avgmeanwin))];
if zlimcol(1)<0
    zlimcol=[-1.*max(abs(zlimcol)) max(abs(zlimcol))];
end
  
% Check if magnetometer or planar gradient data
% A priori, magnetometer : the average values are positive AND negative,
% whereas for the combined planar gradient : only positive average values
if isfield(Savgtrial,'planar')
    zlab = 'Planar gradient (T m^{-1})';
    datyp = 'ERF (planar grad)';
    savt= 'Planar';
else
    zlab = 'Magnetic field (T)';
    datyp = 'ERF';
    savt= '';
end
figure, set(gcf,'visible','off','units','centimeters','position',[2 2 28 H])
cfg = [];
cfg.parameter = 'avg';
cfg.interactive ='no';
cfg.colorbar='no';
cfg.zlim=zlimcol;
cfg.comment='no'; 
cfg.layout ='4D248.lay';
cfg.colormap=colormap_blue2red;

for s=1:length(vect)-1
    subplot(nlig,5,s)
    cfg.xlim = [vect(s) vect(s+1)];
    ft_topoplotER(cfg,Savgtrial);
    axis tight 
    titfig=['t=[ ',num2str(vect(s).*1e3),'  ',num2str(vect(s+1).*1e3),' ] ms'];
    title(titfig,'fontsize',10,'fontweight','bold')
    pos=get(gca,'position');
    set(gca,'position',[pos(1) pos(2)-.04 pos(3) pos(4)]) 
    pos=get(gca,'position');
    meanval=mean(avg(:,time>=vect(s) & time<=vect(s+1)),2);
    minavg=min(meanval);
    maxavg=max(meanval);
    annotation(gcf,'textbox','String',['val=[',num2str(minavg,2),'  ',num2str(maxavg,2),']' ],...
        'HorizontalAlignment','center','FontSize',8,'FitBoxToText','on',...
        'LineStyle','none','position',[pos(1) pos(2)-.005 pos(3)+.01 .01]);
end
cb=colorbar('location','westoutside');
set(cb,'position',[0.0751 0.0632 0.0174 0.3586],'fontsize',12)
set(get(cb,'ylabel'),'string',zlab,'fontsize',12)
gentit={[namcondf,' - Topographic representation of ',datyp];pathavgtrial};
annotation(gcf,'textbox','String',gentit,'interpreter','none','FontSize',13,...
            'fontname','AvantGarde','fontweight','bold',...
            'LineStyle','none','HorizontalAlignment','center',...
            'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);
        
namcond(namcond=='-')='_';
namcond(namcond=='.')='p';
namcond(namcond==' ')='';
namfig=['Topo',savt,'ERPlot_',namcond];
export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
close

disp(' '),disp('- - - - - -')
disp('Figure saved in :')
disp(fdos)
disp('- - - - - -'),disp(' ')
    