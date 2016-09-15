function Csplit = strsplitt(Str, sspl)


if ~ischar(Str) || ~ischar(sspl)
    if ~isempty(Str) && ~isempty(sspl)
        disp('!!!!')
        disp('Bad variable type')
        disp('First argument must be a character array')
        disp('And second agument a char or character array...')
        disp('--- Return empty char')
        Csplit = '';
    else
        disp('Empty arguments')
        if isempty(sspl) && ~isempty(Str)
            disp('Splitting pattern is empty')
            disp('--- Return original char array')
            Csplit = {Str};
        else
            disp('Nothing to split as first argument is empty')
            disp('--- Return empty char')
            Csplit = '';
        end
    end
    
    
else
    itb = strfind(Str,sspl);
    if isempty(itb)
        Csplit = {Str};
    else
        % sspl en premier caractere
        if itb(1) == 1
            if length(itb)==1
                Csplit = {Str(2:end)};
                itb = [];
            else
                Str = Str(2:end); 
                itb = itb(2:end)-1;
            end
        else
            if itb(end)==length(Str)
            % sspl en dernier caractere
                if length(itb)==1
                    Csplit = {Str(1:end-1)};
                    itb = [];
                else
                    Str = Str(1:end-1);
                    itb = itb(1:end-1);
                end
            end
        end
        % sspl entre les caracteres : on decoupe
        if ~isempty(itb)
            if strcmp(sspl,'.')
                sspl = '\.';
            end
            Csplit = regexp(Str,sspl,'split');
        end
    end
end
    