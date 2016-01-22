function sourceGA = load_adys_sourceGA(pgadir, strproc)
% Sooooooo specific...
    SCAC = load(fullfile(pgadir,['GA_Source', strproc],['sourceGA_CAC', strproc,'.mat']));
    SDYS = load(fullfile(pgadir,['GA_Source', strproc],['sourceGA_DYS', strproc,'.mat']));
    sourceGA = struct;
    sourceGA.CAC = SCAC.sourceGA;
    sourceGA.DYS = SDYS.sourceGA;
    clear SCAC SDYS