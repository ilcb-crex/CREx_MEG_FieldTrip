function meg_cleanup_ICAplot(path)

fprintf('\nProcessing of data in :\n%s\n\n',path);
fprintf('\n\t\t-------\nICA component analysis plots\n\t\t-------\n')
pmat = dirlate(path,'ICAcomp*.mat');
if ~isempty(pmat)
    comp_MEGdata = loadvar(pmat,'comp*');
    fdos = make_dir([path,filesep,'ICA_plots'],1);
    opt = struct;
    opt.pathcompmat = pmat;
    opt.pathsavfig = fdos;
    opt.xlimzoom = [100 110];
    meg_topoICA_fig(comp_MEGdata, opt)
end