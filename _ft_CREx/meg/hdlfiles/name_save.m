function namsav = name_save(name)
% Formatage du nom d'un fichier avant sa sauvegarde
% Les tirets, points et espaces sont supprimes du nom s'ils sont presents.
namsav=name;
is=strfind(namsav,'-');
if ~isempty(is)
    for j=1:length(is)
        if j<length(namsav) && ~isempty(strfind('1234567890',namsav(is(j)+1)))
            namsav(is(j))='m';
        else
            namsav(is(j))='_';
        end
    end
end
namsav(namsav=='.')='p';
namsav(namsav==' ')='';