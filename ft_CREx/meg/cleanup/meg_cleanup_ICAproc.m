function compData = meg_cleanup_ICAproc(datapath, icaopt)

fprintf('\nProcessing of data in :\n%s\n\n',datapath);
fprintf('\n\t\t-------\nICA component analysis\n\t\t-------\n')

[pmat,nmat] = find_datamat(datapath, icaopt);
if ~isempty(pmat)
    dsp = strsplitt(nmat,'_');
    prefix = dsp{1};
    if ~isempty(strfind(prefix, 'Trials'))
        dtyp = 'Trials';
    else
        dtyp = 'Data';
    end
    MEGdata = loadvar(pmat,['*', dtyp, '*']);

    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')
    
    cfg = [];
    % Remove baseline (mean value) only if data have not been 
    % previously filtering
    if ~strcmp(nmat(1:3),'raw')
        cfg.demean = 'no';  % Default = 'yes'
    end
    cfg.method = 'runica'; 
    if exist('icaopt','var') && isfield(icaopt,'numcomp') &&...
            ~isempty(icaopt.numcomp) && isnumeric(icaopt.numcomp)
        cfg.numcomponent = icaopt.numcomp;
    end
    compData = ft_componentanalysis(cfg,MEGdata); 
    suff = meg_matsuff(nmat);
    if ~isempty(suff)
        suff=['_',suff]; 
    end
    
    save([datapath,filesep,'ICAcomp',suff],'compData')
    disp(' '),disp('ICA components saved in ----')
    disp(['----> ',datapath,filesep,'ICAcomp_',prefix,suff]),disp(' ')
end