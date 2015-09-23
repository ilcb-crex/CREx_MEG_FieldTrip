function meg_loc_map(sourC,mri,latwin,fnam,fdos,pnamSmat)
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
    latwin=[0 max(sourC.time)];
end
if nargin<4
    fnam='Cond';
end
if nargin<5
    fdos=pwd;
end
if nargin<6
    pSmat=fdos; 
    nSmat='unkwnSourcData';
else
    [pSmat,nam,ext]=fileparts(pnamSmat);
    nSmat=[nam,ext];
end


% Partie du titre des figures
fnamt=fnam;
fnamt(fnamt=='_')='-';
% Partie du noms pour sauver les matrices
fnamf=fnam;
fnamf(fnam=='-')='_';
fnamf(fnam=='.')='p';

time = sourC.time;
ok=1;
if isfield(sourC.avg,'z')
    avgz=sourC.avg.z;
elseif isfield(sourC,'z')
    avgz=sourC.z;
else
    disp('Field "z" not found in source data structure')
    ok=0;
end
% Check for latwin values
iok=zeros(length(latwin(:,1)),1);
for nw=1:length(latwin(:,1))
    if ~isempty(find(time>latwin(nw,1) & time<latwin(nw,2),1,'first'))
        iok(nw)=nw;
    end
end
if sum(iok)==0
    ok=0;
else
    latwin=latwin(iok>0,:);
end

if ok
    for nw=1:length(latwin(:,1))  % Pour chaque fenetre d'interet
        % Partie du nom des figures jpeg
        if length(num2str(nw))==1
            numfen=['0',num2str(nw)];
        else
            numfen=num2str(nw);
        end
        % Scalar field 
        % Initialisation des vecteurs
        avgmz=NaN(length(sourC.pos(:,1)),1);
        avgmz2=NaN(length(sourC.pos(:,1)),1);
        if iscell(avgz)
            cmat=cell2mat(avgz);
        else
            cmat=avgz;
        end
        % Calcul des valeurs moyennes dans la fenetre d'interet pour chaque
        % cellule non nulle de avgz
        avgmz(sourC.inside)=mean(cmat(:,time>latwin(nw,1) & time<latwin(nw,2)),2);
        avgmz2(sourC.inside)=mean(cmat(:,time>latwin(nw,1) & time<latwin(nw,2)).^2,2);
        

        styp={avgmz,avgmz2};
        stypnam = {'Z','sqrZ'};
        fenstr={num2str(latwin(nw,1).*1e3);num2str(latwin(nw,2).*1e3)};
        % Partie du nom des matrices
        fent=fenstr;
        fent{1}(fent{1}=='.')='p';
        fent{2}(fent{2}=='.')='p';
        fenff=[fent{1},'_',fent{2},'ms'];
        % Generation des figures pour chaque type de Z (Z, Zabs, et Z2)
        for nz=1:length(styp)
            sourC.avg.m=styp{nz}; % Le champ avg.m prend la valeur du champs scalaire calcule au dessus

            %______
            % Source interpolation 
            cfg = [];
            cfg.downsample = 2;
            cfg.interpmethod ='cubic';
            cfg.parameter = 'avg.m'; % Le champs scalaire sourC.avg.m est utilise
            sourcInt = ft_sourceinterpolate(cfg,sourC,mri);

            %______
            % Map of localisation with orthogonal projection of the maximum
            % absolute value        
            cfg = [];
            cfg.method = 'ortho'; 
            cfg.location = 'max';
            cfg.interactive = 'no';
            cfg.funparameter = 'm';
            if min(sourC.avg.m)<0
                cfg.funcolorlim = 'maxabs'; 
            else
                cfg.funcolorlim = 'zeromax';
            end
            ft_sourceplot(cfg,sourcInt);
            titlefig = {['[ ',fnamt,' ]',' - Source localisation using mean ',stypnam{nz},' from ',...
                fenstr{1},' to ',fenstr{2},' ms'];pSmat;nSmat};
            format_sourceorthofig(titlefig)
            namfig=['LocMap3Ortho_',stypnam{nz},'_',numfen,'_',fenff,'_',fnamf]; 
            export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5','-nocrop') 
            close

            %______
            % Map of localisation with slice representation
            cfg = [];
            cfg.method = 'slice';
            cfg.location = 'max';
            cfg.funparameter = 'm';
            if min(sourC.avg.m)<0
                cfg.funcolorlim = 'maxabs'; 
            else
                cfg.funcolorlim = 'zeromax';
            end
            %cfg.slicerange=[55 96];           
            ft_sourceplot(cfg,sourcInt);
            format_sourceslicefig(titlefig)
            namfig=['LocMapSlice_',stypnam{nz},'_',numfen,'_',fenff,'_',fnamf]; 
            export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5','-nocrop') 
            close
        end 

    end
end
function format_sourceorthofig(titlefig)
% Agrandissement de la figure
set(gcf,'units','centimeters','position',[8 10 18 15])

% Stockage des positions (et dimensions) des subplots
% et de la colorbar
hh=findobj(gcf,'type','axes');
posimg=zeros(length(hh)-1,4);
hsub=zeros(length(hh)-1,1);
m=1;
for n=1:length(hh)
    if ~strcmp(get(hh(n),'Tag'),'Colorbar')
        posimg(m,:)=get(hh(n),'position');
        subplot(hh(n)); axis 'off';
        hsub(m)=hh(n);
        m=m+1;
    else
        colbarpos=get(hh(n),'position');
        hcol=hh(n);
    end
end

% Agrandissement a nouveau de la figure 
% pour creer un espace pour le titre general
set(gcf,'position',[8 10 18 16])
% Redimensionnement des subplots
for s=1:length(posimg(:,1))
    set(hsub(s),'position',[posimg(s,1) posimg(s,2)-.05 posimg(s,3:4)])
end
% Redimensionnement de la colorbar et label
set(hcol,'position',[colbarpos(1) colbarpos(2)-.05 colbarpos(3) colbarpos(4)-.005])
set(get(hcol,'xlabel'),'String',...
        'Normalized value','fontsize',12,'fontweight','bold')
% Titre general de la figure    
annotation(gcf,'textbox','String',titlefig,'interpreter','none',...
    'FontSize',12,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);

function format_sourceslicefig(titlefig)
set(gcf,'units','centimeters','position',[17 6 21 18],...
    'color',[0 0 0])
set(gca,'units','centimeters','position',[0.4 -1.4 18 18.5])
annotation(gcf,'textbox','String',titlefig,'interpreter','none',...
    'FontSize',12,'fontname','AvantGarde',...
    'color',[1 1 1],...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.05 .85 .9 0.12]);
colb=findobj(gcf,'tag','Colorbar');
set(get(colb,'ylabel'),'String','Normalized value',...
    'Color',[1 1 1],'fontsize',12)
