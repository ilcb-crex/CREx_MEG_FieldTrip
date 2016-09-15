% ________
% Parameters to adjust

%--- Architecture indiquant l'accès aux donnees sources
p0 = 'H:\PWD';
pso = cell(1,2);
pso(1,:)= {{p0} , 0};
pso(2,:)= {{'Set_'}, 1}; 
pso(3,:)= {{'pure'}, 0}; 
% pso(4,:)={{'Run_concat'},0};

%--- Indice de pso indiquant les dossiers Subject 
isubj = 2;


%--- Vecteur des indices des donnees des sujets a traiter selon pso
% vsdo = [] : tous les sujets trouves a partir de l'architecture pso
vsdo = []; 

%--- Nom du groupe de donnees
grp_name = 'pure';

doGA = 1;

template_grid = 'template_Colin27_BS.mat';  %%% A mettre dans dossier CREx/loc/hdmYH
template_mri = 'Colin27_BS.nii';


%--- Type de donnees recherchees en fonction du pretraitement effectue
% Data preprocessing suffix
preproc = struct;
preproc.LPfc    = 25;   % Low-pass frequency
preproc.resfs   = 200;   % New sample frequency
preproc.crop    = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)

dataopt = [];
dataopt.datatyp = 'SourceM';
dataopt.preproc = preproc;
% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

% List of subject's directories
spaths = make_pathlist(pso(1:isubj,:));

if ~isempty(vsdo)
    spaths = spaths(vsdo);
end

if ~isempty(grp_name)
    grp_name = ['_',  grp_name];
end

strproc = preproc_suffix(preproc);

sourcename = ['SourceModel*',strproc,'*.mat'];

GAdir = make_dir([p0,filesep,'GA_Source', strproc], 0);

%___
% Grand average of sources

fprintf('\n\n\t-------\nSource grand AVERAGE\n\t-------\n')

disp(' '), disp('Load template_grid variable')
template_grid = loadvar(template_grid,'template_grid*');

% Define all source data path according to subjpaths and pso
if isubj < length(pso(:,1))
    % Search source mat path architecture - from subject directory
    psm = pso(isubj+1:end,:);
else
    % Source matlab file is already in subject's directory
    psm = [];
end

% Paths list of all MAT files
[sopaths, subjlist] = meg_GA_prep_datapath(spaths, psm, dataopt);
Nsubj = length(subjlist);

% Store all source data in the same structure
storedSo = meg_GA_store_sources(sopaths, template_grid);
fcond = fieldnames(storedSo);

Ndip = length(storedSo.(fcond{1}){1}.inside);

if doGA==1
    sourceGA = struct;
    time = storedSo.(fcond{1}){1}.time;
    for c = 1 : length(fcond)
        % Default cfg : cfg.parameter = 'pow'; and cfg.keepindividual =
        % 'no';
        Socell = storedSo.(fcond{c});
        sourceGA.(fcond{c}) = ft_sourcegrandaverage([],Socell{:});
        
        % Adding z parameter
        % And deleting pow & cfg.previous fields
        
        allz = zeros(Nsubj, Ndip, length(time));
        allm = zeros(Nsubj, Ndip, length(time));
        for s = 1: Nsubj
            allz(s,:,:) = cell2mat(Socell{s}.avg.z);
            allm(s,:,:) = cell2mat(Socell{s}.avg.mom);
        end
        
        sourceGA.(fcond{c}).z = allz; 
        sourceGA.(fcond{c}).mom = allm; 
        
        sourceGA.(fcond{c}).time = time;
        sourceGA.(fcond{c}).subj = subjlist;
        
        sourceGA.(fcond{c}).cfg.previous = [];
        sourceGA.(fcond{c}) = rmfield(sourceGA.(fcond{c}),'pow');
    end

    save([GAdir,filesep,'sourceGA',grp_name,strproc],'sourceGA')
end    

    
    
    


        
