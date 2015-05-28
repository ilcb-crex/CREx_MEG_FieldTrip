function [Gindex,Gnam] = meg_volsplit(pos,fdos)  
% Decoupage d'un volume de source en 12 zones
% x decoupe en 3, y en 2 et z en 2
% pos : positions des sources actives (pos(inside,:))
% fdos : dossier ou sauver la figure representant les differentes zones

if nargin==1
    fdos=pwd;
end

% Decoupage des valeurs sur l'axe x (plans yz)
nbx=3; % Nombre de parties a decouper
x=pos(:,1);
dx=max(x)-min(x);
decx=min(x):dx/nbx:max(x);

if length(decx)<nbx+1
    decx=[decx max(x)]; 
end
decx(end)=decx(end)+max(diff(sort(x)));
% Nom des zones selon le decoupage en x
namx={'Back','Center','Front'};

% Decoupage des valeurs sur l'axe z (plans xy)
nbz=2;
z=pos(:,3);
dz=max(z)-min(z);
decz=min(z):dz/nbz:max(z);
if length(decz)<nbz+1
    decz=[decz max(z)]; 
end
decz(end)=decz(end)+max(diff(sort(z)));
% Nom des zones selon le decoupage en z
namz={'Bottom','Top'};

% Decoupage des valeurs sur l'axe y (plans xz)
nby=2;
y=pos(:,2);
dy=max(y)-min(y);
decy=min(y):dy/nby:max(y);
if length(decy)<nby+1
    decy=[decy max(y)]; 
end
decy(end)=decy(end)+max(diff(sort(y)));
% Nom des zones selon le decoupage en y
namy={'Right','Left'};

% Figure des 3 coupes avec les zones
ig=1;
nbg=(length(decx)-1)*(length(decy)-1)*(length(decz)-1);
G=cell(nbg,1);
Gnam=cell(nbg,1);

for ix=1:length(decx)-1
    for iy=1:length(decy)-1
        for iz=1:length(decz)-1
            indsourc=find(x>=decx(ix) & x<decx(ix+1)...
                & y>=decy(iy) & y<decy(iy+1)...
                & z>=decz(iz) & z<decz(iz+1));
            if ~isempty(indsourc)
                G{ig}=indsourc;
                Gnam{ig}=[namy{iy},namx{ix},namz{iz}];
                ig=ig+1;
            end
        end
    end
end
if ig-1<nbg
    G=G(1:ig-1);
    Gnam=Gnam(1:ig-1);
end

figure
set(gcf,'units','centimeters','position',[3 8 30 21])
colcol=get(gca,'colororder');
colc=[colcol ; 
    [colcol(:,[3 2]) abs(1-colcol(:,1)-.5)]];
pr=zeros(length(G),1);
for i=1:length(G)
    subplot(221), hold on,
    p=plot3(x(G{i}),y(G{i}),z(G{i}),'o','markersize',8,...
        'markerfacecolor',colc(i,:),'markeredgecolor','k');
    pr(i)=p(1);
    
    axis off
    set(gca,'view',[0 90])
    subplot(222), hold on,
    plot3(x(G{i}),y(G{i}),z(G{i}),'o','markersize',8,...
        'markerfacecolor',colc(i,:),'markeredgecolor','k');
    axis off
    set(gca,'view',[0 0])
    
    subplot(223), hold on,
    plot3(x(G{i}),y(G{i}),z(G{i}),'o','markersize',8,...
        'markerfacecolor',colc(i,:),'markeredgecolor','k');
    axis off
    set(gca,'view',[-180 0])    
end
lg=legend(pr,Gnam); %,'location','northeastoutside');
set(lg,'position',[0.6377 0.14 0.1480 0.2880],'fontsize',13,'box','off') 

subplot(221), pos=get(gca,'position');
set(gca,'position',[pos(1) pos(2)-.03 pos(3:4)]);
title('Above','fontsize',18,'color',[.4 .4 .4])

subplot(222), pos=get(gca,'position');
set(gca,'position',[pos(1) pos(2)-.03 pos(3:4)]);
title('From the right','fontsize',18,'color',[.4 .4 .4])

subplot(223)
title('From the left','fontsize',18,'color',[.4 .4 .4])

annotation(gcf,'textbox','String','Brain model dividing',...
    'FontSize',20,'fontname','AvantGarde','fontweight','bold',...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.12 .88 0.79 0.12]);
export_fig(fullfile(fdos,['VolModelGroups_',num2str(length(G)),'div.jpg']),'-m1.5')
close

disp(' ')
disp('Figure showing locations of channel groups saved as :')
disp(fullfile(fdos,['VolModelGroups_',num2str(length(G)),'div.jpg'])), disp(' ')

Gindex=G;
