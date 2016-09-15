% ________
% Parameters to adjust

%--- Architecture indiquant l'accès aux donnees ERF
p0 = 'H:\bapa_mseeg';
perf = {{p0} , 0
        {'S'}, 1
        {'MEG'}, 0 };

%--- Vecteur des indices des donnees des sujets a traiter selon pso
% vsdo = [] : tous les sujets trouves a partir de l'architecture pso
vsdo = []; 

%--- Nom du groupe de donnees
grp_name = 'mseeg';

doGA = 1;

%--- Type de donnees recherchees en fonction du pretraitement effectue
datopt = [];
datopt.datatyp = 'avgTrials';
datopt.preproc.HPfc    = 1;     % (Hz)
datopt.preproc.LPfc    = 25;    % (Hz)
datopt.preproc.resfs   = 200;   % (Hz)
datopt.preproc.crop    = [0 0]; % (s)

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

% List of subject's directories
spaths = make_pathlist(perf(1:isubj,:));

if ~isempty(vsdo)
    spaths = spaths(vsdo);
end

if ~isempty(grp_name)
    grp_name = ['_',  grp_name];
end

strproc = preproc_suffix(datopt.preproc);

GAdir = make_dir([p0,filesep,'GA_ERF', grp_name, strproc],1);

%___
% Grand average of sources
if doGA==1
    fprintf('\n\n\t-------\nERF grand AVERAGE\n\t-------\n')
    
    % Define all source data path according to subjpaths and pso
    if isubj < length(perf(:,1))
        % Search source mat path architecture - from subject directory
        psm = perf(isubj+1:end,:);
    else
        % Source matlab file is already in subject's directory
        psm = [];
    end
    
    % Paths list of all MAT files
    [avgpaths, subjlist] = meg_GA_prep_datapath(spaths, psm, datopt);
    Nsubj = length(subjlist);
    
    % Store all source data in the same structure
    storedERF = meg_GA_store_ERF(avgpaths);
    fcond = fieldnames(storedERF);
    
    cfg = [ ];
    cfg.keepindividual = 'yes' ;
    cfg.method         = 'across'; %(default)    
    
    grad = storedERF.(fcond{1}){1}.grad;
    avgGA = struct;
    avgGAfull = struct;
    for c = 1 : length(fcond) 
        % Default cfg : cfg.parameter = 'pow'; and cfg.keepindividual =
        % 'no';
        Avgcell = storedERF.(fcond{c});
        avgGA.(fcond{c}) = ft_timelockgrandaverage([], Avgcell{:});
        avgGA.(fcond{c}).subj = subjlist;
        
        avgGAfull.(fcond{c}) = avgGA.(fcond{c});
        avg = ft_timelockgrandaverage(cfg, Avgcell{:});
        avgGAfull.(fcond{c}).avgsubj = avg.individual;
        avgGAfull.(fcond{c}).grad = grad;
        
        avgGA.(fcond{c}) = rmfield(avgGA.(fcond{c}), {'var','dof'});
        avgGA.(fcond{c}).grad = grad;
    end

    save([GAdir,filesep,'avgGA',grp_name,strproc],'avgGA')
    save([GAdir,filesep,'avgGAfull',grp_name,strproc],'avgGAfull')
end    

    
    
    


        
