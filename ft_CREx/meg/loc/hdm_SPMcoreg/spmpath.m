function okdone = spmpath(opt)

disp(' ')
disp('--- ')
disp('Search of spm8 directory in toolbox directory or in current path')
disp('---')

spath = {toolboxdir('') ; pwd};
spmdir = {'spm8','SPM8','spm','SPM','spm*','SPM*'};
ok = false;
for d = 1:length(spath)
    for n = 1:length(spmdir)
        if isempty(strfind(spmdir{n},'*'))
            % We are looking for a directory with name spmdir{n}
            if exist([spath{d}, filesep, spmdir{n}],'dir')==7
                pSPM = [spath{d}, filesep, spmdir{n}];
                ok = true;
                break;
            end
        else
            % Check list of matching directory names
            isd = dir([spath{d}, filesep, spmdir{n}]);
            if ~isempty(isd)
                pSPM = [spath{d}, filesep, isd(1).name];
                ok = true;
                break;
            end
        end
    end
    if ok
        disp(['Find : ',pSPM])
        break;
    end
end

if ok
    if strcmp(opt,'add')
        disp('Adding SPM directory to Matlab paths')
        addpath(pSPM)    
        addpath(fullfile(pSPM,'toolbox','Seg'))
        addpath(fullfile(pSPM,'toolbox','DARTEL'))
    elseif strcmp(opt,'rm')
        disp('Removing SPM toolbox paths')
        % Search all spm directory
        allp = strsplitt(path,';')';
        ic = strfind(allp, pSPM);
        for j = 1:length(ic)
            if ~isempty(ic{j})
                rmpath(allp{j})
            end
        end
        ft_defaults
    end
else
    disp('!!!')
    disp('SPM toolbox directory not found...')
    disp('Contact after-sales service... or place')
    disp('spm8 directory in matlab toolbox directory')
    disp('And restart the program...')
end
    
if nargout > 0
    okdone = ok;
end

disp(' ')