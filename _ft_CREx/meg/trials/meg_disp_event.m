function cfg_rawData = meg_disp_event(datapath, savpath)
% MEG_DISP_EVENT(DATAPATH,SAVPATH)
%
% Affichage des evenements presents dans les donnees MEG brutes
%
%   - Retourne la liste de l'ensemble des evenements  
%     presents dans les donnees brutes
%   - Sauvegarde la liste dans un fichier txt
% 
% datapath : nom du chemin d'acces aux donnees
%      ex. : datapath = 'C:\Users\MEG\S05\Run4\c,rfhp0.1Hz';
%
% savpath  : nom du fichier de sauvegarde au format TXT 
%      ex. : - savpath = 'C:\Users\MEG\S05\Run4\list_S05_Run4.txt';
%              => list_S05_Run4.txt sera sauve dans le repertoire
%                 'C:\Users\MEG\S05\Run4\'
%            - savpath = 'list_S05_Run4.txt' 
%              => fichier txt sauve dans le repertoire courant (pwd)
%            - savpath = 'C:\Users\MEG\S05\Run4\' 
%              => un fichier nomme par defaut 'all_events_list.txt' 
%                 sauve dans 'C:\Users\MEG\S05\Run4\'
%
%            Si le fichier texte existe deja, la liste des evenements 
%            de la donnee MEG analysee est ajoutee a la precedente.
%
%            Si savpath est absent ou vide ([]), l'affichage de la
%            liste sur la fenetre de commande n'est pas sauvegardee.
%
% cfg_rawData : la structure retournee par la fonction FieldTrip
% ft_definetrial : cfg_rawData = ft_definetrial(cfg); avec les parametres
% cfg.dataset = datapath; et cfg.trialdef.triallength = Inf; 
% Soit les infos sur l'ensemble des evenements contenus dans le jeu de
% donnees brutes.
% 
% Cette fonction utilise les fonctions Fieldtrip : 
% ft_read_header, ft_definetrial
%________________________________________________________________________
% $ 23/09/2013 -- CREx BLRI -- $
%

% ________
% Check input

if nargin~=2 || isempty(savpath)
    sav=0;
else
    namsavdef='All_events_list.txt';
    if isempty(strfind(savpath,filesep)) % savpath est un nom seul et non un chemin
        savpath=[pwd,filesep,savpath];   % Chemin par defaut : pwd
    end
    if isdir(savpath) % savpath est le chemin d'un dossier et non du fichier txt a sauver
        savpath=fullfile(savpath,namsavdef);
        sav=1;
    else
        if ~strcmp(savpath(end-3:end),'.txt')
            dos =fileparts(savpath);
            if isdir(dos)
                savpath=fullfile(dos,namsavdef);
                sav=1;
            else
                try
                    mkdir(dos)
                    sav=1;
                catch
                    sav=0;
                    disp(['Path of txt file to save : ',savpath]) 
                    disp('is BAD...')
                end
            end
        else
            sav=1;
            if ~isempty(dir(savpath))
                disp(' ')
                disp(['File ',savpath])
                disp('already present. List of events will be')
                disp('appended to the file.'), disp(' ')
            end
        end
    end
end


% ________
% Read header by FieldTrip function

fprintf('\nRead event(s) in :\n%s\n',datapath);
fprintf('\n--------\nHeader informations\n--------\n');
fprintf('Reading of header by ft_read_header\n\n') 
[fe,dur,nbchan]=deal([]);
try
    hdr=ft_read_header(datapath);
    fnam=fieldnames(hdr);
    if ~isempty(strcmp('Fs',fnam)) && ~isempty(strcmp('nSamples',fnam))
        fe=hdr.Fs;
        npoint=hdr.nSamples;
        dur=(npoint-1)./fe;
    end
    if ~isempty(strcmp('nChans',fnam))
        nbchan=hdr.nChans;
    end   
catch
    disp('OMG Header is not readable...')
end

% ________
% Read events by FieldTrip function

fprintf('\n--------\nEvents list\n--------\n');
fprintf('Reading of events by ft_definetrial\n\n') 
cfg = [];
cfg.dataset = datapath;
cfg.trialfun = 'ft_trialfun_general'; % Default (avoid warning message)
cfg.trialdef.triallength = Inf; % bloc pris en entier
try
    cfg_rawData = ft_definetrial(cfg); 
    if isempty(cfg_rawData.event)
        ok=0;
        msg = 'No one event found in dataset';
        S = struct('event',struct('nothing',[]));
    else
        ok=1;
        S=cfg_rawData.event;
        % Ajout de la valeur de la frequence d'echantillonnage 
        cfg_rawData.fsample = fe;       
    end
catch
    ok=0;
    msg = 'Extraction of event impossible from ft_definetrial...';
    S = struct('event',struct('nothing',[]));
end

% ________
% Display data informations & events 

fnam=fieldnames(S);
bigC=cell(length(S),size(fnam,1));
for nf=1:size(fnam,1)
    bigC(:,nf)={S.(fnam{nf})};
end
if sav
    diary(savpath)
end
fprintf('\n\t\t--------\n\t\tList of events\n\t\t--------\n\n');
fprintf('\nData path : %s\n\n',datapath);
disp(['Number of channels : ',num2str(nbchan)])
disp(['Recording duration (s) : ',num2str(dur)])
disp(['Sample frequency (Hz) : ',num2str(fe)])
disp(' ')
disp('      --------------------------')
disp(fnam')
disp(' ')
disp(bigC)
disp(' ')
disp('      --------------------------')
disp(' ')
% Count of different kinds of events 
if sum(strcmp('type',fnam)) && sum(strcmp('value',fnam))
    typ=extract_field(S,'type');
    [a,T,c]=unique(typ,'rows'); %#ok
    nbt=length(a(:,1));
    disp([num2str(nbt),' type(s) of event found :'])
    disp(' ')
    val=extract_field(S,'value');
    for j=1:nbt
        if ischar(a(j,:))
            disp(['TYPE n°',num2str(j),' : ',a(j,:),' - Assigned values :'])
        else
            disp(['TYPE n°',num2str(j),' : ',num2str(a(j,:)),' - Assigned values :'])
        end
        disp(' ')
        disp(' Values   (Number)')
        disp(' ')
        
        [g,T,h]=unique(val(c==j)); %#ok
        num=zeros(length(g),1);
        for ig=1:length(g)
            num(ig)=length(find(h==ig));
        end
        disp([repmat('   ',ig,1),num2str(g),repmat('     (',ig,1),num2str(num),repmat(')',ig,1)])
        disp(' ')
    end
    disp(' ')
    disp('      --------------------------')
    disp(' ')
end
if ~ok
    disp(' ')
    disp(['!!!! ',msg,' !!!!'])
end
if sav
    diary off
    disp('__________')
    disp('Informations saved in txt file :')
    disp(savpath), disp(' ') 
end

% ________
% Additionnal function

% Extract & Format values stocked into a field
function val=extract_field(S,field)
    fnam=fieldnames(S);
    if ~isempty(strcmp(field,fnam))
        if ischar(S(1).(field))
            val=char({S.(field)});      % Character array
        elseif isnumeric(S(1).(field))
            val=cell2mat({S.(field)})'; % Matrix of numbers
        else
            val={S.(field)}';           % Cellule of values
        end     
    else
        val=[];
    end
        
        