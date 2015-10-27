% ________
% Parameters to adjust

% Paths for MEG datasets
p0 = 'F:\BaPa';
p1 = cell(1,2);
p1(1,:)= {{p0} , 0};
p1(2,:)= {{'CAC'}, 0}; 
p1(3,:)= {{'S01'}, 1}; 

vdo = [];  
% Vecteur des indices des donnees a traiter
% vsdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vsdo = 1:10; => sur les 10 premieres donnees
% vsdo=17; : sur la 17eme donnees

% Choice of calculus to perform
doTopoERfig = 0;
doChanGroup = 1;
doClusterStat = 0;

matpref = 'avgTrials';
%--- Type de donnees recherchees en fonction du pretraitement effectue
% Data preprocessing suffix
preproc = struct;
preproc.LPfc    = 40;   % Low-pass frequency
preproc.resfs   = 240;   % New sample frequency
preproc.crop    = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)

framopt = struct;
framopt.slidwin = -0.08 : 0.01 : 0.8;
framopt.lgwin = 0.02;

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp = make_pathlist(p1);

if isempty(vdo)
    vdo = 1:length(alldp);
end

strproc = preproc_suffix(preproc);



if doTopoERfig == 1
    for np = vdo 
        disp_progress(np, vdo);
        meg_ERF_topoplot(alldp{np}, matpref, strproc, framopt)
    end   
end    

if doChanGroup==1
    for np = vdo 
        disp_progress(np, vdo);
        meg_ERF_changroup(alldp{np}, matpref, strproc)        
    end
end



