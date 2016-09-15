function compData = meg_ica_proc(datapath, icaopt)
% -- Compute ICA components by ft_componentanalysis on continuous data or
% trials dataset by the 'runica' method
% If data are trials, the average of each virtual sensor (component) is
% done at the end of the ICA processing.
% -- Save data of components in the same directory than the data

fprintf('\nProcessing of data in :\n%s\n\n',datapath);
fprintf('\n\t\t-------\nICA component analysis\n\t\t-------\n')

% Check for inputs
if nargin==2 && isfield(icaopt,'numcomp') &&...
        ~isempty(icaopt.numcomp) && isnumeric(icaopt.numcomp)
    Ncomp = icaopt.numcomp;
else
    Ncomp = 'all';
end
        
% Find data matrix with names containing icaopt.prefix and preproc
% characteristics
[pmat,nmat] = find_datamat(datapath, icaopt);

if ~isempty(pmat)
    dsp = strsplitt(nmat,'_');
    prefix = dsp{1};
    
    if ~isempty(strfind(prefix, 'Trials'))
        dtyp = 'Trials';
        continuous = 0;
        % Demean option for ICA calculation (remove mean value)
        demn = 'no'; 
    else
        continuous = 1;
        dtyp = 'Data';
        if strcmp(nmat(1:3),'raw')
            % Remove mean value only if data have not been 
            % previously filtering
            demn = 'yes';
        else
            demn = 'no';
        end
    end

    Sdat = loadvar(pmat,['*', dtyp, '*']);

    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')
    
    if continuous==1
        Sdat = struct('Continuous', Sdat);
    end
    
    fcond = fieldnames(Sdat);
    
    compData = [];
    for i = 1 : length(fcond)
        
        cond = fcond{i};
                
        % Parameters for ICA calculation
        cfg = [];
        cfg.method = 'runica'; 
        cfg.numcomponent = Ncomp;
        cfg.demean = demn;
        % That all !
        comp = ft_componentanalysis(cfg, Sdat.(cond)); 
        
        % Average trials
        if continuous==0
            cfg = [];
            cfg.keeptrials = 'no';
            cfg.removemean = 'no'; % Suppose to be already done by filtering 
            comp = ft_timelockanalysis(cfg, comp);
        end
        compData.(cond) = comp;    
    end
    
    % Append preproc suffix to component data matrix
    suff = meg_matsuff(nmat);
    if ~isempty(suff)
        suff=['_',suff]; 
    end
    
    
    if continuous
        comptyp = 'ICAcomp';
        compData = compData.(cond);  
    else
        comptyp = 'avgComp';
    end
    compmat = [datapath, filesep, comptyp, '_', prefix, suff];
    save(compmat,'compData')
    
    disp(' '),disp('ICA components saved in ----')
    disp(['----> ',compmat]),disp(' ')
end

% function Sconc = concate_trials(Sdat)
% 
% alltrials = Sdat.trial;
% 
% fs = sampfreq(Sdat.time{1});


