function [datapath, dataname] = find_datamat(dpath, dataopt)
% Special function to find MAT data file with the specific name :
%                  [datatype_prefix,'*',processing_suffix,'*.mat']
%
% dataopt.datatyp : string of the prefix data name to find
%
% dataopt.preproc : parameters structure of processing done on data (and
% that should appear on the matrix name string)
% datopt.preproc.HPfc  : High-pass frequency (Hz)
% datopt.preproc.LPfc : Low-pass frequency (Hz)
% datopt.preproc.resfs : New sample frequency (Hz)
% datopt.preproc.crop : [t_prestim t_postim]in s (stim : t=0s, t_prestim is negative)
%
% Exemple : searching of the source*.mat data matrix obtained from data
% previously band-pass filtered between 1 and 25 Hz and resample at 200 Hz
% datopt = [];
% datopt.datatyp = 'source';
% datopt.preproc.HPfc    = 1;     % (Hz)
% datopt.preproc.LPfc    = 25;    % (Hz)
% datopt.preproc.resfs   = 200;   % (Hz)
% datopt.preproc.crop    = [0 0]; % (s)

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

% Default parameters
dopt_def = struct('datatyp', {'*'},...
                    'preproc',[]);
                
if nargin <2 || isempty(dataopt)==1
    dataopt = dopt_def;
else
    dataopt = check_opt(dataopt,dopt_def);
end

if ~iscell(dataopt.datatyp)
    dataopt.datatyp = {dataopt.datatyp};
end

% Data type (prefix of the data name to find)
prefix = dataopt.datatyp;

% Processing parameters to find in data name
possproc = {'HP', 'LP', 'Res', 'Crop'};
Np = length(possproc);

% Return preprocessing string according to dataopt.preproc but in an
% arbitrary order
strproc = preproc_suffix(dataopt.preproc);
% We have to check for each preprocessing string units separately
strprocel = strsplitt(strproc, '_');
% Return {''} if no preproc suffix retruned by preproc_suffix

% Order the seeking preprocessing according to possproc
Npc = length(strprocel);
searchproc = cell(1, Npc);
if ~isempty(strprocel{1})   
    cp = char(possproc');
    cp = cellstr(cp(:,1:2));
    for i = 1 : Npc
        searchproc(strcmp(strprocel{i}(1:2), cp)) = strprocel(i);
    end
else
    searchproc = [];
end


% If we are looking for data with preprocessing parameters, all the data 
% name matching with the preprocessing part are kept
% Then, prefix indicating datatyp is considere to find the matrix

% Stop as soon as a matrix has been found with the good prefix
% Part of data matrix name to find
namat = ['*' , strprocel{1}, '*.mat'];
fprintf('\n\nSearch of data matrix : %s\n\n', namat);


dpp = dir(fullfile(dpath, namat));
dfil = [];
if ~isempty(dpp)
    % Among theses matrix, we are looking for the matrix with prefix
    % matching with one prefix cell string (by the order of priority)    
    for ip = 1 : length(prefix)
        namat = [prefix{ip}, '*', strprocel{1}, '*.mat'];
        dfp = dir(fullfile(dpath, namat));
        if ~isempty(dfp)
            dfil = dfp;
            break
        end   
    end
end
            
if ~isempty(dfil)
    % Several mat name found - match the other processing parameters
    Nfil = length(dfil);
    if Nfil > 1 && ~isempty(searchproc)
        vfil = 1 : Nfil;
        % Several data matrix found : thoses with and without
        % pre-processing (case where strproc=[]) 
        for k = 1 : Nfil
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
    [datapath, dataname] = dirlate(dpath, namat);
    fprintf('Found :\n%s', dataname)
    fprintf('--------\n')
else
    disp(' ')
    disp('!!! MAT data file not found with the specified preprocessing')
    disp('options')
    datapath = [];
    dataname = [];
end
 
%______
% Check for input options
function dftopt = check_opt(dftopt, dftopt_def)

    fopt = fieldnames(dftopt_def);
    for i = 1 : length(fopt)
        if ~isfield(dftopt, fopt{i}) || isempty(dftopt.(fopt{i}))
            dftopt.(fopt{i}) = dftopt_def.(fopt{i});
        end     
    end