
% ________
% Parameters to adjust
% Anat data
p0 = '\\Filer\home\Personnels\zielinski\Mes documents\_Docs_\OnTheRoad\MEG\MEG_process\ADys\test_loca'; %'F:\Catsem';
p1 = cell(1,2);
p1{1,1} = {p0};    p1{1,2}= 0;
p1{2,1} = {'CAC','DYS'};   p1{2,2}= 0; 
p1{3,1} = {'S02'};   p1{2,2}= 0; 
p1{4,1}= {'MRI'}; p1{3,2}= 0; 

formimg = 'mri';
vdo = 2;

% Vecteur des indices des donnees a traiter
% vdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vdo = 1:10; => sur les 10 premieres donnees
% vdo=17; : sur la 17eme donnees
% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp=make_pathlist(p1);

for np=vdo
    [pmri,nmri]=dirlate(alldp{np},['*.',formimg]);
    if ~isempty(pmri)
        meg_mri_reslseg(pmri,1);
    end
end

