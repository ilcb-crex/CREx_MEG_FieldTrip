function colc = color_group(ncol)
% Retourne une palette de couleurs fixe
% Cela permet de retrouver l'ordre des couleurs et de les regenerees au
% (a l'instar de la creation d'une palette a partir de "rand")
%

figure
col = get(gca,'colororder'); 
% Retourne une matrice definissant 7 couleurs (7 lignes, 3 colones R V B)
% We remove the last one, to much dark (dark-grey)
col = col(1:end-1,:);
close
colcol = [  0.043	0.52    0.78 
            0.85	0.16	0
            0.16    0.73    0.12
            1       0.686    0
            0.10    0.86    0.86
            0.87	0.49	0
            0       0.60    0.40
            0       0.75    0.75  
            col
            ];
        
%         colcol = [  0.043	0.52    0.78 
%             0.85	0.16	0
%             0.09    0.70    0.24
%             1       0.76    0
%             0.10    0.86    0.86
%             0.87	0.49	0
%             0       0.60    0.40
%             0       0.75    0.75  
%             col
%             ];
if ncol < length(colcol(:,1))
    colc = colcol(1:ncol,:);
else
    % Palette de base (ncol<=14)
    colc = [colcol ; 
        [col(:,[3 2]) abs(1-col(:,1)-.5)]]; % Biotifoul...
    lgcol = length(colc(:,1));
    % Si ncol>lgcol : definition d'autres lignes...
    % On part de la palette de base que l'on modifie au fur et a mesure
    if ncol > lgcol
        % On ajoute des jeux de 14 couleurs à chaque fois
        nbset = 14;
        ndiv = ceil((ncol-lgcol)./nbset); % Combien de matrice de taille (nbset x 3) a ajouter
       
        for i = 1 : ndiv            
            if mod(i,2) 
                colb = circshift(colc(end-13:end, :),[1 -1]);
                colb(:,1) = colb(:,1)-.1;
            else
                colb = circshift(colc( end-13:end, :),[-1 1]);
                colb(:,3)=colb(:,3)+.1;
            end
            if mod(i,3)
                colb = [colb(1:2:end-1,[2 3 1])-0.05
                    colb(2:2:end,[2 1 3])+0.05];
            end
            adcol = mod(abs(colb),fix(abs(colb)));
            s = sum(adcol,2);
            adcol(s<.6,:) =  colb(s<0.6,:) +.25;
            adcol(s>2.5,:) = colb(s>2.5,:) -.25;
            adcol(adcol<.15) = 0;
            adcol(adcol>.95) = 1;
            colc = [colc ; adcol]; %#ok
        end
    end
    colc = colc(1:ncol, :); 
end

%
% View of the colors
%
% 
% figure, hold on
% for i = 1:length(colc(:,1))
%     plot(i,1,'o','markersize',12,'markerfacecolor',colc(i,:),'markeredgecolor','none')
% end