function clusterROI = meg_clusterstat_montecarlo(sourceGA, statopt)
% Still very specific to CREx processing data - should add the function to
% detect at which level the avgROI field is store for example (groupe level
% or not ?).
% + Miss the checking of the statopt parameters

%---- General variable
% Groupe names
cat = fieldnames(sourceGA);
% Condition names
ucond = unique(statopt.supcond, 'stable');

% Process the mean source signal per condition and per ROI
opt = [];
opt.atlas = statopt.atlas;
opt.dipid = statopt.dipid;
opt.param = statopt.paramstr;
opt.method = 'each';
opt.cond = ucond;
sGA_aROIsubj = meg_aROIsubj_calc(sourceGA, opt);



% Define indices of ROI to considere
Alab = statopt.atlas.tissuelabel;
Nlab = length(Alab);
    
if ~isfield(statopt, 'iROI') || isempty(statopt.iROI) || (ischar(statopt.iROI))
    iroi = 1 : length(Alab);
else
    iroi = statopt.iROI;
end

supcond = statopt.supcond;
strproc = statopt.strproc;
WOI = statopt.WOI;
Nrand = statopt.Nrand;
alphaTHR = statopt.alphaTHR;
durTHR = statopt.durTHR;

ft_defaults

time = sGA_aROIsubj.(cat{1}).(ucond{1}).time;

iwoi = find(time > WOI(1) & time < WOI(2));

clustat = struct;

% Configuration structure for ft_statistics_montecarlo
cfgst = [];
cfgst.method = 'montecarlo'; 
cfgst.statistic = 'depsamplesT';    % as a measure to evaluate the effect at the sample level
cfgst.tail = 0;                     % -1, 1 or 0 (default = 0); one-sided or two-sided test
cfgst.correctm = 'cluster';         % apply multiple-comparison correction
cfgst.clusteralpha = alphaTHR;      % alpha level threshold of the sample-specific test statistic 
cfgst.clusterstatistic = 'maxsum'; 	% how to combine the single samples that belong to a cluster                          
cfgst.clustertail = 0;            	% -1, 1 or 0 (default = 0)
cfgst.minnbchan = 0;                % min nb of neigh. channels required for a selected sample to be include
cfgst.alpha = alphaTHR;             % alpha level of the permutation test
cfgst.numrandomization = Nrand;     % number of draws from the permutation distribution
cfgst.ivar  = 2;                    % Independent variable(s) : conditions number
cfgst.uvar  = 1;                    % Units of observation (the "pairing" : Subject number)
cfgst.dimord = 'chan_freq_time';
cfgst.avgoverchan = 'yes';    
cfgst.correcttail = 'prob'; 

for i = 1 : length(cat)
    ca = cat{i};
    
    % Define the design matrix
    Nsubj = length(sourceGA.(ca).(supcond{1,1}).subj);
    design = zeros(2, Nsubj*2);
    design(1, :) = [1:Nsubj 1:Nsubj];  
    design(2, :) = [ones(1, Nsubj) ones(1, Nsubj).*2];
    
    cfgst.design = design;  
    
    for j = 1 : length(supcond(:,1))

        supname = strjoint(supcond(j,:),'_');
        
        meas1 = sGA_aROIsubj.(ca).(supcond{j,1}).avgROIsubj;
        meas2 = sGA_aROIsubj.(ca).(supcond{j,2}).avgROIsubj; 
                
        wmeas1 = NaN(Nlab, Nsubj, length(iwoi));
        wmeas2 = NaN(Nlab, Nsubj, length(iwoi));
        
        for k = iroi
            if ~isempty(meas1{k})
                wmeas1(k,:,:) = meas1{k}(:,iwoi);
                wmeas2(k,:,:) = meas2{k}(:,iwoi);
            end
        end
        
        cond1 = permute(wmeas1, [1 3 2]);
        cond2 = permute(wmeas2, [1 3 2]);   

        p_val = NaN(length(Alab), length(iwoi));

        for k = iroi            
            if ~isnan(cond1(k,1,1))
             
                C1 = squeeze(cond1(k,:,:));
                C2 = squeeze(cond2(k,:,:));
                dat = [C1,C2];
                cfgst.dim = [1 1 length(C1)];

                stat = ft_statistics_montecarlo(cfgst, dat, design);
                p_val(k,:) = stat.prob';
            end
        end
        clustat.(ca).(supname).time = time(iwoi);
        clustat.(ca).(supname).p_val = p_val;
        clustat.(ca).(supname).label = Alab;
        clustat.(ca).(supname).Nrand = Nrand;
        clustat.(ca).(supname).alphaTHR = alphaTHR;
        clustat.(ca).(supname).WOI = WOI;
    end
end

% Define time clusters per ROI
Fs = fsample(time);
fnames = fieldnames(clustat.(cat{1})); 
clusterROI = struct;
for i = 1 : length(cat)
    label = clustat.(cat{i}).(fnames{1}).label;
    for j = 1 : length(fnames)
        clusterROI.(cat{i}).(fnames{j}).dur = cell(length(label),1);
        clusterROI.(cat{i}).(fnames{j}).itime = cell(length(label),1);
        clusterROI.(cat{i}).(fnames{j}).pval = cell(length(label),1);
        clusterROI.(cat{i}).(fnames{j}).durTHR = durTHR;
        clusterROI.(cat{i}).(fnames{j}).clustat = clustat.(cat{i}).(fnames{j});
        % We keeep information about preprocessing trials used to compute
        % the sources signals
        clusterROI.(cat{i}).(fnames{j}).preproc = strproc;
        for k = iroi
            proi = clustat.(cat{i}).(fnames{j}).p_val(k,:);
            if ~isnan(proi(1))
                pz = proi;
                pz(proi < alphaTHR) = 1;
                pz(proi >= alphaTHR) = 0;

                dpz = diff(pz);
                iclust = find(dpz==1)+1;
                durc = zeros(length(iclust),1);
                itimec = zeros(length(iclust),1);
                pvalc = zeros(length(iclust),1);
                for ic = 1 : length(iclust)
                    ii = iclust(ic);
                    jj = ii;
                    while jj+1 <= length(pz) && pz(jj+1)==1 
                        jj = jj+1;
                    end
                    durc(ic) = (jj-ii+1)./Fs;
                    itimec(ic) = clustat.(cat{i}).(fnames{j}).time(ii);
                    pvalc(ic) = proi(ii);
                end
                idurok = find( durc >= durTHR);
                if ~isempty(idurok)
                    clusterROI.(cat{i}).(fnames{j}).dur{k} = durc(idurok);
                    clusterROI.(cat{i}).(fnames{j}).itime{k} = itimec(idurok);
                    clusterROI.(cat{i}).(fnames{j}).pval{k} = pvalc(idurok);                    
                end
            end
        end
    end
end
