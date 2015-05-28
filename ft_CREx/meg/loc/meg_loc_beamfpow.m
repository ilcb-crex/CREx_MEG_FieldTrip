function sourC = meg_loc_beamfpow(trials,lfgrid,vol,latwin)

% Method 1

% The covariance is calculated on all trials and averaged
cfg = [];
cfg.removemean = 'no';
cfg.covariance = 'yes';
cfg.covariancewindow = 'all';
avgT = ft_timelockanalysis(cfg,trials);

% Source analysis using averaged covariance calculated with the whole trials
% Linear Constrained Minimum Variance beamformer
cfg        = [];
cfg.method = 'lcmv';  
cfg.grid   = lfgrid;
cfg.vol    = vol;
cfg.lcmv.lambda = '5%'; 
cfg.lcmv.keepfilter = 'yes';
cfg.lcmv.fixedori     = 'yes';
sourC_avgT = ft_sourceanalysis(cfg,avgT); % Source per Condition

% Average baseline part
cfg=[];
cfg.toilim = [trials.time{1}(1) 0];
trials_BL = ft_redefinetrial(cfg,trials);
avg_BL = ft_timelockanalysis(cfg,trials_BL);
% Apply filter obtain by source analysis using all trials on baseline part
cfg = [];
cfg.vol = vol;
cfg.method = 'lcmv';
cfg.grid   = lfgrid;
cfg.grid.filter = sourC_avgT.avg.filter;
cfgbf=cfg;
sourC_avgBL =  ft_sourceanalysis(cfgbf, avg_BL);

% Do the same thing for all parts of interest defined inside evoked-related
% potential (evoked response expected after stimulus presentation)
sourC_norm1=cell(length(latwin(:,1)),1);
for nw=1:length(latwin(:,1))
    cfg        = [];
    cfg.toilim = latwin(nw,:);
    trials_ER = ft_redefinetrial(cfg,trials);
    avg_ER = ft_timelockanalysis(cfg,trials_ER);
    % Apply filter obtain from the source analysis using the entire part of
    % the trials
    sourC_avgER = ft_sourceanalysis(cfgbf,avg_ER);

    % Sources normalisation using baseline results
    % This avoids that sources being localized at the center of the brain 
    sourC_norm1{nw} = sourC_avgER;
    sourC_norm1{nw}.avg.pow = sourC_avgER.avg.pow./sourC_avgBL.avg.pow;
end

% Method 2

% Averaged all trials (per condition)
avgT = ft_timelockanalysis([],trials);

% Define baseline average
cfg = [];
cfg.covariance = 'yes';
cfg.removemean = 'no';
cfg.covariancewindow = [trials.time{1}(1) 0];
cfgavg=cfg;
avg_BL = ft_timelockanalysis(cfg,avgT);

% Source analysis on baseline average part
cfg        = [];
cfg.method = 'lcmv';
cfg.grid   = lfgrid;
cfg.vol    = vol;
cfg.lcmv.lambda = '5%';
cfgbf=cfg;   
sourC_avgBL = ft_sourceanalysis(cfg,avg_BL);

sourC_norm2=cell(length(latwin(:,1)),1);
for nw=1:length(latwin(:,1))
    % Define average evoked response
    cfgavg.covariancewindow = latwin(nw,:); 
    avg_ER = ft_timelockanalysis(cfgavg,avgT);
    % Perform source analysis of this part
    sourC_avgER = ft_sourceanalysis(cfgbf,avg_ER);
    
    % Normalized with baseline results
    sourC_norm2{nw} = sourC_avgER;
    sourC_norm2{nw}.avg.pow = sourC_avgER.avg.pow./sourC_avgBL.avg.pow;
end

sourC=cell(2,1);
sourC{1}=sourC_norm1; % Obtained with method 1
sourC{2}=sourC_norm2; % Obtained with method 2

