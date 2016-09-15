function matname = meg_matname(inimat, proc)
% proc is the structure containing processing 
% addsuff)

if nargin == 1
    addsuff = [];
end

% Remove ext .mat 
if length(inimat)>4 && strcmp(inimat(end-3:end),'.mat')
    inimat = inimat(1:end-4);
end

% Define new processing suffix
suffproc = def_newsuff(inimat, addsuff);


% Sparse all processing - combine them if possible


function finsuff = sparse_suff(suff)
% All subprocessing strings
sproc = strsplitt(suff,'_')';
cproc = char(sproc);
% Find all "lp" (low-pass filter processing)
iocc = strcmpi('lp', cellstr(cproc(:,1:2)));

if sum(iocc) > 0
    


function newsuff = def_newsuff(namat, suff)
% Add the new processing suffix information to the previous one
if ~isempty(namat)
    

    
    % All processing informations are normally seprated by "_" character
    % Find the first one, suffix should be the string that follows
    itb = strfind(namat,'_');
    if isempty(itb)
        prevsuff = '';
    else
        prevsuff = namat(itb(1)+1:end);  
    end

    if ~isempty(suff) && ischar(suff)
        % Remove the first separator if presents
        if strcmp(suff(1),'_')
            suff = suff(2:end);
        end
        % And the last
        if strcmp(suff(end),'_')
            suff = suff(1:end-1);
        end
        
        suff(suff=='-') = '_';
        suff(suff=='.') = 'p';
        if ~isempty(prevsuff)
            newsuff = [suff,'_',prevsuff];
        else
            newsuff = suff;
        end
    else
        newsuff = prevsuff;
    end    
else
    if nargin==2 && ~isempty(suff)
        newsuff = suff;
    else
        newsuff = '';
    end
end

function namform = name_form(name)
% Format file name
% If "-" character is found, replaces it by "m" if it is supposed to be
% related to the minus sign (following by number) or by "_" if it is
% supposed to be a separator (not followed by a number)
% "." are replaced by "p" character (as "." should be only used for the
% extension).

namform = name;

% Replace the "-" characters
is = strfind(namform,'-');
Nc = length(namform);
if ~isempty(is)
    % For each occurences
    for j = 1:length(is)
        indc = is(j);
        if indc < Nc && ~isempty(strfind('1234567890', namform(indc + 1)))
            namform(indc) = 'm';
        else
            namform(indc) = '_';
        end
    end
end
% Replace "." characters
namform(namform=='.') = 'p';
% Remove blancks
namform(namform==' ') = '';