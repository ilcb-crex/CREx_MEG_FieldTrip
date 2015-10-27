function meg_chansplit_fig(Savg,Gindex,Gnam,pdir,pavgmat)

for i=1:length(Gindex)
    dos=make_dir([pdir,filesep,Gnam{i}]);
    indc=Gindex{i};
    for c=1:length(indc)
        tit=['[ ',Gnam{i},' : ',Savg.label{indc(c)},' ] - ',pavgmat];
        thelittlefig(Savg.time,smooth(Savg.avg(indc(c),:),10),[0 0 .8],tit)
        export_fig([dos,filesep,'ERF_',Gnam{i},'_',Savg.label{indc(c)},'.jpg'],'-m1.5')
        close 
    end
    tit=['[ ',Gnam{i},' : Mean of ',num2str(length(indc)),' channels ] - ',pavgmat];
    thelittlefig(Savg.time,smooth(mean(Savg.avg(indc,:)),10),[.8 0 .8],tit)
    export_fig([dos,filesep,'ERF_',Gnam{i},'_Mean.jpg'],'-m1.5')
    close    
end
      
function thelittlefig(x,y,col,titstr)
    figure, set(gcf,'units','centimeters','position',[10 10 14 6])
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
        text(vgrid(1,v)+.01,yl(1),num2str(vgrid(1,v)*1e3,'%3.0f'),'fontsize',8,'color',[.3 .3 .3],...
            'fontweight','bold')
    end
    ylab=['\Deltay = ',num2str(yl(2)-yl(1),'%2.1e')];
    annotation(gcf,'textarrow',[0.0992 0.0992],[0.7203 0.7203],'String',ylab,'FontSize',8,...
        'HeadStyle','none','LineStyle', 'none', 'TextRotation',90,'color',[.5 .5 .5]);
    annotation(gcf,'textbox','String',titstr,'interpreter','none','FontSize',8,...
        'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','right',...
        'FitBoxToText','off','Position',[0.12 .88 0.79 0.12]);