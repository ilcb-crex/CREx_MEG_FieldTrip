function [diffvol_NaN,diffvol_0] = get_diffvol3D(volref,volcomp,writeopt,pathwrite)
% GET_DIFFVOL3D  Effectue la difference entre deux volumes 
%                (voxel a voxel) : Volume à comparer - Volume de reference
%
% [diffvol_NaN,diffvol_0] = GET_DIFFVOL3D(volref,volcomp,writeopt,pathwrite)
%
% 	volref  - nom du volume de reference
%
%   volcomp - nom du volume a comparer avec le volume de reference
%       => Des chaines de caractere designant les noms des volumes 
%       (nom seul si le volume est present dans le repertoire courant
%       (pwd) ou chemin d'acces complet)
%       => Ces volumes sont des objets NIFTI ou IMG (avec HDR associe)
%
%   writeopt  - si l'on souhaite sauver la matrice de resultats et ecrire 
%               le volume 3D correspondant a la difference : 
%               writeopt = 'w' ; Ne rien indiquer sinon.
%
%   pathwrite - si 'w' est entre : chemin du dossier d'enregistrement
%               des resultats de la difference (matrice et image du volume)
%               Si non renseigne : pathwrite = pwd.
%
% Variables de sortie : matrices 3D des difference voxel a voxel entre les 
% 2 images entrees. Deux versions de matrices :
%
%   diffvol_NaN - les differences en considerant les valeurs NaN
%                   initiales des images en entrees
%   diffvol_0   - les differences en remplacant prealablement les valeurs 
%                   NaN contenues dans les images initiales par des zeros
%
%
% Exemple : [voldiff_NaN,voldiff_0] =
% get_diffvol3D(path_vol1,path_vol2,'w',pathresults);
%
% path_vol1 = 'C:\GoodJob\MRIf_Project_1\Subj01\Stat1stLevel\con_001.img';
% path_vol2 = 'C:\GoodJob\MRIf_Project_1\Subj02\Stat1stLevel\con_001.img';
% pathresults = 'C:\GoodJob\MRIf_Project_1\Analysis\DiffVol_001'
% Sauve la matrice contenant la difference con_001_[path_vol2] -
% con_001_[path_vol1] (version avec des NaN et avec des 0)
% diffvol_con001_VS_con001_NaN.img
% diffvol_con001_VS_con001_Z.img
%   Si le nom de fichier existe deja, 
%
% Cette fonction utilise de façon directe les fonctions SPM : 
% spm_vol, spm_read_vols (et spm_write_vol si writeopt='w')
%
% 
%________________________________________________________________________
% $ 26/07/2013 -- CREx BLRI -- $
%


% ________
% Check input
if nargin==3
    pathwrite=pwd;
end
if nargin<3
    writeopt='no';
end
if nargin==4
    if isempty(strfind(pathwrite,filesep))
        pathwrite=[pwd,filesep,pathwrite];
    end
    % Make directory if it doesn't exist yet
    if ~isdir(pathwrite)
        mkdir(pathwrite)
    end
end

% Define path if inputs volref and volcomp are only names of files
if isempty(strfind(volref,filesep))
   pvolref=[pwd,filesep,volref];
end
if isempty(strfind(volcomp,filesep))
   pvolcomp=[pwd,filesep,volcomp];
end

% Check if volume's files exist
dref=dir(pvolref);
dcomp=dir(pvolcomp);
if isempty(dref) || isempty(dcomp)
    disp('Volume''s file not found')
    if isempty(dref)
        disp(['??? ',pvolref])
    end
    if isepty(dcomp)
        disp(['??? ',pvolcomp])
    end
    return
end
  
% ________
% Read volumes
try
    hdrr=spm_vol(pvolref);
    Vref=spm_read_vols(hdrr);
catch
    disp('Impossible to read the volume...')
    disp(['??? ',pvolref])
    return
end

try
    hdrc=spm_vol(pvolcomp);
    Vcomp=spm_read_vols(hdrc);
    if ~all(hdrr.dim==hdrc.dim)
        disp('Impossible to calculate the difference :')
        disp('Non-identical dimensions between the two volumes :')
        disp(['volref (',hdrr.fname,') : DIM = [',num2str(hdrr.dim),']'])
        disp(['volcomp(',hdrc.fname,') : DIM = [',num2str(hdrc.dim),']'])
        return
    end
catch
    disp('Impossible to read the volume...')
    disp(['??? ',pvolcomp])
    return
end

% ________
% Calculation

% Difference by keeping potential NaN in input images       
diffvol_NaN=Vcomp-Vref;

% Difference by preliminary replacing NaNs with zeros 
Vr0=Vref;
Vc0=Vcomp;
Vr0(isnan(Vr0))=0;
Vc0(isnan(Vc0))=0;
diffvol_0=Vc0-Vr0;

% ________
% Write
if strcmp(writeopt,'w')
    [~,namr,~]=fileparts(pvolref);
    [~,namc,d]=fileparts(pvolcomp);
    newhdr=hdrr;
    namr(namr=='_')='';
    namc(namc=='_')='';
    newhdr.fname=[pathwrite,filesep,'diffvol_',namc,'_VS_',namr,'_NaN',d];
    if warning_replace(newhdr.fname)
        delete(newhdr.fname)
    end
    spm_write_vol(newhdr,diffvol_NaN);        
    newhdr.fname=[pathwrite,filesep,'diffvol_',namc,'_VS_',namr,'_Z',d];
    if warning_replace(newhdr.fname)
        delete(newhdr.fname)
    end
    spm_write_vol(newhdr,diffvol_0);
    save([pathwrite,filesep,'diffvol_',namc,'_VS_',namr],'diffvol_*')
end

% ________
% Additional Function

% Warning message if file already exists
function statut = warning_replace(namefile)
    if ~isempty(dir(namefile))
        disp(' ')
        disp('Pre-existing file  :')
        disp(namefile)
        disp('will be replaced by the undergoing processing file...')
        statut = 1;
    else
        statut = 0;
    end


            
        
        