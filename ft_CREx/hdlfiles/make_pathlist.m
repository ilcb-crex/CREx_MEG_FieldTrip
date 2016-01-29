function pathlist = make_pathlist(archicell)
% MAKE_PATHLIST Genere un ensemble de chemins d'acces aux dossiers selon
% l'architecture definie dans la cellule archicell
% Ces chemins sont stockes dans la cellule pathlist.
%
% Ex. d'architecture :
%
%     D1              D2        D3        D4       
%
%                                   |--- Run_1
%              	|---- S01 |---- MEG |--- Run_2
%               |                   |--- Run_3
%               |
%               |---- S02 |---- MEG |--- Run_2    
%               |                   |--- Run_3
% Project_1 ----|                  
%               |                                 
%              	|---- P01 |---- MEG |--- Run_3
%               |
%               |---- P02 |---- MEG |--- Run_1    
%                                   |--- Run_2
%
% Construction de l'argument archicell :
% Une cellule comportant autant de ligne que de niveau n de dossier (Dn)
% et 2 colonnes : col. 1 : le nom complet ou partiel du dossier (le debut
%                 du nom a recherche)
%                 col. 2 : l'indication sur le caractere complet ou partiel
%                 du nom du dossier cherche (1 : nom partiel, 0 : complet)
% Ex. avec l'architecture ci-dessus, archicell = p avec :
% p{1,1}= {'Project_1'};  	p{1,2}= 0;
% p{2,1}= {'S','P'};       	p{2,2}= 1;
% p{3,1}= {'MEG'};          p{3,2}= 0;
% p{4,1}= {'Run'};          p{4,2}= 1;
% 
% p{2,2}= 1 => l'ensemble des dossiers dont le nom commence par 'S' ou 'P' 
% sera recherche a l'interieur du dossier D2 pour definir les chemins 
% d'acces. Idem avec p{4,1}, tous les dossiers dont le nom commence par
% 'Run' trouves dans le dossier D4 seront integres a la liste de chemins.
% 
% 
% Si le chemin du dossier de travail courant de Matlab n'est pas celui
% ou sont situes les dossiers en D1, il est necessaire d'indiquer le chemin
% d'acces complet au dossier place en position D1 dans p{1,1}.
% Ex. : p{1,1}= {'C:\path1\Project_1'};
%
% >> pathlist = make_pathlist(p)
% >> char(pathlist)
% >> ans =
%   F:\path1\Project_1\S01\MEG\Run_1 
%   F:\path1\Project_1\S01\MEG\Run_2
%   F:\path1\Project_1\S01\MEG\Run_3
%   F:\path1\Project_1\S02\MEG\Run_2
%   F:\path1\Project_1\S02\MEG\Run_3
%   F:\path1\Project_1\P01\MEG\Run_3
%   F:\path1\Project_1\P02\MEG\Run_1
%   F:\path1\Project_1\P02\MEG\Run_2
      
pathlist = cell(1,1);

arch = check_archicell(archicell);


% Initialisation des chemins initiaux


inipth=cell(1,1);
np=1;
for i=1:length(arch{1,1})
    [chem,dos]=fileparts(arch{1,1}{i});
    partf = find_alldos(chem, dos, arch{1,2});
    if ~isempty(partf)
        for j=1:length(partf)
            inipth{np} = partf{j};
            np=np+1;
        end
    end
end
if length(arch(:,1))==1 && ~isempty(partf)
    pathlist = partf';
else
    % Plusieurs chemins initiaux a sonder
    for k=1:length(inipth)
        pini = inipth{k};
        partf = find_alldos(pini,arch{2,1},arch{2,2});
        if ~isempty(partf)
            if k==1
                parta=partf;
            else
                parta=[parta,partf]; %#ok
            end
        end
    end
    if exist('parta','var')
        pathlist = parta';
        if length(arch(:,1))>2
            newarch = cell(length(arch(:,1))-1,2);
            newarch{1,1} = parta; 
            newarch{1,2} = 0;
            newarch(2:length(arch(:,1))-1,1) = arch(3:length(arch(:,1)),1);
            newarch(2:length(arch(:,1))-1,2) = arch(3:length(arch(:,1)),2);
            arch = newarch;
            pathlist = make_pathlist(arch);
        end
    end
end
% Suppression des valeurs vides
if length(pathlist)>1
    tmp = pathlist;
    pathlist = cell(1,1);
    nc = 1;
    for c = 1:length(tmp)
        if ~isempty(tmp{c})
            pathlist{nc} = tmp{c};
            nc = nc+1;
        end
    end
end
pathlist = pathlist';

if isempty(pathlist{1})
    disp('--- Directories not found with input architecture')
end
function allfound = find_alldos(herepath, debnomdos, opt)
    if nargin<3
        opt = 1;
    end
    if opt
        aj = '*';
    else
        aj = '';
    end
    allfound = cell(1,1);
    if ~iscell(debnomdos)
        debnomdos = {debnomdos};
    end

    id = 1;
    for n = 1:length(debnomdos)

        fpt = [herepath,filesep,debnomdos{n},aj];
        if opt
            fd = dir(fpt);
            if ~isempty(fd)
                for k = 1:length(fd)
                    if isdir([herepath,filesep,fd(k).name])
                        allfound{id} = [herepath,filesep,fd(k).name];
                        id = id+1;
                    end
                end
            end
        else
            if isdir(fpt)
                allfound{id} = fpt;
                id = id+1;
            end
        end

    end

function arch = check_archicell(archic)

    
    sz = size(archic);
    
    % Formatage de archicell
    % [1] Format erronné - Plusieurs cas possibles :
    %  Size = 1x1 ou size = 1xN ou size = Nx1 ET chaque element est une
    %  cellule contenant une ou plusieurs chaines de caractere  
    % => il manque l'indication du type de recherche souhaite (0 ou 1) en
    % deuxieme colonne
    % => parallelement, si le contenu est directement une chaine de 
    % caractere et non une cellule, il faut le transformer en cellule
    
    newarch = cell(1,2);
    % [1a] Une chaine de caractere seule
    if ( sz(1)==1 && sz(2)>1 ) && ischar(archic)
        newarch = {{archic}, 0};
    end    
    
    % [1b] Une cellule uniquement
    if sz(1)==1 && sz(2)==1 && iscell(archic)
        newarch = [archic 0];
    end
    
    % [1c] Une inversion ligne / colonne
    if sz(1)==2 && sz(2)==1 && isnumeric(archic{2}) 
        if iscell(archic{1})
            newarch = archic';
        elseif ischar(archic{1})
            newarch = {archic(1) archic{2}};
        end
    end
    
    % [1d] Un tableau de cellules 1xN ou Nx1
    if ( sz(1)==1 && sz(2)>1 ) || ( sz(1)>1 && sz(2)==1 ) && ~isnumeric(archic{max(sz)})
        allc = zeros(max(sz), 1);
        for  c = 1:max(sz)
            if ischar(archic{c})
                archic{c} = archic(c);
            end
            allc(c) = iscell(archic{c});
        end
        if sum(allc) == max(sz)
            if sz(2)>1
                archic = archic';
            end
            newarch = archic;
            newarch(:,2) = deal({1});
        end
    end
    if ~isempty(newarch{1})
        archic = newarch;
        sz = size(archic);
    end
    
    % [2] Format correct : N x 2 mais contenu incorrect
    if sz(1)>=1 && sz(2)==2
        lg = sz(1);
        for j = 1:lg
            if ischar(archic{j,1}) 
                archic{j,1} = archic(j,1);
            end
            if ~ischar(archic{j,1}{1})
                archic{j,1} = {''};
                archic{j,2} = 1;
            end
            if iscell(archic{j,2}) && isnumeric(archic{j,2}{1})
                archic{j,2} = archic{j,2}{1};
            end
            if ~isnumeric(archic{j,2})
                archic{j,2} = 1;
            end
        end
    end
    
    % [3] Retrait des eventuels separateurs de fichiers a la fin des noms
    % ainsi que des blancs au debut et a la fin
    for k = 1:length(archic(:,1))
        for n = 1:length(archic{k,1})
            if ~isempty(archic{k,1}{n})
                while strcmp(archic{k,1}{n}(1),' ')
                    archic{k,1}{n} = archic{k,1}{n}(2:end);
                end
                while strcmp(archic{k,1}{n}(end),' ')
                    archic{k,1}{n} = archic{k,1}{n}(1:end-1);
                end  
                if strcmp(archic{k,1}{n}(end), filesep)
                    archic{k,1}{n} = archic{k,1}{n}(1:end-1);
                end
            end
        end
    end
    arch = archic;
    
    % Initialisation
    pth = arch{1,1};

    for i= 1:length(pth)
        % Cas ou pth{i} est un nom de fichier/dossier et non un chemin
        if isempty(strfind(pth{i},filesep)) 
            arch{1,1}{i}=[pwd, filesep, pth{i}];
        end
    end

      