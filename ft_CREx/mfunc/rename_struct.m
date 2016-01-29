function Sren = rename_struct(Sini, Cstr_ini, Cstr_fin)
% Rename field names of the multi-levels structure Sini
% For any k (for k = 1 : length(Cstr_ini)), replace all occurences of 
% Cstr_ini{k} by its corresponding string, Cstr_fin{k}.
% Exemple :
% Sini is a structure with these different fields :
% Sini.CAC.Morpho.time
%                .avgROI
%                .Morpho_Seman
%         .Ortho.time
%               .avgROI
%               .Ortho_Seman
% Sini.DYS.Morpho.time
%                .avgROI
%                .Seman
%          ...
% The occurrences to replace are defined in this cellule of string :
%   Cstr_ini = {'Morpho','Ortho','Seman'};
% The corresponding substitution string  :
%   Cstr_fin = {'Morphological', 'Orthographic', 'Semantic'}; 
% Sren = rename_struct(Sini, Cstr_ini, Cstr_fin) changes the field names as :
% Sren.CAC.Morphological.time
%                       .avgROI
%                       .Morphological_Semantic
%         .Orthographic.time
%                      .avgROI
%                      .Orthographic_Semantic
% Sren.DYS.Morphological.time
%                       .avgROI
%                       .Semantic
%          ...

if ischar(Cstr_ini)
    Cstr_ini = {Cstr_ini};
end

if ischar(Cstr_fin)
    Cstr_fin = {Cstr_fin};
end

Nc = length(Cstr_ini);

if isstruct(Sini)
    Snames = fieldnames(Sini);
    % Could be unique condition name or combinaison (structure of results
    % from statistical analysis for example)
    % Replace any occurence of the fieldnames at this level
    for n = 1 : length(Snames)
        fname = Snames{n};
        for k = 1 : Nc
            si = Cstr_ini{k};
            sf = Cstr_fin{k};
            iocc = find_strocc(fname, si, sf);    
            if ~isempty(iocc)
                if length(si) < length(sf)
                    newname = regexprep(fname, ['(?!\',sf,')\',si], sf);
                else
                    newname = regexprep(fname, si, sf);
                end
                % The name has been change
                if ~strcmp(fname, newname)
                    if sum(strcmp(newname, Snames))==0
                        Sini.(newname) = Sini.(fname);
                        Sini = rmfield(Sini, fname);
                        fprintf('Field name %s replace by %s\n', fname, newname);
                        fname = newname;
                    else
                        fprintf('New field %s already exists\n', newname);
                    end
                end
            end
        end
        Sini.(fname) = rename_struct(Sini.(fname), Cstr_ini, Cstr_fin);
    end
 
end
Sren = Sini;
 
function iocc = find_strocc(fname, strini, strfin)        
    iocc = strfind(fname, strini); 
    if ~isempty(iocc)
        iocc_fin = strfind(fname, strfin);
        if ~isempty(iocc_fin)
            % Shouldn't be the same occurrence as Cstr_fin{k}
            [~, ia] = setxor(iocc, iocc_fin);
            iocc = iocc(ia);
        end
    end