function [pathfile, namefile] = dirlate(path,nam)
dfile = dir([path,filesep,nam]);
if ~isempty(dfile)
    if length(dfile)>1
        disp(' ')
        disp('--------')
        disp('Warning : more than one file')
        disp(['" ',nam,' " found in :'])
        disp(path)
        disp(' ')
        dat=cell2mat({dfile.datenum});
        dfile=dfile(dat==max(dat));
        disp('Most recent data will be use :')
        disp([dfile.name])
        disp('--------'), disp(' ')
    end
    namefile = dfile.name;
    pathfile = [path,filesep,dfile.name];
else
    namefile = [];
    pathfile = [];
end