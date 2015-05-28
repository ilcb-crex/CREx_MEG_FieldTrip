function gt = put_figtext(str, loc, sz, txcol, bkcol)
%
% PUT_FIGTEXT Place le texte str sur la fenetre graphique courante.
% Les options possibles sont l'emplacement (loc), la taille (sz), 
% la couleur (txcol) du texte et de l'arriere-plan (bkcol)
% 
% Exemple : put_figtext('A)','nw',14);
%
% loc : position du texte par rapport au centre de la figure
%       - NW pour NorthWest : coin en haut a gauche de la fenetre
%       - NE pour NorthEast : en haut a droite
%       - SW pour SouthWest : en bas a gauche
%       - SE pour SouthEast : en bas a droite
% Les lettres de la localisation peuvent etre entrees en minuscule et
% dans le desordre. Valeur par defaut (si non renseignee) : NW.
%
% sz : taille du texte. Par defaut sz=12;
%
% txcol : couleur du texte. Peut etre indique sous forme d'une lettre 
% correspondant aux couleurs Matlab par defaut ('r' pour rouge, 'b' pour 
% bleu, 'm' pour magenta etc.) ou en vecteur de 3 elements pour une couleur
% specifique ([R V B] avec R, V , B respectivement pour Rouge Vert Bleu, la
% valeur de la proportion de chaque couleur primaire (variant de 0 1). La
% couleur par defaut est noire.
% 
% bkcol : couleur de l'arriere-plan du texte (voir txcol pour le format).
% La couleur par defaut est blanche.
%

alloc = {'NW' 'NE' 'SW' 'SE' 'WN' 'EN' 'WS' 'ES'};

if nargin<=4 || (ischar(bkcol)==0 && length(bkcol)<3)
    bkcol = [1 1 1];
end
if nargin<=3 || (ischar(txcol)==0 && length(txcol)<3)
    txcol = [0 0 0];
end
if nargin<=2
    sz = 12;
end
if nargin<=1 || sum(strcmpi(loc,alloc))==0
    loc='NW';    
end
loc = upper(loc);

xl = get(gca,'xlim');
deltax = xl(2) - xl(1);
yl = get(gca,'ylim');
deltay = yl(2) - yl(1);
tckl = get(gca,'ticklength');

set(gca,'units','centimeter')
pos = get(gca,'position');
l = pos(3); 
h = pos(4);

if l>=h
    htck=deltax*tckl(1);
    vtck=(tckl(1)*l*deltay)/h;
else
    vtck=deltay*tckl(1);
    htck=(tckl(1)*h*deltax)/l;
end

switch loc
    case {'NW','WN'}
        posix = xl(1)+1.5*htck;
        posiy = yl(2)-1.5*vtck;

    case {'NE','EN'}
        posix = xl(2)-1.5*htck;
        posiy = yl(2)-1.5*vtck;

    case {'SW','WS'}
        posix = xl(1)+1.5*htck;
        posiy = yl(1)+1.5*vtck;
        
    case {'SE','ES'}
        posix = xl(2)-1.5*htck;
        posiy = yl(1)+1.5*vtck;
end
gt = text(posix,posiy,str,...
    'HorizontalAlignment','left',...
    'verticalalignment','top',...
    'color',txcol,...
    'BackgroundColor',bkcol,...
    'fontsize',sz);  

switch loc
    case {'NE','EN', 'SE','ES'}
       set(gt, 'horizontalalignment','right')
end
set(gca,'units','normalized');