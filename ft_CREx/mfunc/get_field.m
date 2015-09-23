function val = get_field(S, fname, typ)
% Find value of a field in a complexe structure - with embedded structures
% S : the structure
% fname : name of the field from which we search the value
% typ : expected variable type 
%disp(['Search for value in fieldname ',fname])

if nargin == 3 && ~isempty(typ)
    typ = check_typ(typ);
    if ~isempty(typ)
        classcheck = true;
    else
        classcheck = false;
    end
else
    typ = [];
    classcheck = false;
end


val = [];
if isstruct(S)
    Snames = fieldnames(S);
    vstr = strcmp(Snames, fname);
    if sum(vstr)==1
        vali = S.(fname);
        if classcheck
            if isa(vali,typ) == 1
                disp(['--- Value found in field "',fname,'" with class ',typ])
                val = vali;
            else
                disp('One fieldname match but not data type')
                disp(['Found type : ',class(vali)])
            end
        else
            val = vali;
        end
    end
    if isempty(val)
        for n = 1:length(Snames)
            % disp(['Check inside : ',Snames{n}]) 
            val = get_field(S.(Snames{n}), fname, typ);
            if ~isempty(val)
                return;
            end
        end 
    end
end

function typ = check_typ(typ)

typ = lower(typ);
alltyp = {'single','double','int8','int16','int32','int64','uint8',...
    'uint16','uint32','uint64','numeric','float','integer',...
    'logical','char','struct','cell','function_handle'};
if sum(strcmp(alltyp, typ))==0
    disp('Unknown data type')
    if sum(strcmp(alltyp(1:13), typ(1:3))) >= 1
        typ = 'numeric';
        disp('Set type to numeric')
    else
        typ = [];
    end
end
            
        
    