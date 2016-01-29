function hrec = put_rectangle(limrect, vcolor)
% Ajoute des rectangles colores a l'arriere plan d'un graphique correspondant 
% a une serie temporelle (y = f(t), le temps etant represente par l'axe x),
% afin de mettre en valeur des intervalles de temps particuliers
%
% limrect : matrices des abscisses des cotes des rectangles N x 2
% (bornes inferieures et superieures des N rectangles a tracer)
% Par exemple le premier rectangle representera l'intervalle de temps
% compris entre limrect(1,1) et limrect(1,2). 
% La hauteur des rectangles est calculee en fonction des limites de 
% l'axe des ordonnees. La longueur des ticks des axes est prises en compte 
% afin que les rectangles ne cachent pas les ticks des axes des abscisses.
% La couleur par defaut est grise [.85 . 85 .85] si le vecteur couleur
% vcolor [R V B] n'est pas indique en entree de la fonction.
% 
%--- CREx 2014
%--- CZ acouvolc 2011

%--- Default color
if nargin < 2 || isempty(vcolor)
    vcolor = [.85 .85 .85];
end

%--- Check limrect input
if nargin < 1 || isempty(limrect) || sum(limrect(:))==0
    disp(' ')
    disp('!!! You must specify limrect values !')
    disp('Type help put_rectangle for explanations')
    hrec = [];
    return;
end

sz = size(limrect);
if any(sz==1) && length(limrect)~=2
    disp(' ')
    disp('Bad format for limrect input')
    disp('Must be a N x 2 matrix of rectangle x-limits')
    hrec = [];
    return;
end
    
if sz(1) == 2 && ( sz(2) > 2 || sz(2) == 1)
    limrect = limrect';
end
    
%--- GO !
hold on

%- Define height of the rectangle(s) (considerating tick length too)
yl = get(gca,'ylim');
deltay = yl(2)-yl(1);

tckl = get(gca,'ticklength');

sunit = get(gca, 'units');
if ~strcmp(sunit, 'centimeters')
    iscm = false;
    set(gca,'units','centimeter')
else
    iscm = true;
end

pos = get(gca,'position');
l = pos(3); 
h = pos(4);
if l>=h
    vtck = (tckl(1)*l*deltay)/h;
else
    vtck = deltay*tckl(1);
end

yi = yl(1) + 0.5*vtck; % Instead of 0.5
yf = yl(2) - 0.5*vtck;
yw = yf-yi;

%- Plot each rectangle

% Keep rectangle handle
hrec = zeros(length(limrect(:,1)),1);

for i = 1:length(limrect(:,1))
    xi = limrect(i,1);
    xf = limrect(i,2);
    xw = xf-xi;
    h = rectangle('position',[xi yi xw yw],'edgecolor','none','facecolor',vcolor);
    
    % Put it in the bottom 
    uistack(h,'bottom')
    
    hrec(i) = h;
end

if ~iscm
    set(gca,'units', sunit);
end



