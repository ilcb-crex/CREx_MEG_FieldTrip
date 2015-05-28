function meg_volsplit_fig(sourC,Gindex,Gnam,pdir,pnam)

for i=1:length(Gindex)

    indc=Gindex{i};
    % Only keep the source points that are inside the brain
    % and transform the cellule in matrix
    z2=cell2mat(sourC.avg.z2(sourC.inside));
    
    tit=['[ Mean Z2 - Section : ',Gnam{i},' ] - ',pnam];
    thelittlefig(sourC.time,mean(z2(indc,:)),[0 0 .8],tit)
    export_fig([pdir,filesep,'BeamfZ2_',Gnam{i},'.jpg'],'-m1.5')%dos
    close 
    
    % Smooth version
%     tit=['[ Mean Z2 (10 span smooth) - Section : ',Gnam{i},' ] - ',pnam];
%     thelittlefig(sourC.time,smooth(mean(z2(indc,:)),10),[0 0 .8],tit)
%     export_fig([pdir,filesep,'Smooth_BeamfZ2_',Gnam{i},'.jpg'],'-m1.5')%dos
%     close 
end
      
function thelittlefig(x,y,col,titstr)
    figure, set(gcf,'units','centimeters','position',[10 10 17 8])
    plot(x,y,'linewidth',1,'color',col)
    axis tight; axis off;
    xl=xlim;
    yl=ylim;
    line(xl,[0 0],'color',[.8 .8 .8],'linewidth',1);
    line([0 0],yl,'color',[.8 .8 .8],'linewidth',1);
    vgrid=-10:.2:xl(2);
    vgrid=vgrid(vgrid>xl(1));
    vgrid=repmat(vgrid,2,1);
    line(vgrid,repmat(yl,length(vgrid),1)','color',[.7 .7 .7],'linestyle',':')
    for v=1:length(vgrid(1,:))
        text(vgrid(1,v)-.01,yl(1)-diff(yl)./30,num2str(vgrid(1,v)*1e3,'%3.0f'),'fontsize',10,'color',[.3 .3 .3],...
            'fontweight','bold')
    end
  
    ylab=['\Deltay = ',num2str(yl(2)-yl(1),'%2.1f')];
    annotation(gcf,'textarrow',[0.0992 0.0992],[0.6011 0.6011],'String',ylab,'FontSize',12,...
        'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'color',[.5 .5 .5]);
    annotation(gcf,'textbox','String',titstr,'interpreter','none','FontSize',8,...
        'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','right',...
        'FitBoxToText','off','Position',[0.12 .88 0.79 0.12]);