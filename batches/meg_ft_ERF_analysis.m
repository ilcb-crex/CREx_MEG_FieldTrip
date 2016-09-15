% ________
% Parameters to adjust

% Paths for MEG datasets
p0 = 'H:\bapa_mseeg';

p1 =    {{p0} , 0
        {'S04'}, 0
        {'MEG'}, 0
         }; 

vdo = [];  
% Vecteur des indices des donnees a traiter
% vsdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vsdo = 1:10; => sur les 10 premieres donnees
% vsdo=17; : sur la 17eme donnees

% Choice of calculus to perform
doTopoERfig = 1;
doChanGroup = 0;
doClusterStat = 0;

matpref = 'avgTrials';
%--- Data to process as a function of preprocessing still made
% Data preprocessing suffix
datopt = [];
datopt.datatyp = 'avgTrials';
datopt.preproc.HPfc    = 1;     % High-pass frequency
datopt.preproc.LPfc    = 25;    % Low-pass frequency
datopt.preproc.resfs   = 200;   % New sample frequency
datopt.preproc.crop    = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)

%--- Figure option : sliding window parameters
framopt = [];
framopt.slidwin = -0.050 : 0.010 : 0.700;  % Starts of each window
framopt.lgwin = 0.02 ;                   % Duration of each window

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp = make_pathlist(p1);

if isempty(vdo)
    vdo = 1:length(alldp);
end


if doTopoERfig == 1
    for np = vdo 
        disp_progress(np, vdo);
        meg_ERF_topoplot(alldp{np}, datopt, framopt)
    end   
end    

if doChanGroup==1
    for np = vdo 
        disp_progress(np, vdo);
        meg_ERF_changroup(alldp{np}, datopt)        
    end
end



