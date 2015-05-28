function okdone = i2mpath(opt)

toolname = 'iso2mesh';
toolp = ['external', filesep, toolname];

disp(' ')
disp('--- ')
disp(['Search of ',toolname,' directory in toolbox directory,'])
disp(['current directory and in fieldtrip',filesep, toolp])
disp('---')

spath = {toolboxdir('') ; pwd};
sdir = {'fieldtrip','fieldtrip*','iso2mesh'};
ok = false;
for d = 1:length(spath)
    for n = 1:length(sdir)
        if isempty(strfind(sdir{n},'*'))
            % We are looking for a directory with name spmdir{n}
            if exist([spath{d}, filesep, sdir{n}],'dir')==7
                pTool = [spath{d}, filesep, sdir{n}];
                if n<3
                    pTool = [pTool, filesep, toolp]; %#ok
                end
                if ~isempty(dir(pTool))
                    ok = true;
                    break;
                end
            end
        else
            % Check list of matching directory names
            isd = dir([spath{d}, filesep, sdir{n}]);
            if ~isempty(isd)
                pTool = [spath{d}, filesep, isd(1).name];
                if n<3
                    pTool = [pTool, filesep, toolp]; %#ok
                end
                if ~isempty(dir(pTool))
                    ok = true;
                    break;
                end
            end
        end
    end
    if ok
        disp(['Find : ',pTool])
        break;
    end
end

if ok
    if strcmp(opt,'add')
        disp(['Adding ',toolname,' directory to Matlab paths'])
        addpath(pTool)    
    elseif strcmp(opt,'rm')
        disp(['Removing ',toolname,' toolbox paths'])
        % Search all iso2mesh directory
        allp = strsplitt(path,';')';
        ic = strfind(allp, pTool);
        for j = 1:length(ic)
            if ~isempty(ic{j})
                rmpath(allp{j})
            end
        end
        ft_defaults
    end
else
    disp('!!!')
    disp([toolname,' toolbox directory not found...'])
    disp('Contact after-sales service... or place')
    disp([toolname,' directory in toolbox directory'])
    disp('And restart the program...')
end
    
if nargout > 0
    okdone = ok;
end

disp(' ')