function meg_loc_map_frame_cbf(sourC,mri,fnam,fdos,pSmat)
% sourC : le resultat de ft_sourceanalysis
% mri : la structure FieldTrip de l'image IRM a utilise pour l'affichage 
% latwin : les fenetres d'interet (autant de ligne que de fenetres, et 2
% colonnes : latwin(:,1) : borne inferieure de la fenetre en seconde
% et latwin(:,2) : borne superieure
% Ex. : latwin = [.1 .3 ; .3 .6] : deux fenetres seront considerees pour les cartes de
% localisation : 100-300 ms et 300-600 ms
% fnam : nom de la condition (defaut : 'Cond')
% fdos : nom du dossier ou sauver les figures (defaut : pwd)
% pnamSmat : chemin complet de la matrice contenant les sources issues de la modelisation
% (defaut : 'unkwnSourceData') - permet d'avoir indirectement le nom du
% dossier Sujet et du Run sur la figure

if nargin<3
    fnam='Cond';
end
if nargin<4
    fdos=pwd;
end
if nargin<5
    pSmat=[fdos,'unkwnSourcData']; 
end

iwin=-.08:.01:.8;  % to add to the sourC structure
lgw=.02; 

% Partie du titre des figures
fnamt=fnam;
fnamt(fnamt=='_')='-';
% Partie du noms pour sauver les matrices
fnamf=fnam;
fnamf(fnam=='-')='_';
fnamf(fnam=='.')='p';
grey=[.6 .6 .6]; 

timec=[];
avgs=[];
for nw=1:length(sourC.time)
    timec=[timec,sourC.time{nw}]; %#ok
    p=sourC.avg.pow{nw};
    avgs=[avgs;repmat(mean(p(isnan(p)==0)),length(sourC.time{nw}),1)]; %#ok
end
[time,ia]=unique(timec);
avgmean=smooth(avgs(ia));

% Calculus of all 'avg.pow' values to determine the range of the colorbar
cmat=cell2mat(sourC.avg.pow);
cmatok=cmat(isnan(cmat)==0);
minmax=[min(cmatok) max(cmatok)-(max(cmatok)-mean(cmatok))./2];

[namsav,msi,msf]=deal(cell(length(iwin),1));
a=1;
for s=1:length(iwin)
    if iwin(s)+lgw<time(end)
        msi{a}=num2str(iwin(s).*1e3);
        msf{a}=num2str((iwin(s)+lgw).*1e3);
        if ~isempty(strfind(msi{a},'e'))
            msi{a}=num2str(round(iwin(s)).*1e3);
        end
        if ~isempty(strfind(msf{a},'e'))
            msf{a}=num2str(round(iwin(s)+lgw).*1e3);
        end            
        if a<10
            numfram=['0',num2str(a)];
        else
            numfram=num2str(a);
        end
        namsav{a}=name_save(['_CBFLocFrame_',fnamf,'_',numfram,'_',msi{a},'_to_',msf{a},'_ms']);
        a=a+1;
    end
end

if a-1<length(iwin)
    namsav=namsav(1:a-1);
    msi=msi(1:a-1);
    msf=msf(1:a-1);
    iwin=iwin(1:a-1);
end

sourCwin=sourC;
for nw=1:length(iwin)  % Pour chaque fenetre d'interet
    sourCwin.time=sourC.time{nw};
    sourCwin.avg.pow=sourC.avg.pow{nw};
    %______
    % Source interpolation 
    cfg = [];
    cfg.downsample = 2;
    cfg.interpmethod ='cubic';
    cfg.parameter = 'avg.pow'; % Le champs scalaire sourC.avg.m est utilise
    sourcInt = ft_sourceinterpolate(cfg,sourCwin,mri);

    %______
    % Map of localisation with slice representation
    cfg = [];
    cfg.method = 'slice';
    cfg.location = 'max';
    cfg.funparameter = 'pow';

    cfg.slicerange=[55 96];
    coltyp={'RelColMap','TopoRelCol','FixColMap','TopoFixCol'};
    colparam={'zeromax';'zeromax';minmax;minmax};
    for nf=1:length(coltyp)
        cfg.funcolorlim = colparam{nf};
        ft_sourceplot(cfg,sourcInt);
        if nf==2 || nf==4
            colormap_topo;
        end
        titlefig = {['[ ',fnamt,' ]',' - Source localisation using classical beamforming'];...
                pSmat;['t = [',msi{nw},' ',msf{nw},'] ms']};

        set(gcf,'units','centimeters','position',[10 2 21 26],'color',[0 0 0])
        set(gca,'units','centimeters','position',[0.4 8 18 18.5]) 

        colb=findobj(gcf,'tag','Colorbar');
        set(colb,'ycolor',[1 1 1],'position',[0.8967 0.4252 0.0160 0.5057])
        set(get(colb,'ylabel'),'String','Normalized value',...
            'Color',[1 1 1],'fontsize',12)

        sub=axes('Parent',gcf,'Position',[0.0705 0.08 0.8175 0.27]);  %#ok
        plot(time,avgmean,'color',[.8 .8 .8],'linewidth',1.5);
        hold on, plot(time(time>=iwin(nw) & time<=iwin(nw)+lgw),...
            avgmean(time>=iwin(nw) & time<=iwin(nw)+lgw),'r','linewidth',3)
        set(sub,'linewidth',1.2,'box','off','color',[0 0 0],'xcolor',grey,'ycolor',grey);
        xl=[-.5 1];
        xlim(xl)
        set(sub,'xtick',xl(1):.2:xl(end))
        xlabel('Time (s)','color',grey,'fontsize',13)
        ylabel('Mean parameter value','color',grey,'fontsize',13)
        set(gca,'fontsize',12)
        title('Mean pattern of ''avg.pow'' source parameter value','color',grey,'fontsize',13)
        annotation(gcf,'textbox','String',titlefig,'interpreter','none',...
                'FontSize',13,'fontname','AvantGarde',...
                'color',[1 1 1],...
                'LineStyle','none','HorizontalAlignment','center',...
                'FitBoxToText','off','Position',[0.05 0.9116 0.9 0.0859]);


        export_fig([fdos,filesep,coltyp{nf},namsav{nw},'.jpeg'],'-m1.5','-nocrop') 
        close

    end
end
end



