function rawData = meg_extract4d(dirpath, trl)
% Find and extract raw data found in a specific directory. 
% Raw data can be MEG 4D data or S/EEG data.
% Input paramaters:
% --------
% - dirpath : path of the directory where data are looked for
%               or path of the raw data file to extract
% - trl : vector to specified trial to extract [ default: []]
%   If trl is unset, empty or 0, continuous data are extract [ default ].
%   If trl is defined (as a Nx3 matrix), trials are defined (see
%   ft_preprocessing for trl definition).
% Output parameters:
% ---------
% rawData : FieldTrip data structure containing extracted data
%
% This function uses the function filepath4D of the ft_CREx toolbox to find the 
% 4D file in the directory. Data are then extracted by ft_definetrial and
% ft_preprocessing FieldTrip functions.
%
%______
%-CREx 20131030 
%-CREx-BLRI-AMU project: https://github.com/blri/CREx_MEG/fieldtrip_process


%-- Check for inputs
if nargin == 1 || isempty(trl) || trl==0
    trlfield = 0;
else
    trlfield = 1;
end

% -- Search file
fprintf('\n\t-------\nSearch for 4D/seeg data file\n\t-------\n')
% If dirpath is not the path of the raw file but of a directory, raw data
% are searched inside the dirpath folder using filepath4d function.
if exist(dirpath,'file')==2
    datapath = dirpath;
else
    datapath = filepath4d(dirpath);
end

%-- Extract data with fieldtrip functions
if ~isempty(datapath)
    fprintf('\n\t-------\nExtract raw dataset\n\t-------\n')
    [~, ~, ext] = fileparts(datapath);
    % Defined type of channel to extract
    % If data extent is 'eeg', then EEG channels will be extracted.
    % Otherwise, data are assumed to be MEG data.
    if strcmp(ext, '.eeg')
        chan = {'*'};
    else
        chan = {'meg'};
    end
    
    cfg = [];
    cfg.dataset = datapath;
    cfg.trialfun = 'ft_trialfun_general'; % Default (avoid warning message)
    cfg.trialdef.triallength = Inf;       % All the dataset blocksize
    cfg_rawData = ft_definetrial(cfg);    
    cfg_rawData.channel = chan;

    % If trl is define as input parameter, then data will be epoched
    % according to the trl matrix.
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