function meg_cleanup_chancheck(dirpath, opt)
% Check for continuous data noise per channel
% Ratio of Hilbert envelop calculated on the absolute value
fprintf('\nProcessing of data in :\n%s\n\n',dirpath);

if ~isfield(opt,'datatyp') || isempty(opt.datatyp) 
    opt.datatyp = '4d';
end
ok = false;
if strcmpi(opt.datatyp,'4d')==1
    ftData = meg_extract4d(dirpath);
    if ~isempty(ftData)
        disp('-----')
        disp('Filter dataset to calculate a meaningful value')
        disp('of the mean envelop signal')
        cfg = [];
        cfg.hpfilter = 'yes';
        cfg.hpfreq   = 0.5;
        ftData = ft_preprocessing(cfg,ftData);
        datnam = '4dData_fHP0.5Hz';
        ok = true;
    end
else
    
    fprintf('\n\t-------\nLoad dataset\n\t-------\n')
    [pdat,nmat] = dirlate(dirpath,[opt.datatyp,'*.mat']);
    if ~isempty(pdat)
        ftData = loadvar(pdat,'*Data*');
        datnam = nmat(1:end-4);
        ok = true;
    end
end
if ok
    meg_chancheck_fig(ftData, dirpath, datnam)
end
