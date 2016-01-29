function [trl, event] = ADys_trialfun(cfg)

pretrig = -round(cfg.trialdef.prestim * cfg.fsample);
postrig = round(cfg.trialdef.poststim * cfg.fsample);
                
S = cfg.event;
% Recherche des evenements de type eventyp - supprime les evenements
% "INSIDE_PADART" dans le cas d'une suppression d'artefact par exemple
ctyp = cellstr(char(S.type));

etyp = cfg.trialdef.eventtype;     % Nom des types d'evenements lies au stimuli recherchés
rtyp = cfg.trialdef.resptype; % Nom des types d'evenement lies aux reponses 

S = S(strcmp(ctyp,etyp)==1 | strcmp(ctyp,rtyp)==1);

% Recherche des triggers suivis par une reponse correcte
% Pour bien faire, il aurait fallu rechercher les événements de type
% TRIGGER et ceux de type RESPONSE associés
% Pour faire plus simple, on ne considere que les valeurs des evenements
% sans verifier le type de l'evenement : car elles sont differentes dans la 
% manip ADys selon le type (trigger ou reponse)

val = cell2mat({S.value})';  % Dans val, il y a l'ensemble des triggers et responses
sampl = cell2mat({S.sample})';

trigval =  cfg.trialdef.eventvalue;  % Valeurs des triggers recherchees
rightresp = cfg.trialdef.rightresp;  % Valeurs des reponses correctes

trl = [];
event = [];

% Indices associes aux triggers de valeur(s) trigval
if length(trigval)==1
    itrig = find(val==trigval);
else
    itrig=[];
    for v = 1:length(trigval)
        itp = find(val==trigval(v));
        if ~isempty(itp)
            itrig = [itrig; itp];  %#ok
        end
    end
    itrig = sort(itrig);
end
fprintf('\n\n--------\n')
disp('TRIGGER value(s) :')
disp(num2str(trigval))
fprintf('--------\n')


if ~isempty(itrig)
    disp(['Initial number : ',num2str(length(itrig))])
    % Facon detournee de retrouver les reponses correspondantes pour la
    % manip ADys
    % On elimine les cas où la réponse du sujet est trop tardive
    
    ir = [itrig+1 itrig+2]; % On recherche la reponse proche du trigger (max. 2 evenements apres)
    if length(itrig)>1
        if length(rightresp)>1   % Plusieurs bonnes reponses possibles
            vi = [];
            for r = 1:length(rightresp)
                [indi,T] = find(val(ir)==rightresp(r)); %#ok
                vi = [vi; indi];  %#ok
            end
            if ~isempty(vi)
                vi = sort(vi);
            end
        else
            [vi,T] = find(val(ir)==rightresp); %#ok
        end
    else
        if ~isempty(find(val(ir)==rightresp,1))
            vi = 1;
        else
            vi = [];
        end
    end
    if ~isempty(vi)
        itrigok = itrig(vi); 
        event = S(itrigok);
        trl = [sampl(itrigok)+pretrig, sampl(itrigok)+postrig, repmat(pretrig,length(itrigok),1), val(itrigok)];
        disp(['Followed by correct answer : ',num2str(length(itrigok))])
    end
else
    disp('NO TRIGGER found...')
end
fprintf('\n--------\n')