function fpath = make_dir(dirpath,new)
% CREATION_DOSSIER cree le dossier dans lequel les resultats
% des calculs (matrices, figures) seront stockes
%
% DEBDOS contient le nom du dossier a creer 
% NEW vaut 1 pour creer un nouveau dossier, avec rajout d'un
%     numero consecutif a celui deja pre-existant, et
%     vaut 0 sinon
%
if nargin < 2 || isempty(new)
    new = 0;
end
ispath = strfind(dirpath,filesep);
if ~isempty(ispath) && ispath(end)==length(dirpath)
    dirpath = dirpath(1:end-1);
    ispath = strfind(dirpath, filesep);
end
if ~isempty(ispath) && length(ispath)>1 && any(diff(ispath)==1)
    inds = strfind(dirpath,[filesep filesep]);
    if ~isempty(inds)
        inds = sort(inds,1,'descend');
        for id = 1:length(inds)
            if inds(id)>1
                dirpath = dirpath(setdiff(1:length(dirpath),inds(id)));
            end
        end
    end
    
end
    
    
verif = dir([dirpath,'*']);	

if isempty(verif)==1
    if new==1
        fpath = [dirpath,'_1'];
    else
        fpath = dirpath;
    end
    mkdir(fpath)
else
    if new == 1
        nbmaxdos = 1; 
        nbdos = 1;
        for nn = 1:length(verif)
            nom = verif(nn).name;
            for do = 1:2
                if nom(length(nom)-do)=='_'
                    nbdos = str2double(nom(length(nom)-do+1:length(nom)));
                end
            end
            if nbdos > nbmaxdos
                nbmaxdos = nbdos;
            end
        end
        fpath = [dirpath,'_',num2str(nbmaxdos+1)];
        mkdir(fpath)
    else
        fpath = dirpath;
    end
end
if isempty(strfind(dirpath,filesep))==1
    fpath = [pwd, filesep, fpath];
end