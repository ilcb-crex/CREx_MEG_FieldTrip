function strproc = preproc_suffix(preproc)
% Return the processing suffix corresponding to parameters specified in 
% preproc structure :
%
% preproc.hpfc  : High-pass cut-off frequency of applied filter (Hz)
% preproc.lpfc  : Low-pass cut-off frequency of applied filter (Hz)
% preproc.resfs : Resample frequency (Hz)
% preproc.crop  : trials croped border ([t_prestim t_postim] in seconds, 
%                                   stim : t=0s, t_prestim is negative)
%
% Ex. : build processing suffix for trials that have been filtered betwee,
% 1 and 25 Hz (band-pass) and resampled at 200 Hz :
% preproc.hpfc = 1;
% preproc.lpfc = 25;
% preproc.resfs = 200;
% preproc.crop = [0 0]; % No crop
% preproc.rmT
% preproc.rmC
% preproc.rmS
% => strproc = '_HP1Hz_LP25Hz_Res200Hz'
%
% Need to build new data matrix name after preprocessing or to append
% strproc suffix to result directories...
%
% - CREx 2014

if isstruct(preproc)
    % Lower string for the field names
    newfields = cellstr(lower(char(fieldnames(preproc))));
    val = struct2cell(preproc);
    preproc = cell2struct(val, newfields); 
end

strproc = '';

%---- FILTER

%-- HP
if isfield(preproc,'hpfc') && ~isempty(preproc.hpfc) && preproc.hpfc > 0
    fcs = num2str(preproc.hpfc);
    fcs(fcs=='.') = 'p';
    strproc = [strproc,'_hp',fcs];
end

%-- LP
if isfield(preproc,'lpfc') && ~isempty(preproc.lpfc) && preproc.lpfc > 0
    fcs = num2str(preproc.lpfc);
    fcs(fcs=='.') = 'p';
    strproc = [strproc,'_lp',fcs];
end

%---- RESAMPLE

if isfield(preproc,'resfs') && ~isempty(preproc.resfs) && preproc.resfs > 0
    fss = num2str(preproc.resfs);
    fss(fss=='.') = 'p';
    strproc = [strproc,'_rs',fss];
end

%---- CROP WINDOW

if isfield(preproc,'crop') && length(preproc.crop)==2 && sum(preproc.crop)~=0
    win = preproc.crop;
    winst = cell(1,2);
    winst{1} = ['m',num2str(abs(win(1)))];
    winst{1}(winst{1}=='.') = 'p';
    winst{2} = num2str(win(2));
    winst{2}(winst{2}=='.') = 'p';
    strproc = [strproc,'_crop',winst{1},'to',winst{2},'s'];
end      


%---- CLEANUP
cus = 'rm';

%-- TRIALS REMOVING
if isfield(preproc, 'rmt') && ~isempty(preproc.rmt) && preproc.rmt > 0
    nrm = num2str(preproc.rmt);
    cus = [cus, nrm, 't'];
end

%-- COMPONENT REMOVING
if isfield(preproc, 'rmc') && ~isempty(preproc.rmc) && preproc.rmc > 0
    nrm = num2str(preproc.rmc);
    cus = [cus, nrm, 'c'];
end

%-- SENSOR REMOVING
if isfield(preproc, 'rms') && ~isempty(preproc.rms) && preproc.rms > 0
    nrm = num2str(preproc.rms);
    cus = [cus, nrm, 's'];
end

if length(cus) > 3
    strproc = [strproc, '_', cus];
end