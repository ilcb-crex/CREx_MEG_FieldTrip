% Cluster-based permutation tests with Fieldtrip - Within subjects analysis
% Fieldtrip tutorial :
% http://fieldtrip.fcdonders.nl/tutorial/cluster_permutation_timelock
%
% Here we use ft_statistics_montecarlo function directly
%
% We are searching for temporal clusters inside each ROIs (no spatial
% clustering processed).
%
% Exemple of test with ADys data
% Comparison between theses two conditions :
% Morpho and Ortho
%
% Data structure used (exemple with the Morpho condition) :
%
% sourceGA.Morpho :
%     powdimord: 'pos'
%           pos: [4050x3 double]
%           dim: [15 18 15]
%        inside: [4050x1 logical]
%           cfg: [1x1 struct]
%             z: [20x2127x361 double]
%           mom: [20x2127x361 double]
%          time: [1x361 double]
%          subj: {20x1 cell}
%
% Source signals (sourceGA.Morpho.z) have been average per anatomical ROI
% based on Cloin27 template (116 ROIs)
% Average signals have been stored in 
% sourceGA_aROIsubj.Morpho :
%     avgROIsubj: {116x1 cell}
%          label: {1x116 cell}
% For index of ROI = 81 :
% sourceGA_aROIsubj.Morpho.label{81} = 'Temporal_Sup_L'
% sourceGA_aROIsubj.CAC.Morpho.avgROIsubj(81) = [20x361 double] (mean
% signal in this area for the 20 subjects).
%

% Parameters for the statistics
WOI = [0 0.650]; % Windows of interest (s)
Nrand = 10000; % Number of randomized permutations
alphaTHR = 0.05; % alpha threshold for the permutation test

% Configuration structure for ft_statistics_montecarlo
cfgst = [];
cfgst.statistic = 'depsamplesT';    % as a measure to evaluate the effect at the sample level
cfgst.tail = 0;                     % -1, 1 or 0 (default = 0); one-sided or two-sided test

cfgst.numrandomization = Nrand;     % Number of draws from the permutation distribution
cfgst.alpha = alphaTHR;             % Alpha level of the permutation test

cfgst.correctm = 'cluster';         % Apply multiple-comparison correction
cfgst.clusteralpha = alphaTHR;      % Alpha level threshold of the sample-specific test statistic 
cfgst.clusterstatistic = 'maxsum'; 	% How to combine the single samples that belong to a cluster                          
cfgst.clustertail = 0;            	% -1, 1 or 0 (default = 0 : two-tail test)
cfgst.minnbchan = 0;                % Min nb of neigh. channels required for a selected sample to be include

cfgst.ivar  = 2;                    % Independent variable(s) : conditions number (2nd row of the design matrix)
cfgst.uvar  = 1;                    % Units of observation (the "pairing" : Subject number - 1st row of design)

cfgst.dimord = 'chan_freq_time';
cfgst.avgoverchan = 'yes';    
cfgst.correcttail = 'prob';         % Correct p values because of two-tails (-> p_val/2)
                                    % http://fieldtrip.fcdonders.nl/faq/why_should_i_use_the_cfg.correcttail_option_when_using_statistics_montecarlo
 
% Define the design matrix
Nsubj = length(sourceGA.Morpho.subj);
design = zeros(2, Nsubj*2);
design(1, :) = [1:Nsubj 1:Nsubj];  
design(2, :) = [ones(1, Nsubj) ones(1, Nsubj).*2];
    
cfgst.design = design;  



% Make a matrix of the windowed averaging signals
Nroi = length(sourceGA_aROIsubj.label);

meas1 = sourceGA_aROIsubj.Morpho.avgROIsubj;
meas2 = sourceGA_aROIsubj.Ortho.avgROIsubj; 

time = sourceGA.Morpho.time;
iwoi = find(time > WOI(1) & time < WOI(2));

wmeas1 = NaN(Nroi, Nsubj, length(iwoi));
wmeas2 = NaN(Nroi, Nsubj, length(iwoi));

for k = 1 : Nroi
    if ~isempty(meas1{k}) 
        wmeas1(k,:,:) = meas1{k}(:,iwoi);
        wmeas2(k,:,:) = meas2{k}(:,iwoi);
    end
end

% Format the data, as ft_statistics_montecarlo requires it
cond1 = permute(wmeas1, [1 3 2]); % [ roi x ampl x subj ]
cond2 = permute(wmeas2, [1 3 2]);   

% Store the p values corrected for multiple comparison by the clustering 
% method (based here on sum of max(t-value))
p_val = NaN(Nroi, length(iwoi));

for k = 1 : Nroi         
    if ~isnan(cond1(k,1,1))

        C1 = squeeze(cond1(k,:,:));
        C2 = squeeze(cond2(k,:,:));
        
        dat = [C1,C2];
        cfgst.dim = [1 1 length(C1)];

        stat = ft_statistics_montecarlo(cfgst, dat, design);
        p_val(k,:) = stat.prob';
    end
end

