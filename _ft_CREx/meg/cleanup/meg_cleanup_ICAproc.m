function meg_cleanup_ICAproc(path,icaopt)

fprintf('\nProcessing of data in :\n%s\n\n',path);
fprintf('\n\t\t-------\nICA component analysis\n\t\t-------\n')
[pmat,nmat] = dirlate(path,'filtData*.mat');
if ~isempty(pmat)
    MEGdata = loadvar(pmat,'*Data*');
    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')
    cfg = [];
    % Remove baseline (mean value) if data have not been 
    % previously filtering
    if ~strcmp(nmat,'raw')
        cfg.demean = 'no';  % Default = 'yes'
    end
    cfg.method = 'runica'; 
    if exist('icaopt','var') && isfield(icaopt,'numcomp') &&...
            ~isempty(icaopt.numcomp) && isnumeric(icaopt.numcomp)
        cfg.numcomponent = icaopt.numcomp;
    end
    compData = ft_componentanalysis(cfg,MEGdata); %#ok
    suff = meg_matsuff(nmat);
    if ~isempty(suff)
        suff=['_',suff]; 
    end
    save([path,filesep,'ICAcomp',suff],'compData')
    disp(' '),disp('ICA components saved in ----')
    disp(['----> ',path,filesep,'ICAcomp',suff]),disp(' ')
end