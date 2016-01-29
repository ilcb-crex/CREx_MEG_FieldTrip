function meg_cleanup_filt(datapath, filtopt)
% Apply filter on continuous dataset
% 
% datapath : path of directory where dataset is stored (as mat-file)
%
% Parameters of the filtering in filtopt structure :
%
% filtopt.type : kind of filter identified by a string
%       - 'none' : none [default] 
%       - 'hp' : high-pass filter
%       - 'lp' : low-pass filter
%       - 'bp' : band-pass
%       - 'ask' : ask for it, for each dataset
%
% filtopt.fc : cut-off frequency vector in Hz
%       - size 1x2 for band-pass [f_low f_high] (ex. : [0.5 300])
%       - size 1x1 for low or high-pass filter 
%           (ex. filtopt.type = 'lp'; filtopt.fc = 300)
%       [default : [] - no filtering]
%
% filtopt.datatyp : prefix of mat-dataset to load and filter in data directory
%       - 'raw' : search for "rawData*.mat" data files in path directory
%       - 'filt' : search for data previously filtered "filtData*.mat, and
%                   re-apply filter on it
%       - 'clean' : dataset of data already cleaned by ICA components
%       rejection ("cleanData*.mat")
%       - any custom prefix string (search for "[custom]Data*.mat" on path
%       directory)
%       [default : 'raw']
%
% figopt.figflag : draw the first 3 channels continuous data in subplot
%           of before and after filtering to see the global effect
%           1 : draw and save [default] ; 0 : no figure
%
% Save the new filtering data in path directory
%

fprintf('\n\t\t-------\nApply filter on dataset\n\t\t-------\n')
fprintf('\nProcessing of data in :\n%s\n\n', datapath);
defopt = struct('type', 'none', 'fc', [], 'datatyp', 'raw', 'figflag', 1);

if nargin < 2
    filtopt = defopt;
else
    filtopt = check_opt(filtopt, defopt);
end
if strcmp(filtopt.datatyp, 'raw')
    namsav = 'filt';
else
    namsav = filtopt.datatyp;
end
namvar = namsav;
if strcmp(filtopt.datatyp, 'clean')
    namvar = 'cleancomp';
end

[pmat,nmat] = dirlate(datapath,[filtopt.datatyp, 'Data*.mat']);

% Extract data from raw 4D file if rawData*.mat not found 
if isempty(pmat) && strcmp(filtopt.datatyp, 'clean') 
    % Try with 'filtData (assumption : no ICA component were to remove)
    disp('cleanData*.mat not found, search for filtData*.mat')
    [pmat,nmat] = dirlate(datapath,'filtData*.mat');
    namsav = 'filt';
end

if isempty(pmat)
    rawData = meg_extract4d(datapath);
    pmat = '4D file';
else    
    rawData = loadvar(pmat,'*Data*');
end
if ~isempty(rawData)
    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')
    
    % Check for filtopt options
    filtopt = meg_filtopt(filtopt);
    
    % Apply filter
    filtData = meg_filt_dataset(rawData, filtopt);

    fopt = filtopt.type;
    fc = filtopt.fc;
    
    if ~strcmp(fopt,'none') && ~isempty(filtData)
        fstr = [];
        if length(fc) == 1
            fc = repmat(fc, 1, 2);
        end
        % Save the FieldTrip structure of the filtered data
        
        if strcmpi(fopt, 'bp') || strcmpi(fopt, 'hp')
            fstr = [fstr,'_HP', num2str(fc(1)), 'Hz'];
        end
        
        if strcmpi(fopt, 'bp') || strcmpi(fopt, 'lp')
            fstr = ['_LP', num2str(fc(2)),'Hz'];
        end

        fstr(strfind(fstr,'.')) = 'p'; 
        
        newsuff = meg_matsuff(nmat, fstr);
        
        S = struct([namvar, 'Data'], filtData); %#ok
        
        save([datapath,filesep,namsav,'Data_',newsuff],'-struct', 'S')

        fprintf('\n\nFiltering data : %s \nsave in datapath %s\n\n',...
            [namsav,'Data_',newsuff,'.mat'], datapath)
        
        if filtopt.figflag==1
            % Make some figures of the results
            meg_filt_fig(filtData,rawData,filtopt,datapath,1:3) 
            % 1:3 : index of the channels to be plotted
        end
    end
else
    disp('Data not found...')
    disp(' ')
end

%--- Check filtopt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end