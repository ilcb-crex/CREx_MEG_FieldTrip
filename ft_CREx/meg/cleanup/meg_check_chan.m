function CHANstr = meg_check_chan(badopt,CHANstr)
% MEG_CHECK_CHAN
%
% -> Visualiser les cannaux MEG avec AnyWave ou ft_databrowser
% -> Specifier les cannaux a oter
%
% CHANstr = meg_check_chan(badopt,CHANstr)
%
% badopt.disptool : structure definissant la methode utilisee pour visualiser les 
% donnees afin de reperer les voies bruitees a supprimer
%   badopt.disptool.name : nom de la methode
%       - 'anywave' : lancement de AnyWave.exe. Le chemin d'acces au 
%          logiciel peut etre renseigne dans le champ path.
%       - 'ftbrowser' : utilisation de la fonction ft_databrowser
%       - 'none' : pas de visualisation (les voies a oter sont demandees
%          directement) [DEFAULT]
%   badopt.disptool.toolpath : chemin d'acces au logiciel de visualisation, utile
%       pour la methode 'anywave'. Par defaut, disptool.toolpath =
%       'C:\Program Files\AnyWave\AnyWave.exe'
%   badopt.datatyp : type de donnees a visualiser
%   badopt.dirpath : chemin d'acces au dossier contenant les donnees (optionnel 
%       pour la methode 'anywave' mais utile pour 'ftbrowser'). 
%       Ex. : badopt.dirpath='C:\Users\MEGData\S05\run4'
%
% CHANstr : cellule contenant les voies a oter 
%   - CHANstr en input : ex. {'A25','A121','A203'} sera affiche sur la 
%	   fenetre de commande pour verification et formatte pour l'utilisation 
%      par fieldtrip (valeur par defaut : vide)
%   - CHANstr en output est de la forme : 
%     CHANstr = {'MEG' '-A121' '-A25' '-A203'}
%     Cette cellule est utilisee par les fonctions fieltrip (champ "channel" 
%     des structures de config)
%
%________________________________________________________________________
% $ 16/09/2013 -- CREx BLRI -- $
%
disp(' ')
disp(' ------------------')
disp(' Select BAD channel ')
disp(' ------------------')
disp(' ')

% ________
% Check input

% Si aucun outil de visualisation renseigne
% les donnees ne sont pas visualisees
if nargin<1 
    disptool.name='none';
else
    disptool = badopt.disptool;
end

if ~isempty(disptool) && ~isstruct(disptool)
    if ischar(disptool) && ~isempty(strfind('anywave ftbrowser none',lower(disptool)))
        disptool.name=disptool;
    else
        disptool.whatisit=disptool;
    end
end

if isempty(disptool) || ~isfield(disptool,'name')
    fprintf('\nTool to use for checking channels quality :')
    disp('AnyWave    -> 1')
    disp('FT browser -> 2')
    disp('None       -> 3')
    num=input(' Number     : ');
    switch num
        case 1,    disptool.name='anywave';
        case 2,    disptool.name='ftbrowser';
        otherwise, disptool.name='none';
    end
end

% Define data type & data directory path
if ~isfield(badopt,'datatyp') || isempty(badopt.datatyp) 
    datatyp = '4d';
else
    datatyp = badopt.datatyp;
end

if ~isfield(badopt,'dirpath') || ~exist(badopt.dirpath,'dir')
    dirpath = [];
else
    if exist(badopt.dirpath,'file')==2  % Path of a file, not of a directory
        [dirpath,dat,ext] = fileparts(badopt.dirpath);
        if strcmpi(datatyp,'4d')==0 && strcmp(ext,'.mat')==1
            datatyp = dat;
        end
    else
        dirpath = badopt.dirpath;
    end
end

% Identify data to look for
if ~isempty(dirpath)
    if strcmpi(datatyp,'4d')==0
        datapath = dirlate(dirpath,[datatyp,'*.mat']); 
    else
        datapath = filepath4d(dirpath);
    end
else
    datapath = [];
end


if nargin<2
    CHANstr=[];
end

% ________
% Set specific variable for each method

anylaunch=0;
ftdisp=0;
nodisp=0;
switch lower(disptool.name)
    case 'anywave'
        anylaunch=1;
        if ~isfield(disptool,'toolpath')
            anypath='C:\Program Files\AnyWave\AnyWave.exe';
        else
            anypath=disptool.toolpath;
        end
    case 'ftbrowser'
        ftdisp=1;
    case 'none'
        nodisp=1;
end

% ---
% DISPTOOL.NAME = ANYWAVE
% Running of AnyWave to select BAD channels

if anylaunch 
    % Recherche de l'executable AnyWave.exe
    if isempty(strfind(anypath,'AnyWave.exe'))
        if exist(anypath,'dir') 
            anypath=fullfile(anypath,'AnyWave.exe');
        end
    end
        
    if exist(anypath,'file')
        oklaunch=1;
    else
        % Find AnyWave.exe
        [g,p,oklaunch] = uigetfile('C:\AnyWave.exe','Find & Select AnyWave.exe file');
        if oklaunch
            anypath = [p,g];
        else
            disp('So AnyWave isn''t AnyWhere...')
            anylaunch = 0;
        end
    end
end
% Identify and specify the bad channels
% AnyWave launch for display
if anylaunch && oklaunch
    disp(' ')
    disp('Check for MEG bad channels...')
    fprintf('\n---------------\nAnyWave running\n---------------\n');
    if ~isempty(datapath)
        disp(['Data path = ',datapath])
    end
    fprintf('\nSelect data file for display (Fichier/Ouvrir)\n') 
    system([anypath '&']);

    % Ask for bad channel which will be put in CHANstr variable 
    disp(' ')
    disp('Keep all channel  -> 1')
    disp('Remove channel(s) -> 2')
    badfound=input('                  -> ');
    if badfound==2
        CHANstr = enter_badchan;
    else
        CHANstr = {'MEG'};
    end
end
% ---

% ---
% DISPTOOL.NAME = FTBROWSER
% Running ft_databrowser function
if ftdisp
    if isempty(datapath) 
         % Find data file
        [g,p,ftlaunch] = uigetfile('*','Find & Select data file');
        if ftlaunch
            datapath = [p,g];
        else
            disp('So NO data available...')
        end
    else
        ftlaunch = 1;
    end
end
if ftdisp && ftlaunch
    disp(' ')
    disp('Check for MEG bad channels...')
    fprintf('\n---------------\nft_databrowser running\n---------------\n');
    disp(['Data path = ',datapath])
    disp(' ')
    % Data bloc extraction
    if strcmpi(datatyp,'4d')==1
        rawData = meg_exctract4d(datapath);
    else
        rawData = loadvar(datapath,'*Data*');
    end
    if ~isempty(rawData)
        try
            % Data visualisation 
            cfg = [];
            cfg.viewmode = 'vertical';
            cfg.channel  = 1:20; % 20 channels per figure window
            cfg.ploteventlabels='colorvalue';
            if rawData.time{1}(end) > 300
                cfg.blocksize = 300;
            else
                cfg.blocksize = rawData.time{1}(end);
            end
            ft_databrowser(cfg,rawData);
        catch
            disp('Impossible to use ft_databrowser for visualisation')
        end
        % Manually input of bad channel to specify in CHANstr variable
        disp(' ')
        disp('Keep all channel  -> 1')
        disp('Remove channel(s) -> 2')
        badfound=input('                  -> ');
        if badfound==2
            CHANstr=enter_badchan;
        else
            CHANstr={'MEG'};
        end
    end
end
% ---

% ---
% DISPTOOL.NAME = NONE
% Check already specified channels and correct it if necessary
if nodisp
    disp(' '), disp('Enter BAD channel(s)')
    disp(' -----------')
    disp(['Data path = ',datapath])

    disp(' '), disp(' -----------')
    if ~isempty(CHANstr)
        if ~iscell(CHANstr)
            CHANstr={CHANstr};
        end
        if ~strcmp(CHANstr{1},'MEG')
            newCHAN=cell(1,length(CHANstr)+1);
            newCHAN{1}='MEG';
            newCHAN(2:end)=CHANstr;
            CHANstr=newCHAN;
        end
        fprintf('\nBad channels indicated in CHANstr variable : ')
        for c=2:length(CHANstr)
            if ~strcmp(CHANstr{c}(1),'-')
                CHANstr{c}=['-' CHANstr{c}];
            end
            disp(CHANstr{c}(2:end))
        end
        disp(' ')
        disp('Keep it   -> 1')
        disp('Modify it -> 2')
        modify=input('                  -> ');       
        if modify==2
            CHANstr=enter_badchan;
        end
    else
        disp(' ')
        disp('Keep all channel  -> 1')
        disp('Remove channel(s) -> 2')
        badfound=input('                  -> ');
        if badfound==2
            resp = 2;
            while resp==2
                CHANstr = enter_badchan;
                disp(' '), disp('----')
                disp('Channels selection :')
                disp(CHANstr(2:end)), disp(' ')
                disp('Confirm it                -> 1')
                disp('Ooops enter a new one     -> 2')
                disp('Finally keep all channels -> 3')
                resp = input('                          -> ');
                disp(' '), disp('----'), disp(' ')
                if resp == 3
                    CHANstr = {'MEG'};
                end
            end
        else
            CHANstr={'MEG'};
        end
    end
end

% Function to enter bad channel on the command window
function CHANstr = enter_badchan
    CHANstr = cell(1,20);
    CHANstr{1} = 'MEG';
    goon = 1;
    n = 2;
    fprintf('\nEnter BAD channel name (ex. : A111, a111 or 111 only)\n\t-------------\n\n'); 
    while goon
        ch = input(['Bad channel n°',num2str(n-1),' : '],'s');
        if ch(1)~='A'
            if ch(1)=='a'
                ch(1)='A';
            else
                if ~isempty(strfind('123456789',ch(1)))
                    ch = ['A',ch]; %#ok
                end
            end
        end
        CHANstr{n} = ['-',ch];
        disp(' ')
        disp('Enter a new bad channel (1)')
        goon=input('                or stop (0) : ');
        disp(' ')
        n = n+1;
    end
    CHANstr = CHANstr(1:n-1);




