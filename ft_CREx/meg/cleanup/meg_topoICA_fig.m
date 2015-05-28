function meg_topoICA_fig(comp_MEGdata,specopt)
%
% MEG_TOPOICA_FIG
%
% Generation des figures de topographies associees au composantes ICA
%
% Deux types de figures sont mises en forme :
% [1] les cartes topographiques seules, avec plusieurs topo representees 
%     par figure
% [2] les cartes topographiques avec les signaux temporels associes
%     5 composantes sont affichees par figure, avec le signal temporel 
%     a droite de chaque topo. Le signal temporel est montre sur toute sa 
%     duree, puis dans une fenetre de temps reduite.
%
% En entree de la fonction :
%
% - comp_MEGdata : la structure Fieldtrip telle que retournee par 
%                ft_componentanalysis, contenant les composantes ICA
%
% - Options possibles si renseignees dans la structure specopt:
%
%   specopt.pathcompmat : le chemin d'acces a la matrice de donnees 
%               contenant la variable comp_MEGdata. Ce chemin est affiche  
%               dans le titre de chaque figure, ce qui permet de connaitre 
%               indirectement le sujet et run dont il est question
%        Ex.: 'F:\MEG_TheProject\Data\S07\Run_3\...
%                        ICAcomp_preprocData_fcHP_0p5Hz.mat'
%        Defaut si champ pathcompmat absent : pwd
%
%   specopt.pathsavfig : le chemin du dossier ou les figure sont a 
%               enregistrer 
%        Ex. : 'F:\MEG_TheProject\Data\S07\Run_3\ICA_Plots'
%        Defaut si champ pathsavfig absent : pwd
%
%   specopt.nbtopoplot : option d'affichage pour les figures de type [1],
%               nombre de cartes topographiques a afficher par figure
%        Defaut : 20. Pour 248 composantes par exemple, 248/20 = 13
%        figures seront ainsi generees et enreigistrees.
%
%   specopt.xlimzoom : option d'affichage pour les figures de type [2],
%               fenetre temporelle pour l'agrandissement effectue sur 
%               le signal temporel
%        Defaut : [0 10]. Apres avoir enregistrer la figure avec le signal
%        temporel dans sa totalite (ex. : 600 s), un zoom est effectue
%        entre 0 et 10 s. Ceci permet de voir plus en detail la forme des
%        signaux associes a la composante ICA.
%        Par souci de lisibilite, les figures [2] representent 5
%        composantes par figure. Pour 248 composantes par exemple, 50 
%        figures avec le signal temporel complet seront enregistrees + 50 
%        figures avec la fenetre reduite de 10 s pour le signal temporel.
%        Pour desactiver cet affichage "zoom", specifier specopt.xlimzoom 
%        = 'no' ou [];
%
%
% Fonctions specifiques utilisees :
% Fieldtrip : ft_topoplotIC pour representer les cartes de topographie.
% CREx_Toolbox et export_fig.m
% Toolbox Fieldtrip fieldtrip_20130825
%_________________________
% CREx 28/10/2013



%_____
% Input check-in

% Path of the Fieldtrip ICA component matrix
if nargin==2 && isfield(specopt,'pathcompmat')
    pmat=specopt.pathcompmat;
else
    pmat=pwd; % Default
end
% Path of the directory where figures will be saved
if nargin==2 && isfield(specopt,'pathsavfig')
    fdos=specopt.pathsavfig;
else
    fdos=pwd; % Default
end
% Number of topographic plot per figure (for topographics plot only figures)
if nargin==2 && isfield(specopt,'nbtopoplot')
    nbp=specopt.nbtopoplot;
else
    nbp=20;
end
% Zoom applied to temporal signal of ICA component for topo+temporal plots
if nargin==2 && isfield(specopt,'xlimzoom')
    if isempty(specopt.xlimzoom) || (ischar(specopt.xlimzoom))
        zoom=0;
    else
        if length(specopt.xlimzoom)==1
            xlimzoom = [specopt.xlimzoom specopt.xlimzoom+10];
            zoom=1;
        elseif length(specopt.xlimzoom)==2
            xlimzoom=specopt.xlimzoom;
            zoom=1;
        else
            zoom = 0;
        end
    end
else
    xlimzoom=[0 10]; % Default 
    zoom=1;
end
 

% Topographic plots (20 components per figure)
% Nombre de topo
% % lgc=length(comp_MEGdata.label);
% % vviz=1:nbp:lgc;
% % 
% % for nf=1:length(vviz)
% %     figure
% %     iend=vviz(nf)+(nbp-1);
% %     if iend>lgc
% %         iend=lgc;
% %     end
% %     cfg=[];
% %     cfg.component = vviz(nf):iend;
% %     cfg.layout    = '4D248.lay';
% %     cfg.comment   = 'no';
% %     ft_topoplotIC(cfg,comp_MEGdata);
% %     set(gcf,'visible','off','units','centimeters')
% %     set(gcf,'position',[7 3 27 25])
% %     tit={['ICA from RUNICA calculation - Topographic plot [',num2str(nf),']']
% %         ['datapath = ',pmat]};
% %     annotation(gcf,'textbox','String',tit,'interpreter','none',...
% %         'FontSize',13,'fontname','AvantGarde',...
% %         'LineStyle','none','HorizontalAlignment','center',...
% %         'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);
% %     nfs=num2str(nf);
% %     if length(nfs)==1
% %         nfss=['0',nfs];
% %     else
% %         nfss=nfs;
% %     end
% %     namfig=['TopoPlot_',nfss,'_comp_',num2str(vviz(nf)),'_to_',num2str(iend)];
% %     export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
% %     close
% % end
    
% Topographic + temporal (5 components per figure)
lgc = length(comp_MEGdata.label);
nbp = 5; % Une figure par 5 composantes
vfig = 1:nbp:lgc;
for nf = 1:length(vfig) 
    nfs=num2str(nf);
    if length(nfs)==1
        nfss=['0',nfs];
    else
        nfss=nfs;
    end
    figure 
    set(gcf,'visible','off','units','centimeters','position',[7 3 34 25])
    for ns=1:nbp
        numcomp = vfig(nf)+ns-1;
        if numcomp <= lgc
            cfg=[];
            cfg.component = numcomp;
            cfg.layout    = '4D248.lay';
            cfg.comment   = 'no'; 
            % Proportion du subplot : 1 colonne pour topo et 3 colonnes pour donnees temporelles
            subplot(nbp,4,(ns-1)*4+1)
            ft_topoplotIC(cfg,comp_MEGdata);
            pos=get(gca,'position');
            set(gca,'position',[.05 pos(2:4)])
            subplot(nbp,4,(ns-1)*4+2:(ns-1)*4+4)
            plot(comp_MEGdata.time{1},comp_MEGdata.trial{1}(numcomp,:))
            pos=get(gca,'position');
            set(gca,'position',[pos(1)-0.08 pos(2) pos(3)+0.1 pos(4)])
            xlim([0 comp_MEGdata.time{1}(end)])
            ylabel('Magnetic field (T)','fontsize',12)
            xlabel('Time (s)','fontsize',12)
            set(gca,'fontsize',12)
        end
    end
    if numcomp >= lgc
        iend=lgc;
    else
        iend=numcomp;
    end
    tit={['ICA from RUNICA calculation - Components plot [',num2str(nf),']']
        ['datapath = ',pmat]};
    annotation(gcf,'textbox','String',tit,'interpreter','none',...
        'FontSize',13,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);

    namfig=['CompoPlot_',nfss,'_comp_',num2str(vfig(nf)),'_to_',num2str(iend)];
    export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
    
    if zoom
        vzoom=xlimzoom;
        for ns=1:nbp
            numcomp = vfig(nf)+ns-1;
            if numcomp <= lgc
                subplot(nbp,4,(ns-1)*4+2:(ns-1)*4+4)
                plot(comp_MEGdata.time{1},comp_MEGdata.trial{1}(numcomp,:))
                pos=get(gca,'position');
                set(gca,'position',[pos(1)-0.08 pos(2) pos(3)+0.1 pos(4)])
                xlim(vzoom)
                ylabel('Magnetic field (T)','fontsize',12)
                xlabel('Time (s)','fontsize',12)
                set(gca,'fontsize',12)
            end
        end
        if numcomp >= lgc
            iend=lgc;
        else
            iend=numcomp;
        end
        tit={['ICA from RUNICA calculation - Components plot [',num2str(nf),']']
        ['datapath = ',pmat]};
        annotation(gcf,'textbox','String',tit,'interpreter','none',...
            'FontSize',13,'fontname','AvantGarde',...
            'LineStyle','none','HorizontalAlignment','center',...
            'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);
    
        namfig=['CompoPlot_',nfss,'_comp_',num2str(vfig(nf)),'_to_',num2str(iend),'_',num2str(vzoom(2)),'s'];
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
    end
    close
end