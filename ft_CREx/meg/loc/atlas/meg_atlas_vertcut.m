function atlas = meg_atlas_vertcut(atlas, opt)
% Make vertical cut of ROI to define new ROI (sub-ROI of the initial atlas)
% ROI are supposed to have an orientation parallele to the x-axis
% Do the same thing for ROIs of the 2 hemispheres (R and L)

%- Check for crucial options
defopt = struct('ROInames', [], 'ncut', []);
if nargin < 2
    opt = defopt;
else
    opt = check_opt(opt, defopt);
end

if isempty(opt.ROInames) || isempty(opt.ncut)
    disp('Crucial input parameter are missing')
    atlas = [];
    return;
else
    if numel(opt.ROInames) ~= numel(opt.ncut)
        disp('For each ROI in opt.ROInames an associated')
        disp('number of subROI to make is required in opt.ncut')
        atlas = [];
        return;
    end
end

% Sub-ROI : cut ROI in ncut parts 
[iroi, ncut] = find_ROI(atlas.tissuelabel, opt.ROInames, opt.ncut);
Nr = length(iroi);


Alab = atlas.tissuelabel';
Alabini = Alab;
% iroi = zeros(length(Rcut),1);
% for i = 1 : length(Rcut)
%     iroi(i) = find(strcmp(Alab, Rcut{i})==1);
% end
pos = atlas.pos;
idtis = atlas.tissue(:); 

% This is only to cut a volume in 3 parts (sub-volumes), trying to
% balance the number of points inside each sub-volume (number of atlas
% points will be proportional to the number of sources from the 3D grid use
% for the subsequent
for i = 1 : Nr
    labini = Alabini{iroi(i)};
    ivol = find(strcmp(labini, Alab)==1); 
    % Ce sont les valeurs de idtis qu'il faut changer
    % Les positions restent identiques
    % Mais il faut inserer les 3 nouvelles zones, decaler les numeros
    % d'identification des autres
    
    Nsub = ncut(i);
    posc = pos(idtis==ivol,:);
    
    % Essayer d'equilibrer les volumes decoupes en terme de nombre de
    % points
    
    % Total number of points inside the ROI
    nbpt = length(posc(:));
    
    % Mean number of points for each subROI
    nbc = nbpt/Nsub;
    
    % The units are mm. We are search for a cutting with a precision <= cm
    % (because of the dipole grid). So we take a y-position vector with a
    % spacing of 5 mm to find the xz-plan for cutting the ROI.
    % We are using this vector for scanning the ROI volume and stop when
    % the optimum number of points inside the subROI is finding
    poscy = posc(:,2);
    
    vyp = fix(min(poscy)) : 0.5 : ceil(max(poscy));
    
    ycut = zeros(Nsub-1,1);
    
    % On augmente le volume en deplacant y jusqu'a ce que l'on atteigne le 
    % bon nombre de points (soit environ le tier du volume entier)
    goon = 1;
    j = 1;
    fcut = 2;
    iy = 1; % Index of the initial inferior limit of y (vypos(iy))  

    while goon
        
        % All points with y between vyp(icut) & vyp(fcut)
        cutvol = posc( poscy >= vyp(iy) & poscy < vyp(fcut), :);
        nbp = length(cutvol(:));
        if nbp >= nbc % We close the sub-volume
           % disp(num2str(nbp))
           ycut(j) = vyp(fcut-1);
           j = j+1;
           if j == Nsub
               goon = 0;
           end
           iy = fcut;
        end
        fcut = fcut+1;
    end
     
    % Les index de la ROI dans idtis
    itis = find(idtis==ivol); 
    
    %%% To adapt in the case of a cutting > 3 parts !!!   
    % Les index de la nouvelle sous-ROI dans pos
    % For the moment, only for 2 or 3 subROIs cutting
    if Nsub==2
        iback = itis(poscy <= ycut(1));
        ifront = itis(poscy > ycut(1));
    else
        iback = itis(poscy <= ycut(1));
        icent = itis(poscy > ycut(1) & poscy <= ycut(2));
        ifront = itis(poscy > ycut(2));
    end
    
    
    % We increase idtis identification number that follows the iroi that is
    % being cutted before to insert the new idtis of the subROI
    idtis(idtis > ivol) = idtis(idtis > ivol)+ Nsub-1;
    
    rlab = labini;
    if Nsub==2
        idtis(iback) = ivol;
        idtis(ifront) = ivol+1;
        
        clab = {[rlab(1:end-1),'Back_',rlab(end)]
            [rlab(1:end-1),'Front_',rlab(end)]};
    else
        idtis(iback) = ivol;
        idtis(icent) = ivol+1;
        idtis(ifront) = ivol+2;
        clab = {[rlab(1:end-1),'Back_',rlab(end)]
            [rlab(1:end-1),'Center_',rlab(end)]
            [rlab(1:end-1),'Front_',rlab(end)]};
    end
    Alab = [Alab(1:ivol-1) ; clab ; Alab(ivol+1:end)];

end
atlas.tissue(:) = idtis;
atlas.tissuelabel = Alab';

% function figcut(pos, idtis, icut, rlab)
% Make a beautiful one with black background for example
%     figure, plot3(pos(idtis>0,1), pos(idtis>0,2),pos(idtis>0,3),'+')  
%     hold on,
%     plot3(pos(iback,1), pos(iback,2),pos(iback,3),'ro')
%     plot3(pos(icent,1), pos(icent,2),pos(icent,3),'go')
%     plot3(pos(ifront,1), pos(ifront,2),pos(ifront,3),'mo')
% 
% figure, plot3(posc(:,1), posc(:,2),posc(:,3),'+')
% xlabel('x'), ylabel('y')
% hold on
% plot3(pback(:,1), pback(:,2), pback(:,3),'ro')
% plot3(pcent(:,1), pcent(:,2), pcent(:,3),'go')
% plot3(pfront(:,1), pfront(:,2), pfront(:,3),'mo')
% title('Cutting carnage of Temporal-Inf-L ROI') 
% saveas(gcf,'ROIcut_Temporal_Inf_L.fig')


function [iroi, ncut] = find_ROI(label, Rnam, ncut)

Rnam = reshape(Rnam, 1, numel(Rnam));
ncut = reshape(ncut, 1, numel(ncut));
% Removing "_R" or "_L" letters at the end of the label
for i = 1 : length(Rnam)
    if strcmp(Rnam{i}(end), 'L') || strcmp(Rnam{i}(end), 'R')
        Rnam{i} = Rnam{i}(1 : end-2);
    end
end
[ulab, ia] = unique(Rnam);
ucut = ncut(ia);
Nr = length(ulab);
iroi_LR = zeros(2, Nr);
ncut_LR = zeros(2, Nr);
% Reassociate R and L part 
k = 1;
for j = 1 : Nr
    iroi_L = find(strcmp([ulab{j}, '_L'], label)==1);
    iroi_R = find(strcmp([ulab{j}, '_R'], label)==1);
    if ~isempty(iroi_L) && ~isempty(iroi_R)
        iroi_LR(:, k) = [iroi_L ; iroi_R]; 
        ncut_LR(:, k) = [ucut(j) ; ucut(j)];
        k = k + 1;
    else
        ilab = find(strcmp(ulab{j}, label)==1);
        if ~isempty(ilab)
            iroi_LR(1, k) = ilab;
            ncut_LR(1, k) = ucut(j);
            k = k + 1;
        end
    end
end
iroi = iroi_LR(:); 
iroi = iroi(iroi > 0);
ncut = ncut_LR(:);
ncut = ncut(ncut > 0);

%--- Check opt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end