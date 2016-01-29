function meg_loc_beamfpow_map(sourC_bfmeth,mri,latwin,fnam,fdos,pnamSmat)
% sourC : le resultat de ft_sourceanalysis
% fnam : nom de la condition (defaut : 'Cond')
% fdos : nom du dossier ou sauver les figures (defaut : pwd)
% nso : nom de la matrice contenant les sources issues de la modelisation
% (defaut : 'unkwnSourceData')
if nargin<3
    latwin=[0 max(sourC_bfmeth{1}{1}.time)];
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





fnamt=fnam;
fnamt(fnamt=='_')='-';

fnamf=fnam;
fnamf(fnam=='-')='_';
fnamf(fnam=='.')='p';


for nw=1:length(latwin(:,1))
    if length(num2str(nw))==1
        numfen=['0',num2str(nw)];
    else
        numfen=num2str(nw);
    end

    %styp={avgmz,avgmza,avgmz2};
    %stypnam = {'Z','absZ','sqrZ'};
    fenstr={num2str(latwin(nw,1).*1e3);num2str(latwin(nw,2).*1e3)};
    fent=fenstr;
    fent{1}(fent{1}=='.')='p';
    fent{2}(fent{2}=='.')='p';
    fenff=[fent{1},'_',fent{2},'ms'];
    
    for nz=1:length(sourC_bfmeth)
        sourC=sourC_bfmeth{nz}{nw};
        
        %______
        % Source interpolation 
        cfg = [];
        cfg.downsample = 2;
        cfg.interpmethod ='cubic';
        cfg.parameter = 'avg.pow';
        sourcInt = ft_sourceinterpolate(cfg,sourC,mri);

        %______
        % Map of localisation with orthogonal projection of the maximum
        % absolute value        
        cfg = [];
        cfg.method = 'ortho';
        cfg.location = 'max';
        cfg.interactive = 'no';
        cfg.funparameter = 'pow';
        if min(sourC.avg.pow)<0
            cfg.funcolorlim = 'maxabs'; 
        else
            cfg.funcolorlim = 'zeromax';
        end
        ft_sourceplot(cfg,sourcInt);
        titlefig = {['[ ',fnamt,' ]',' - Source localisation using beamforming method n°',num2str(nz),' from ',...
            fenstr{1},' to ',fenstr{2},' ms'];pSmat;nSmat};
        format_sourceorthofig(titlefig)
        namfig=['LocMapBF3Ortho_',numfen,'_meth',num2str(nz),'_',fenff,'_',fnamf]; 
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5','-nocrop') 
        close
        
        %______
        % Map of localisation with slice representation
        cfg = [];
        cfg.method = 'slice';
        cfg.location = 'max';
        cfg.funparameter = 'pow';
        if min(sourC.avg.pow)<0
            cfg.funcolorlim = 'maxabs'; 
        else
            cfg.funcolorlim = 'zeromax';
        end
        ft_sourceplot(cfg,sourcInt);
        format_sourceslicefig(titlefig)
        namfig=['LocMapBFSlice_',numfen,'_meth',num2str(nz),'_',fenff,'_',fnamf]; 
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5','-nocrop') 
        close
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
        'Maximum absolute value','fontsize',12,'fontweight','bold')
% Titre general de la figure    
annotation(gcf,'textbox','String',titlefig,'interpreter','none',...
    'FontSize',11,'fontname','AvantGarde',...
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
set(get(colb,'ylabel'),'String','Maximum absolute value',...
    'Color',[1 1 1],'fontsize',12)
