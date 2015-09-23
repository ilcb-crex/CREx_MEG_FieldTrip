function sourC = meg_loc_beamfpow_slidwin_meth2(trials,lfgrid,vol)

iwin=-.08:.01:.8; 
lgw=.02; 

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

sourC_norm2=cell(length(iwin),1);
for nw=1:length(iwin)
    % Define average evoked response
    cfgavg.covariancewindow = [iwin(nw) iwin(nw)+lgw]; 
    avg_ER = ft_timelockanalysis(cfgavg,avgT);
    % Perform source analysis of this part
    sourC_avgER = ft_sourceanalysis(cfgbf,avg_ER);
    if nw==1
        sourC_norm2=sourC_avgER;
        sourC_norm2.time=cell(length(iwin),1);
        sourC_norm2.avg=rmfield(sourC_norm2.avg,'mom');
        sourC_norm2.avg.pow=cell(length(iwin),1);
        sourC_norm2.iwin=iwin;
        sourC_norm2.lgwin=lgw;
    end
    % Normalized with baseline results
    sourC_norm2.time{nw} = [iwin(nw) iwin(nw)+lgw]; %sourC_avgER.time;
    sourC_norm2.avg.pow{nw}= sourC_avgER.avg.pow./sourC_avgBL.avg.pow;
end

sourC=cell(2,1);
sourC{1}=sourC_norm2; % Obtained with method 2


