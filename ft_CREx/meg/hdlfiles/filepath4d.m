function datapath = filepath4d(path,dtyp)
% FILEPATH4D : retourne le chemin d'acces complet aux donnees 4D trouvees
% dans le dossier indique par le chemin path.
% dtyp est un parametre optionnel qui specifie le type de donnees 4D a 
% rechercher.
% Valeur de dtyp selon le type de fichier 4D de donnees cherche :
% 'raw'    : raw data ("c,rfDC")
% 'rawcor' : raw data with noise correction ("c,rfDC,n")
% 'filt'   : filtered data ("c,rf*Hz")
% 'filtcor': filetered data with noise correction ("c,rf*Hz*n")
%
% Si la chaine de caractere dtyp n'est pas renseignee ou vide, les donnees
% 4D seront recherchees selon cette ordre : 
% (1) 'c,rfDC,n' : non filtrees avec reduction de bruit, 
% (2) 'c,rfDC'   : non filtrees brutes
% (3) 'c,rf*Hz*n': filtrees avec reduction de bruit
% (4) 'c,rf*Hz'  : filtrees uniquement
% Le chemin du premier fichier trouve correspondant est retourne.
% On suppose que les donnees brutes avec reduction de bruit sont a extraire
% en priorite si elles sont en effet trouvees dans le dossier path.

rawdatanam = {'c,rfDC,n','c,rfDC','c,rf*Hz*n','c,rf*Hz'}; 
dtypnam = {'rawcor','raw','filtcor','filt'};

if nargin==2 && isempty(dtyp) && sum(strcmp(dtyp,dtypnam))==1
    datnam = rawdatanam{strcmp(dtyp,dtypnam)==1};
    dpath = [path,filesep,datnam];
    dp=dir(dpath);
    if isempty(dp)
        disp('!!')
        disp(['4D data "',datnam,'" not found in directory :'])
        disp(path)
        disp(' ')
        datapath = [];
    else
        datapath = [path,filesep,dp(1).name];
    end
else
    % Recherche des fichiers 4D par defaut
    goon = 1;
    i = 1;
  
    while goon && i<=length(rawdatanam)
        dpath = [path,filesep,rawdatanam{i}];
        dp = dir(dpath);        
        if ~isempty(dp)
            datapath = [path,filesep,dp(1).name];
            goon = 0;
        end
        i = i+1;
    end
    if goon==1
        disp('!!')
        disp('4D data not found in directory :')
        disp(path)
        disp(' ')
        datapath = [];
    end
end
if ~isempty(datapath)
    [T,fnam] = fileparts(datapath); %#ok
    disp(' ')
    disp(['---- Found : ',fnam]), disp(' ')
end