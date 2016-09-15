function meg_cleanup_ICAplot(datapath)
% Load ICA components matrix, and launch function to output figures of components
% (topographic + temporal plots).
% 
fprintf('\nProcessing of data in :\n%s\n\n',datapath);
fprintf('\n\t\t-------\nICA component analysis plots\n\t\t-------\n')
pmat = dirlate(datapath,'ICAcomp*.mat');
if ~isempty(pmat)
    comp_MEGdata = loadvar(pmat,'comp*');
    % Save ICA figures directory in the general "Preproc_fig" directory
    % that is placed in the data directory
    ppdir = make_dir(fullfile(datapath, '_preproc'), 0);
    fdos = make_dir([ppdir, filesep, 'ICA_plots'],1);
    opt = struct;
    opt.pathcompmat = pmat;
    opt.pathsavfig = fdos;
    opt.xlimzoom = [100 110];
    meg_topoICA_fig(comp_MEGdata, opt)
end