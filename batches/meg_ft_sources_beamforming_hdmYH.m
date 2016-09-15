% ________
% Parameters to adjust

%---- Definition of data architecture
p0 = 'H:\PWD'; 
pmeg = {  {p0}, 0
        {'Set_0'}, 1 
        {'bapa', 'pure'}, 0
        };    
    
%--- Indices of data path list to treat (vsdo=[] : all found data paths)
vdo = [];  

%--- Process to launch
doVol = 1;  % Volume conduction model computing
doLoc = 1;  % Beamforming localisation
doMap = 0;  % Maps of results

%--- Stimulus conditions to process
% Only conditions field names in trials data structure will be
% considerating for beamforming localization computation
% Exemple : conditions = {'Morpho','Ortho','Seman','NonR'}; 
% Let empty to process all conditions : condition = {};
conditions = {};


%--- Baseline definition (in seconds)
BSL = [-0.250 0];

%--- Preprocessing options applied to trials for localisation
trialopt = struct;
% Redefined trial window    
trialopt.redef.do  = 0;     % [ redef.do = 1 : do it ; 0 :  don't]  
trialopt.redef.win = [0 0];	% [t_prestim t_postim] (s) ( ! stim at t= 0 s => t_prestim negative)
% Apply Low-Pass filter
trialopt.LPfilt.do = 1;       
trialopt.LPfilt.fc = 25;	% Low-pass cut-off frequency (Hz)
% Resample trials
trialopt.resamp.do = 1;       
trialopt.resamp.fs = 200;	% New sample frequency (Hz)
% "Resampling can reduce some aberrant covariance values"

%--- Sliding windows options for map representations
% Mean values of source signals are calculated according to windows
% definition and duration
winopt = struct;
winopt.slidwin =  -0.050 : 0.010 : 0.700; %-0.020 : 0.010 : 0.600; % -0.3 : 0.01 : 0.650;   % Starts of each window
winopt.lgwin = 0.02 ;                   % Duration of each window

%--- Name of the MRI template for the localisation maps 
template_name = 'Colin27_BS.nii'; %'Colin27_BS.nii';

% ____ GO !____

% opengl('OpenGLWobbleTesselatorBug',1) 
% opengl('software', true)
% Don't know if necessary to prevent 
% head model figures bug

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

datapaths = make_pathlist(pmeg);

if ~isempty(vdo)
    datapaths = datapaths(vdo); 
end
Ndp = length(datapaths);

% Check options of preprocessing for trials before applying it
if doLoc==1 
    [T, trialopt] = meg_trials_preproc([], trialopt);
end

%_____
% Volume conduction model preparation and ajusted MNI grid (from template)
if doVol==1
    for ns = 1 : Ndp 
        disp_progress(ns, Ndp);
        fprintf('\nProcessing of data in :\n%s\n\n',datapaths{ns});
        
        fprintf('\n\n\t-------\nVolume conduction model preparation\n\t-------\n\n')
        
        megpath = datapaths{ns};
        
        [subj_vol, subj_grid, M1] = meg_loc_headmodel_hdmYH(megpath);
        if ~isempty(subj_vol)
            save([megpath,filesep,'headModel_hdmYH_Colin27BS'],'subj_vol','subj_grid','M1')
            disp('-----')
            disp('Head model saved in headModel_hdmYH_Colin27BS.mat')
            disp('in MEG data path')
        else
            disp('!!!!! So head model not computed due to missing/wrong data... :''(')
        end

    end
end

%_____
% Beamforming modelisation using previously computed volume conduction model 
if doLoc==1
    for ns = vdo 
        disp(['------------------- [ ',num2str(ns),' ] -------------------'])
        disp(['--> ',datapaths{ns}])
        fprintf('\n\n\t-------\nSources computation by beamforming method\n\t-------\n\n')
        
        megpath = datapaths{ns};
        meg_loc_beamform_hdmYH(megpath, trialopt, conditions, BSL)
    end
end

%_____
% Map of modelisation results
if doMap==1
    pMRI = which(template_name);
    if isempty(pMRI)
        disp(' ')
        disp('!!!!!')
        disp([template_name,' not found in Matlab path...'])
        disp('Impossible to edit map of localisation')
        
    else
        colmri = ft_read_mri(pMRI);
        for ns = vdo 
            disp(['------------------- [ ',num2str(ns),' ] -------------------'])
            disp(['--> ',datapaths{ns}])
            fprintf('\n\n\t-------\nSources computation by beamforming method\n\t-------\n\n')

            megpath = datapaths{ns};
            opt = [];
            opt.win = winopt;
            opt.cond = conditions;
            opt.tempmri = colmri;
            
            meg_loc_map_hdmYH(megpath, opt, trialopt)

        end
    end
end