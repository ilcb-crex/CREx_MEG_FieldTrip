function [Gindex,Gnam] = meg_chansplit(Sgrad,datalabel,savpath)
% Retourne les index de chaque groupes
% Decoupe 12 zones de capteurs a partir des coordonnees retournees par
% ft_prepare_layout. Ces coordonnees correspondent a la projection
% orthographique des coordonnees 3D des capteurs renseignes dans le champs
% grad des structures de donnees crees a partir des fonctions FieldTrip.

if nargin<3
    savpath=pwd;
end
cfg = [];
cfg.grad=Sgrad;
cfg.layout = '4D248.lay';
lay = ft_prepare_layout(cfg);

figure
set(gcf,'units','centimeters','position',[9 9 17 13])    
lay.label = lay.label(1:end-2);
lay.pos = lay.pos(1:end-2,:);
%layy=rmfield(layy,{'height','width'}); %=layy.height(1:end-2);
%layy.width=layy.width(1:end-2);
ft_plot_lay(lay, 'point', true, 'pointsymbol','.','pointsize',1,'pointcolor',[1 1 1],...
    'box', false, 'label', true, 'labelsize',8,'mask', false, 'outline', true);

colcol=get(gca,'colororder');
colc=[colcol ; 
    [colcol(:,[3 2]) abs(1-colcol(:,1)-.5)]];
%colc([10 12],:)=colc([12 10],:);

x = lay.pos(:,1);
y = lay.pos(:,2);

dy=max(y)-min(y);
decy=min(y):dy/3:max(y);
if length(decy)<4
    decy=[decy max(y)]; 
end
decy(end)=decy(end)+max(diff(sort(y)));

dx=max(x)-min(x);
decx=min(x):dx/4:max(x);
if length(decx)<5
    decx=[decx max(x)]; 
end
decx(end)=decx(end)+max(diff(sort(x)));

% Ok, now we can reject channels that are not present in datalabel cellule,
% there are, channels that have been removed from analysis because of
% important noise...
if length(datalabel)<length(lay.label)
    igood=zeros(length(lay.label),1);
    for i=1:length(lay.label)
        if any(strcmp(datalabel,lay.label{i}))
            igood(i)=1;
        end
    end
    x=x(igood==1);
    y=y(igood==1);
    lay.label=lay.label(igood==1); %%%%%%%%
end
%%%%%%%%
indsort=zeros(length(datalabel),1);
for c=1:length(datalabel)
    indsort(c)=find(strcmp(lay.label,datalabel{c})==1);
end
x=x(indsort);
y=y(indsort);
%%%%%%%%
ig=1;
nbg=(length(decx)-1)*(length(decy)-1);
G=cell(nbg,1);
p=zeros(nbg,1);
hold on
for ix=1:length(decx)-1
    for iy=1:length(decy)-1
        indchan=find(x>=decx(ix) & x<decx(ix+1) & y>=decy(iy) & y<decy(iy+1));
        if ~isempty(indchan)
            G{ig}=indchan;
            pg=plot(x(indchan),y(indchan),'o','markersize',10,'markerfacecolor',colc(ig,:),...
                'markeredgecolor','k');
            p(ig)=pg(1);
            ig=ig+1;
        end
    end
end
if ig-1<nbg
    G=G(1:ig-1);
    p=p(1:ig-1);
end

Gnam={'OTg','Tg','FTg','OCg','Cg','Fg','OCd','Cd','Fd','OTd','Td','FTd'};
lg=legend(p,Gnam,'location','northeastoutside');
set(lg,'position',[0.8511 0.2497 0.12 0.45],'box','off')
title('Groups of channels used to visualize evoked-response fields','fontsize',12)
export_fig(fullfile(savpath,['ChanGroups_4Dlay_',num2str(nbg),'g.jpg']),'-m1.5')
close
disp(' ')
disp('Figure showing locations of channel groups saved as :')
disp(fullfile(savpath,['ChanGroups_4Dlay_',num2str(nbg),'g.jpg'])), disp(' ')
Gindex=G;





        
