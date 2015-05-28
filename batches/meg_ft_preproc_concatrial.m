% Concatenate trials data of several run per subject
% ________
% Parameters to adjust

%--- Architecture indiquant l'accès aux dossiers Sujet
p0='H:\ADys';
psubj=cell(1,2);
psubj{1,1}= {p0};       psubj{1,2}= 0;
psubj{2,1}= {'DYS'};	psubj{2,2}= 0; 
psubj{3,1}= {'S20'};    psubj{3,2}= 1; 

%--- Architecture permettant d'atteindre les dossiers Run a partir des 
% chemins Subject (psubj)
prun = cell(1,2);
prun{1,1}={''};     prun{1,2}= 0;
prun{2,1}={'Run'}; 	prun{2,2}= 1;

%--- Vecteur des indices des donnees des sujets a traiter selon psubj
% vsdo = [] : tous les sujets trouves a partir de l'architecture psubj
vsdo = []; 

%--- Choice of which grad field will be added to concatenated trials data
% set (identified as the index of the run directory for each subject)
grad_numrun = 2; 

%--- Name of the new directory to save concatenated trials
concat_dirnam = 'Run_concat'; 

%--- Flag indicating if preprocessing run directory are to be renamed (as
% prep* (* being original name)
ren_prepdir = 0; 

% _______ GO !

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

%--- List of subject's directory paths
allsubjp = make_pathlist(psubj);

if isempty(vsdo)
    vsdo = 1:length(allsubjp);
end

%--- Concatenated trials for each subjects
for ns = vsdo     
    fprintf('\n\n\t-------\nConcatenate trials for subject :\n\t-------\n')
    fprintf('--> %s\n',allsubjp{ns})
   
    %--- List of Run directories
    prun{1,1} = allsubjp{ns};
    megpth = make_pathlist(prun);
    numrun = zeros(length(megpth),1);
    nr = 1;
    
    %--- Load trials for each run and concatenate it with previous one
    for nrun = 1:length(megpth)
        
        %--- Search trials data as cleanTrials*.mat or allTrials*.mat
        [T, pmeg] = fileparts(megpth{nrun});
        disp(' '), disp(['__Search for MEG trials -> ', pmeg])
        [pTmat,nTmat]=dirlate(megpth{nrun},'cleanTrials*.mat');
        if isempty(pTmat)
            [pTmat,nTmat]=dirlate(megpth{nrun},'allTrials*.mat');
        end
        if ~isempty(pTmat)
            disp(['  Find : ',nTmat]) 
            disp('  Load data')
            SallT = loadvar(pTmat,'*Trial*');
            fn = fieldnames(SallT);
           
            if nr == 1 %--- Initialisation
                SallTapp = SallT;
            else
                % Append trials for each condition, with previously
                % appended trials
                for n = 1:length(fn) 
                    SallTapp.(fn{n}) = ft_appenddata([], SallTapp.(fn{n}), SallT.(fn{n}));
                end
                %--- Keeping grad field of the 2nd run
                if nr == grad_numrun
                     Grad = SallT.(fn{n}).grad; % Le champs grad : positions lors du 2nd run
                end               
            end
            numrun(nr) = nrun;
            nr = nr+1;           
        end
    end
    if nr > 1
        %--- Adding grad field
        for n = 1:length(fn)
            SallTapp.(fn{n}).grad = Grad;
        end
        if ren_prepdir == 1
            numrun = numrun(numrun>0);
            for j=1:length(numrun)
                [path,nam] = fileparts(megpth{numrun(j)});
                movefile(megpth{numrun(j)}, [path, filesep, 'prep', nam])
            end
        else
            path = fileparts(megpth{1});
        end
        
        fdos = make_dir([path, filesep, concat_dirnam]);
        cleanTrials = SallTapp;
        save([fdos,filesep,'cleanTrials_allRun'],'cleanTrials')
        clear SallTapp
    end
end
