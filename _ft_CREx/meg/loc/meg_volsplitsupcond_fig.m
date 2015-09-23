function meg_volsplitsupcond_fig(sourCell,namcond,Gindex,Gnam,pdir,pmat)
% sourCell : cellule contenant les structures FieldTrip des resultats des
% localisation des sources, pour differentes conditions a superposer

if ~iscell(sourCell)
    sourCell={sourCell};
end

sz=size(namcond);
if sz(1)>1
    namcond=namcond';
end

timec=cell(length(sourCell),1);
for nd=1:length(sourCell)
    timec{nd}=sourCell{nd}.time;
end


% Only keep the source points that are inside the brain...
% and transform the cellule in matrix
z2cell=cell(length(sourCell),1);
for ns=1:length(sourCell)
    z2cell{ns}=cell2mat(sourCell{ns}.avg.z2(sourCell{ns}.inside));
end

mz2c=cell(length(sourCell),1);  
mz2cS=cell(length(sourCell),1); 
    
for i=1:length(Gindex)

    indc=Gindex{i};
    tit=['[ Mean Z2 - Section : ',Gnam{i},' ] - ',pmat];

        
    namcondsav=strjoint(namcond,'_');
    for nd=1:length(sourCell)
        mz2c{nd}=mean(z2cell{nd}(indc,:));
        mz2cS{nd}=smooth(mean(z2cell{nd}(indc,:)),10);
    end
    thelittlefig(timec,mz2c,namcond,tit)
    export_fig([pdir,filesep,'BeamfZ2_sup_',namcondsav,'_',Gnam{i},'.jpg'],'-m1.5')
   	close 

    % Smooth version
%     tit=['[ Mean Z2 (10 span smooth) - Section : ',Gnam{i},' ] - ',pmat];
%     thelittlefig(timec,mz2cS,namcond,tit)
%     export_fig([pdir,filesep,'Smooth_BeamfZ2_sup_',namcondsav,'_',Gnam{i},'.jpg'],'-m1.5')
%     close 

 
end
      
function thelittlefig(xc,yc,legstr,titstr)
    figure, set(gcf,'units','centimeters','position',[10 10 14 6])
    hold on
    col=mycolorsup;
    for p=1:length(xc)
        plot(xc{p},yc{p},'linewidth',1,'color',col(p,:))
    end
    axis tight; axis off;
    set(gca,'position',[.13 .13 .775 .78])
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
    put_leg(legstr,col) 
    
function col=mycolorsup
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
    'LineStyle','none','fontsize',9,'position',[0.1276  -0.0022 0.5 0.1]);        