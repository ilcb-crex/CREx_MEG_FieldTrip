function meg_topoER_frame(Savgtrial,namcond,fdos,matpath)

if nargin<2
    namcond='Cond';
end
if nargin<3
    fdos=pwd;
end
if nargin<4
    matpath='Unknwpath';
    matnam=[];
else
    [matpath,matnam,ext]=fileparts(matpath);
    matnam=[matnam,ext];
end

iwin = -.2:.01:.8; %-.1:.03:.9;
lgw = .02; %.05
namcondf=['[ ',namcond,' ]'];

  
% Check if magnetometer or planar gradient data
% A priori, magnetometer : the average values are positive AND negative,
% whereas for the combined planar gradient : only positive average values
if isfield(Savgtrial,'planar')
    ylab = 'Planar gradient (T m^{-1})';
    ylab2 = 'Sqr planar gradient (T^2 m^{-2})';
    zu = 'T m^{-1}';
    datyp = 'ERF (planar grad)';
  %  savt= 'Planar';
else
    ylab = 'Magnetic field (T)';
    ylab2 = 'Sqr magnetic field (T^2)';
    zu = 'T';
    datyp = 'ERF';
   % savt= '';
end

Savgtrial.dimord='chan_time';
avg=Savgtrial.avg;
time=Savgtrial.time;
avgmeanwin=zeros(length(avg(:,1)),length(iwin));
msi = cell(length(iwin),1);
msf = cell(length(iwin),1);
namsav=cell(length(iwin),1);
for w=1:length(iwin)
    avgmeanwin(:,w)=mean(avg(:,time>=iwin(w) & time<=iwin(w)+lgw),2);
    [msi{w}, msf{w}] = win_ms(iwin(w), lgw);
    if w < 10
        numfram=['0',num2str(w)];
    else
        numfram=num2str(w);
    end
    namsav{w}=name_save(['TopoERFrame_',namcond,'_',numfram,'_',msi{w},'_to_',msf{w},'ms']);
end

    
zlimcol=[min(min(avgmeanwin)) max(max(avgmeanwin))];
if zlimcol(1)<0
    zlimcol=[-1.*max(abs(zlimcol)) max(abs(zlimcol))];
end
    
figure, set(gcf,'visible','off','units','centimeters','position',[16 8 15.7 17.5])
cfg = [];
cfg.parameter = 'avg';
cfg.interactive ='no';
cfg.colorbar='no';
cfg.zlim=zlimcol;
cfg.comment='no'; 
cfg.layout ='4D248.lay';
cfg.colormap=colormap_blue2red;
grey=[.6 .6 .6];
for s = 1 : length(iwin)
    if iwin(s)+lgw < time(end)
        indw = find(time>=iwin(s) & time<=iwin(s)+lgw);
        if s==1
            subplot(312)
            pos=get(gca,'position');
            set(gca,'position',[pos(1) pos(2)-.08 pos(3:4)]);
            p1=gca;
            
            plot(time,Savgtrial.avg,'color',[0 0 .8])
            axis tight; box off;
            set(gca,'ycolor',grey,'xcolor','w')
            ylabel(ylab,'color',grey)
            title('All channels','fontsize',12,'color',grey)
            hold on
            c1=plot(time(indw),Savgtrial.avg(:,indw),'color','r','parent',p1);
            
            subplot(313), plot(time,mean(Savgtrial.avg.^2),'color',[.3 .3 .3])
            pos=get(gca,'position');
            set(gca,'position',[pos(1) pos(2)-.05 pos(3:4)]);
            p2=gca;
            axis tight; box off;
            set(gca,'ycolor',grey,'xcolor',grey)
            ylabel(ylab2,'color',grey)
            xlabel('Time (s)','color',grey)
            title('Mean square','fontsize',12,'color',grey)
            hold on
            c2 = plot(time(indw),mean(Savgtrial.avg(:,indw).^2),'r','linewidth',3,'parent',p2);
        else
            delete([c1;c2])
            c1 = plot(time(indw),Savgtrial.avg(:,indw),'color','r','parent',p1);
            c2 = plot(time(indw),mean(Savgtrial.avg(:,indw).^2),'r',...
                'linewidth',2,'parent',p2);
        end
        subplot(311)
        cfg.xlim = [iwin(s) iwin(s)+lgw];
        ft_topoplotER(cfg,Savgtrial);
        axis tight
        
        titfig=['t=[ ',msi{s},'  ',msf{s},' ] ms'];
        title(titfig,'fontsize',10,'fontweight','bold')
        pos=get(gca,'position');
        set(gca,'position',[pos(1)-.025 pos(2)-.1 pos(3)+.05 pos(4)+.05]) %.08

        cb=colorbar('location','eastoutside');
        set(cb,'position',[0.8507 0.6269 0.0118 0.2659])
        set(get(cb,'title'),'string',zu,'fontsize',10)
        gentit={[namcondf,' - Topographic representation of ',datyp,' : ',matnam];matpath};
        annotation(gcf,'textbox','String',gentit,'interpreter','none','FontSize',9,...
                    'fontname','AvantGarde',...
                    'LineStyle','none','HorizontalAlignment','center',...
                    'FitBoxToText','off','Position',[0.05 .94 0.9 0.058]);

       % pause(0.01)
        
        export_fig([fdos,filesep,namsav{s},'.jpeg'],'-m1.5')
    end
end

close

%--- String names of time intervals
function [msi, msf] = win_ms(startw, lgw)
    msi = num2str(startw.*1e3);
    msf = num2str((startw+lgw).*1e3);
    if ~isempty(strfind(msi,'e'))
        msi = num2str(round(startw).*1e3);
    end
    if ~isempty(strfind(msf,'e'))
        msf = num2str(round(startw+lgw).*1e3);
    end  