function rawData = meg_extract4d(dirpath,trl)

if nargin == 1 || isempty(trl) || trl==0
    trlfield = 0;
else
    trlfield = 1;
end

fprintf('\n\t-------\nSearch for 4D data file\n\t-------\n')
if exist(dirpath,'file')==2
    datapath = dirpath;
else
    datapath = filepath4d(dirpath);
end
if ~isempty(datapath)
    fprintf('\n\t-------\nExtract raw dataset\n\t-------\n')
    cfg = [];
    cfg.dataset = datapath;
    cfg.trialfun = 'ft_trialfun_general'; % Default (avoid warning message)
    cfg.trialdef.triallength = Inf;       % All the dataset blocksize
    cfg_rawData = ft_definetrial(cfg);    
    cfg_rawData.channel = {'MEG','A*'};

    if trlfield==1
        cfg_rawData.trl = trl;
    end
    
    try
        rawData = ft_preprocessing(cfg_rawData);
    catch
        disp('Impossible to read raw dataset...')
        rawData = [];
    end
else
    rawData = [];
    disp(' ')
    disp('4D data file not found...')       
end