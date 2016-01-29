function [pathfile, namefile] = dirlate(path, nam)
%
% [pathfile, namefile] = DIRLATE(path, nam)
%
% Look for data file in path directory which name is matching with the 
% "nam" string. If several matching data file are found, the most recent 
% one is return.
% ex :  path = C:/MEGaWork/Subject1
%       nam = 'avgTrials*.mat'
% All matching name of file 'avgTrials*.mat' will be found by the matlab
% function "dir". Then, the most recent one will be chosen.

dfile = dir([path,filesep,nam]);
if ~isempty(dfile)
    if length(dfile)>1
        fprintf('\n--------\nWarning : more than one file')
        disp(['" ',nam,' " found in :'])
        disp(path)
        disp(' ')
        dat = cell2mat({dfile.datenum});
        dfile = dfile(dat==max(dat));
        fprintf('Most recent data will be use :\n%s', dfile.name)

        fprintf('--------\n')
    end
    namefile = dfile.name;
    pathfile = [path,filesep,dfile.name];
else
    fprintf('\n\n--- Data file not found ---\n\n');
    namefile = [];
    pathfile = [];
end