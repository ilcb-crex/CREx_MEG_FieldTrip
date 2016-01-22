function sourceROIsubj = compute_bapa_sourceROIsubj
% Parameters, very specifics to the study (depending on conditions names,
% conditions to compare, time window of interest, statistic parameters...)

%- Paths of the required data
loadmat = 1;
pgadir = 'F:\BaPa'; % Path of directory containing the GA directories 
patlas = 'atlas_Colin27_BS_subROI.mat';
pdipid = 'dipid_atlascoreg_ADys_subROI.mat';

sopt = [];
sopt.paramstr = 'z';

%- Option to compute "z", "absz" or "z2" source signal from "mom" field 
% in case you have to recompute it (cf baseline to change)
zcompute = 1;
% Associated parameters for the calculation
zopt = [];
% Time portion of the source signal use to do the Z-normalisation
zopt.tnormz = [-0.250 0];
% Time portion of the Z-normalised source signal to do the baseline
% correction (by substracting the mean value of the signal inside this
% portion)
zopt.tbslcor = [];

% Preprocessing parameters previously apply to data for source signal
% reconstruction - important to keep this information on results mat name
% in case of several analysis implying different preprocessing
% parameters...
preproc = struct;
preproc.LPfc    = 40;   % Low-pass frequency
preproc.resfs   = 240;  % New sample frequency

strproc = preproc_suffix(preproc);

if loadmat == 1  
    atlas = loadvar(patlas, 'atlas*');
    dipid = loadvar(pdipid, 'dipid*');
    %--- Still very specific to ADys data
    sourceGA = load_BaPa_sourceGA(pgadir, strproc); 
end


sopt.atlas = atlas;
sopt.dipid = dipid;

if zcompute
    % Prepare source data - Compute "z" field from "mom" field with new 
    % baseline correction if zopt.tbslcor is defined
    zopt.paramstr = sopt.paramstr;
    sourceGA = compute_z(sourceGA, zopt);
end


% Process the mean source signal per condition and per ROI
opt = [];
opt.atlas = sopt.atlas;
opt.dipid = sopt.dipid;
opt.param = sopt.paramstr;
opt.method = 'each';
sourceROIsubj = meg_aROIsubj_calc(sourceGA, opt);
