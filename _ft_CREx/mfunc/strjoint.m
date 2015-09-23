function Cjstr = strjoint(Cstr,jstr)

if nargin < 2
    jstr = '';
end
if ischar(Cstr)
    if length(Cstr(:,1))>1
        Cstr=cellstr(Cstr);
    else
        Cstr={Cst};
    end
end

if ~ischar(Cstr{1}(1)) || ~ischar(jstr)
    disp('!!!!')
    disp('STRJOINT FAILED')
    disp('First argument must be a cell of sting or a character array')
    disp('And second agument a character array...')
    Cjstr = '';
else
    Cjstr = Cstr{1};
    for i=2:length(Cstr)
        Cjstr = [Cjstr,jstr,Cstr{i}];  %#ok
    end
end
    