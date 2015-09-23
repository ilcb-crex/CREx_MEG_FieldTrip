function meg_loc_map_framefig(sourC, mri, figopt)
% sourC : le resultat de ft_sourceanalysis
% mri : la structure FieldTrip de l'image IRM a utilise pour l'affichage 
% fnam : nom de la condition (defaut : 'Cond')
% fdos : nom du dossier ou sauver les figures (defaut : pwd)
% pnamSmat : chemin complet de la matrice contenant les sources issues de la modelisation
% (defaut : 'unkwnSourceData') - permet d'avoir indirectement le nom du
% dossier Sujet et du Run sur la figure
defopt = struct('param','z','slidwin', -0.08 : 0.01 : 0.8 ,'lgwin', 0.02,...
    'fname','', 'savpath', pwd, 'matpath', 'SourceModel.mat', 'visible', 'off');
if nargin < 2 || isempty(figopt)
    figopt = defopt;
else
    figopt = check_opt(figopt, defopt);
end

iwin = figopt.slidwin;
lgw = figopt.lgwin; 

param = figopt.param;

% Figures add-on information
% Indication on stimulus condition's name
if ~isempty(figopt.fname) 
    addtit = ['[ ',figopt.fname, ' ] - '];
    addsav = name_save(figopt.fname);
else
    addtit = '';
    addsav = 'Cond';
end
titlefig = {[addtit,'Source map based on ''',param, ''' signal parameter']; figopt.matpath ; ''};


time = sourC.time;
iwmax = find(iwin + lgw <= time(end),1, 'last');
iwin = iwin(1:iwmax);

Zmat = get_param(sourC, param);
% Define mean signal curve for the subplot
if min(Zmat(1,:))<0
    Zmean = mean(Zmat.^2);
    labmean = 'Mean square signal';
else
    Zmean = mean(Zmat);
    labmean = 'Mean signal';
end

[Zwin, crange, winfo] = prep_winfig(sourC, Zmat, iwin, lgw);

coltyp    = {'RelScal', 'FixScal'};
coltypdir = {'Relative_Scale', 'Fixed_Scale'};
colparam  = {'zeromax'; crange};
if crange(1) < 0
    colparam{1} = 'maxabs';
end
fdossc = cell(length(coltyp),1);

for nw = 1 : length(iwin)  % Pour chaque fenetre d'interet

    sourC.avg.m = Zwin{nw}; % Le champ avg.m prend la valeur du champs scalaire calcule au dessus

    %______
    % Source interpolation 
    cfg = [];
    cfg.downsample = 2;
    cfg.interpmethod ='cubic';
    cfg.parameter = 'avg.m'; % Le champs scalaire sourC.avg.m est utilise
    sourcInt = ft_sourceinterpolate(cfg, sourC, mri);

    % Template or subject MRI
    if sourcInt.dim==[91 109 91] %#ok
        slicerang=[15 75]; %10 80
    else
        slicerang=[55 96];
    end

    %______
    % Map of localization with slice representation
    cfg = [];
    cfg.method      = 'slice';
    cfg.location    = 'max';
    cfg.funparameter = 'm';
    cfg.slicerange  = slicerang;
    if crange(1)<0
        cfg.funcolormap = colormap_blue2red;
    end
    %%% CREx option adding inside ft_sourceplot function
    cfg.visible = figopt.visible; 
    
    titlefig {3} = winfo.namtit{nw};
            
    for nf = 1:length(coltyp)
        cfg.funcolorlim = colparam{nf};
        ft_sourceplot(cfg, sourcInt);

        dt = [iwin(nw) iwin(nw)+lgw];
        format_slicemapfig(time, Zmean, labmean, dt, titlefig, figopt)  
        
        if nw==1
            fdossc{nf} = make_dir([figopt.savpath,filesep,coltypdir{nf}],0);
        end       
        export_fig([fdossc{nf}, filesep, 'SourceMapFrame_', addsav, '_', coltyp{nf}, winfo.namsav{nw},'.jpeg'],'-m1.5','-nocrop') 
        close
    end
end

%____
% Additional functions

%--- Check figopt structure
function figopt = check_opt(figopt, defopt)
%defopt = struct('slidwin', -0.08 : 0.01 : 0.8 ,'lgwin', 0.02,...
%    'fname','', 'savpath', pwd, 'pathmat', 'SourceModel.mat');
defn = fieldnames(defopt);
optn = fieldnames(figopt);

for j = 1 : length(defn)
    if strcmp(optn, defn{j})==0
       figopt.(defn{j}) = defopt.(defn{j});
    end
end
if isempty(dir(figopt.savpath))
    figopt.savpath = make_dir([pwd, filesep, 'SourceMap_Znorm'],1);
end

%--- Extract param field and check for its format 
function valparam = get_param(Sso, param)

%--- Extract variable in Sso structure according to param fieldname

% Check if param contained a '.' character
% Search of variable in subfield
ipt = strfind(param,'.');
if ~isempty(ipt)
    fn = strsplitt(param, '.');
    try valp = getfield(Sso, fn{:});
    catch
        % Maybe last subfield name is correct
        valp = get_field(Sso, fn{end});
    end
else
    % param is the field name
    if isfield(Sso, param)
        valp = Sso.(param);
    else
        valp = get_field(Sso, param);
    end
end
%--- Check valp type and size, format it (should be a Ns x Nt matrix, Ns
% being the number of inside sources and Nt the number of time sample)

if ~isempty(valp)
    if iscell(valp)
        valp = cell2mat(valp);
    end
    if ndims(valp)==3
        sz = size(valp);
        try
            Ns = length(Sso.pos(Sso.inside,1));
            Nt = length(Sso.time);
            isq = find(sz ~=Ns & sz~=Nt);
            if ~isempty(isq)
                isq = 1;
            end
        catch
            isq = 1;
        end
        valp = squeeze(mean(valp), isq);
    end
    valparam = valp;
else
    valparam = [];
    disp('Source parameter to display on map not found in ')
    disp(['data structure. Parameter field name :  ', param])
end


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

%--- Define mean signal by time windows that will be represented 
% by ft_sourceplot, color map range and time windows informations added on
% the figure
function [Zwin, crange, winfo] = prep_winfig(sourC, Zmat, iwin, lgw)
    
time = sourC.time;
Npos = length(sourC.pos(:,1));
inspos = sourC.inside;
% Calculus of all mean Z values to determine the range of the colorbar
Zwin = cell(length(iwin),1);
winfo = struct;
[winfo.namsav, winfo.namtit] = deal(cell(length(iwin),1));
minmax = zeros(length(iwin),2);
for s = 1:length(iwin)
    Zwin{s} = NaN(Npos, 1);

    % Calcul des valeurs moyennes dans la fenetre d'interet pour chaque
    % cellule non nulle de avgz
    avgzwin = mean( Zmat(:, time>=iwin(s) & time<=iwin(s)+lgw), 2);  %%% !! .^2  
    Zwin{s}(inspos) = avgzwin;
    
    minmax(s,:) = [min(avgzwin) max(avgzwin)];
    
    [ msi, msf] = win_ms( iwin(s), lgw); 
    if s < 10
        numfram=['0',num2str(s)];
    else
        numfram=num2str(s);
    end
    winfo.namtit{s} = ['t = [', msi, ' ', msf,'] ms'];
    winfo.namsav{s} = name_save(['_',numfram,'_',msi, '_to_', msf,'_ms']);   
end
% minmax=[min(minmax(:,1)) max(minmax(:,2))];  
crange = [min(minmax(:,1)) max(minmax(:,2))-(max(minmax(:,2))-mean(minmax(:,2)))./2];


    
function format_slicemapfig(time, Zmean, labmean, dt, titlefig, figopt) 
% Add subplot of mean Z2 signal (all source) and format figure size etc...

% Figure and axes sizes
set(gcf,'visible',figopt.visible,'units','centimeters','position',[10 2 21 26],'color',[0 0 0])
set(gca,'units','centimeters','position',[0.4 8 18 18.5]) 

% Colorbar
colb = findobj(gcf,'tag','Colorbar');
set(colb,'ycolor',[1 1 1],'position',[0.8967 0.4252 0.0160 0.5057])
set(get(colb,'ylabel'),'String','Normalized value',...
    'Color',[1 1 1],'fontsize',12)

% Add subplot of temporal signal (mean of all sources)
grey = [.6 .6 .6]; % Color for the axes

sub = axes('Parent',gcf,'Position',[0.0705 0.08 0.8175 0.27]);  
plot(time, Zmean, 'color',[.8 .8 .8],'linewidth',1.5);
hold on
plot( time( time >= dt(1) & time <= dt(2) ),...
    Zmean( time >= dt(1) & time <= dt(2) ),'r','linewidth',3)
set(sub,'linewidth',1.2,'box','off','color',[0 0 0],'xcolor',grey,'ycolor',grey);

xl = xlim;
set(sub, 'xtick', xl(1):0.2:xl(end))

xlabel('Time (s)','color',grey,'fontsize',13)
ylabel(labmean,'color',grey,'fontsize',13)
set(gca,'fontsize',12)

title('Mean square Z-normalized signals (all sources)','color',grey,'fontsize',13)

% Main title
annotation(gcf,'textbox','String', titlefig, 'interpreter','none',...
        'FontSize',13,'fontname','AvantGarde','color',[1 1 1],...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 0.9116 0.9 0.0859]);