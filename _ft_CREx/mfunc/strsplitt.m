function Csplit = strsplitt(Str,sspl)


if ~ischar(Str) || ~ischar(sspl)
    disp('!!!!')
    disp('STRSPLITT FAILED')
    disp('First arguments must be a character array')
    disp('And second agument a char or character array...')
    Csplit = '';
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
        end
        % sspl en dernier caractere
        if itb(end)==length(Str)
            if length(itb)==1
                Csplit = {Str(1:end-1)};
                itb = [];
            else
                Str = Str(1:end-1);
                itb = itb(1:end-1);
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
    