function [datapath, dataname] = find_datamat(path, dataopt)
% Special function to find MAT data file with the specific name :
%                  [prefix,'*',procsuffix,'*.mat']
%
% Regarding to the pre-processing done on trial signals before computing
% the model of source localisation, a suffix is adding to the name of the
% results, SourceModel*.mat; for example :
% SourceModel_LP40Hz_Res240Hz_Crop0p2to1.mat
% Here : procsuffix = '_LP40Hz_Res240Hz_Cropm0p2to1';
% (a LP filter with fc=40 Hz has been done, as well as a resampling at 240
% Hz and a re-definition of the trial temporal window from -0.2 to 1 s).
%
% If procsuffix is empty or not specified, the SourceModel*.mat obtained 
% without any special preprocessing of the trials is seeking. This is done
% by selecting the SourceModel*.mat which name doesn't contain the string
% 'LP', 'Res' or 'Crop'.
% If the "raw" results matrix is not found, the most recent one is selecting,
% regardless to its name.
%
% path : directory path where the data matrix is searched
% prefix : the prefix name of the matrix ('avg', 'clean', 'source'...)
% procsuffix : string of processing done as added 
%
% This function uses "dirlate.m" function (which returns the path of the 
% most recent file corresponding to the input name, found inside the search 
% directory.
% Possible pre-processing suffixs 

possproc = {'HP', 'LP', 'Res', 'Crop'};
Np = length(possproc);

prefix = dataopt.datatyp;

% Return preprocessing string according to dataopt.preproc but in an
% arbitrary order
strproc = preproc_suffix(dataopt.preproc);
% We have to check for each preprocessing string units separately
strprocel = strsplitt(strproc, '_');

% Order the seeking preprocessing according to possproc
searchproc = cell(1, Np);
cp = char(possproc');
cp = cellstr(cp(:,1:2));
for i = 1 : length(strprocel)
    searchproc(strcmp(strprocel{i}(1:2), cp)) = strprocel(i);
end


% Part of data matrix name to find
namat = [prefix, '*' , strprocel{1}, '*.mat'];

fprintf('\n\nSearch of data matrix : %s\n\n', namat);

dfil = dir(fullfile(path, namat));
            
if ~isempty(dfil)
    if length(dfil) > 1
        vfil = 1:length(dfil);
        % Several data matrix found : thoses with and without
        % pre-processing (case where strproc=[]) 
        for k = 1:length(dfil)
            matnam = dfil(k).name;
            matsp = strsplitt(matnam, '_');
            matsp = matsp(2:end);
            % Remove '.mat' of the last processing string unit
            matsp{end} = matsp{end}(1:end-4);
            % We exclude data with preprocessing suffix that are found but
            % not specified in dataopt.preproc
            for i = 1 : Np
                sproc = possproc{i};
                % Preprocessing found in data file name
                if ~isempty(strfind(matnam, sproc)) 
                    % But not expected in data matrix we are looking for
                   if (isempty(strfind(strproc, sproc)) || isempty(strproc))
                        vfil(k) = 0;
                   else
                       % Check if the processing parameter values are the
                       % same as expected
                       % Find the corresponding preprocessing string unit
                       if sum(strcmp(searchproc{i}, matsp))==0
                           vfil(k) = 0;
                       end
                   end                           
                end
            end
        end
        vfil = vfil(vfil>0);
        if ~isempty(vfil) && length(vfil)==1
            namat = dfil(vfil).name;
        else
            disp('Data file not found with the specified preprocessing')
            disp('options')
            disp(['Looking for the most recent "', namat,'" file instead...'])
        end
    end
    [datapath, dataname] = dirlate(path, namat);
else
    disp(' ')
    disp('!!! MAT data file not found with the specified preprocessing')
    disp('options')
    datapath = [];
    dataname = [];
end
          