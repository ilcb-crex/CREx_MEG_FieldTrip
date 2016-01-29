function meg_chansplitsupcond_fig(Savgcell,namcond,Gindex,Gnam,pdir,pavgmat)

if ~iscell(Savgcell)
    Savgcell={Savgcell};
end

sz=size(namcond);
if sz(1)>1
    namcond=namcond';
end

timec=cell(length(Savgcell),1);
for nd=1:length(Savgcell)
    timec{nd}=Savgcell{nd}.time;
end
avgc=cell(length(Savgcell),1);
for i=1:length(Gindex)
    dos=make_dir([pdir,filesep,Gnam{i}]);
    indc=Gindex{i};
    for c=1:length(indc)
        tit=['[ ',Gnam{i},' : ',Savgcell{1}.label{indc(c)},' ] - ',pavgmat];
        namcondsav=strjoint(namcond,'_');
        for nd=1:length(Savgcell) %%%%%%%%%%%%%%%%%%%
            avgc{nd}=Savgcell{nd}.avg(indc(c),:); %smooth(Savgcell{nd}.avg(indc(c),:),10);
        end
        thelittlefig(timec,avgc,namcond,tit)
        export_fig([dos,filesep,'ERF_sup_',namcondsav,'_',Gnam{i},'_',Savgcell{1}.label{indc(c)},'.jpg'],'-m1.5')
        close 
    end
    tit=['[ ',Gnam{i},' : Mean of ',num2str(length(indc)),' channels ] - ',pavgmat];
    for nd=1:length(Savgcell) %%%%%%%%%%%%%%%%%%%%%%%%
        avgc{nd}= mean(Savgcell{nd}.avg(indc,:)); %smooth(mean(Savgcell{nd}.avg(indc,:)),10);
    end
    thelittlefig(timec,avgc,namcond,tit)
    export_fig([dos,filesep,'ERF_sup_',namcondsav,'_',Gnam{i},'_Mean.jpg'],'-m1.5')
    close    
end
      
function thelittlefig(xc,yc,legstr,titstr)
    figure, set(gcf,'units','centimeters','position',[10 10 14 6])
    hold on
    col=mycolorsup;
    for p=1:length(xc)
        plot(xc{p},yc{p},'linewidth',.8,'color',col(p,:))  %%%%%
    end
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
    put_leg(legstr,col) 
    
function col = mycolorsup
    col=[ 0.0431    0.5176    0.7804
          0.8471    0.1608         0
           0    0.6000    0.4000
           0.8706    0.4902         0
            0    0.7490    0.7490];
               
function put_leg(legcell,col)
lig='^{\_\_ }'; 
for s=1:length(legcell)
    legcell{s}(legcell{s}=='_')='-';
    if s==1
        strtext=['\color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s}];
    else
        strtext=[strtext,'  \color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s}]; %#ok
    end
end
annotation(gcf,'textbox','String',strtext,...
    'LineStyle','none','fontsize',9,'position',[0.1276  -0.0022 0.83 0.1]);        