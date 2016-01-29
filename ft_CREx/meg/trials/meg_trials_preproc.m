function [newtrialData,trialopt,strproc] = meg_trials_preproc(trialData,trialopt)
% MEG_TRIALS_PREPROC
%
% Apply pre-processing operation(s) on trials data according to trialopt
% structure indications
% This include : low-pass filtering, resampling and time windows 
% re-definition 
% If trialopt is empty or not enter as an input argument, the preprocessing 
% options to apply are asked to the user in the Matlab command window.
%
% Input arguments :
% - - -
% trialopt can contain these fields :
%   LPfilt.do : logical value, 1 to filter the data, 0 otherwise
%   LPfilt.fc : frequency cut-off (scalar value in Hz) required if LPfilt.do==1
%   resamp.do : logical value, 1 to resample the data, 0 otherwise
%   resamp.fs : resampling frequency (scalar value in Hz) required if resamp.do==1
%   redef.do  : logical value, 1 to crop time window of the data, 0 otherwise
%   redef.win : redefined window (2 columns vector : [ t_initial t_final ] 
%               in seconds) required if redef.do==1. Stimulus is located at 
%               t=0 s, so prestimulus time are negative.
% - - -
% trialData : dataset of the trials as returned by FieldTrip functions
% (trialData is a structure)
% If trialData is empty ([]) and trialopt is specified, the fields of the
% structure are checked and message is displayed if the format of a field is
% bad (ex. : LPfilt.do=1 but LPfilt.fc = [] => LPfilt.do is set to 0).
%
% Output arguments :
% - - -
% newtrialData : the FieldTrip structure containing trials dataset
% preprocessed according to trialopt options structure
% - - -
% trialopt : the options structure which has been possibly change according
% - - -
% strproc is a string which contains information of the processing applied
% to trials data
% This string can be added to the name of a results matrix to save or to 
% the title of a figure in order to keep the record of the correction(s)
% applied to data
% 
% -----
% This function uses FieldTrip specific functions :
% ft_preproc_lowpassfilter, ft_resampledata and ft_redefinetrial
%______________________
% CREx 30/10/2013

if (isempty(trialData) && nargin<2) || (nargin==2 && isempty(trialopt)==1)
  disp(' ')
  disp('No option is defined for the preprocessing of the trials')
  disp('      ------')
  disp('Available options : filtering, resampling ')
  disp('        and/or redefined temporal windows ')
  disp('      ------')
  disp(' ')
  disp('Apply option(s) to all trials -> 1')
  disp(' or keep trials as is         -> 2')
  optc = input('                              -> ');
  trialopt = struct;
  if optc==1
      disp(' ')
      trialopt.LPfilt.do = input('Apply low-pass filter (1) or don''t (0) : ');
      if trialopt.LPfilt.do==1
          trialopt.LPfilt.fc = input('Enter frequency cut-off (Hz) : ');
      end
      disp(' ')
      trialopt.resamp.do = input('Redefined trial window (1) or don''t (0) : ');
      if trialopt.resamp.do==1
          trialopt.resamp.fs = input('Enter new sample frequency (Hz) : ');
      end
      disp(' ')
      trialopt.redef.do=input('Redefined trial window (1) or don''t (0) : ');
      if trialopt.redef.do==1
          trialopt.redef.win = [0 0];
          trialopt.redef.win(1) = input('Enter pre-stimulus time in s (<=0 s) : ');
          trialopt.redef.win(2) = input('Enter post-stimulus time in s (>0 s) : ');
      end
  end
end
% Check trialopt fields
disp(' ')
disp(' - - - - - Preprocessing of trials - - - - - - ')
 
% Check for trialopt fields
trialopt = check_trialopt(trialopt);   

% Check for data type (trial or avg field)
if isfield(trialData,'avg')
    fdat = 'avg';
else
    fdat = 'trial';
end
strproc='';
newtrialData = [];

%---- FILTER
if trialopt.LPfilt.do
    if ~isempty(trialData)
        if ~isfield(trialData,'fsample')
            trialData.fsample = fsample(trialData.time{1});
        end
        if strcmp(fdat,'trial')==1
            for nt = 1:length(trialData.trial)
                trialData.trial{nt} = ft_preproc_lowpassfilter(trialData.trial{nt},trialData.fsample,trialopt.LPfilt.fc);   
            end
        else
            trialData.avg = ft_preproc_lowpassfilter(trialData.avg,trialData.fsample,trialopt.LPfilt.fc); 
        end
    end
    fcs = num2str(trialopt.LPfilt.fc);
    fcs(fcs=='.') = 'p';
    strproc = [strproc,'_LP',fcs,'Hz'];
end
%---- RESAMPLE
if trialopt.resamp.do
    if ~isempty(trialData)
        cfg = [];
        cfg.resamplefs = trialopt.resamp.fs;
        cfg.demean     = 'yes';
        cfg.detrend    = 'no';
        trialData = ft_resampledata(cfg, trialData);  
    end
    fss = num2str(trialopt.resamp.fs);
    fss(fss=='.') = 'p';
    strproc = [strproc,'_Res',fss,'Hz'];
end
%---- CROP WINDOW
if trialopt.redef.do==1
    if ~isempty(trialData)
        cfg        = [];
        cfg.toilim = trialopt.redef.win;
        trialData  = ft_redefinetrial(cfg, trialData);
    end
    win = trialopt.redef.win;
    winst = cell(1,2);
    winst{1} = ['m',num2str(abs(win(1)))];
    winst{1}(winst{1}=='.') = 'p';
    winst{2} = num2str(win(2));
    winst{2}(winst{2}=='.') = 'p';
    strproc = [strproc,'_Crop',winst{1},'to',winst{2},'s'];
end
if ~isempty(trialData)
    newtrialData = trialData;
end

                        
function trialopt = check_trialopt(trialopt)
% -----
% Check for low-pass filter option
if isfield(trialopt,'LPfilt') && isfield(trialopt.LPfilt,'do')
    if ~isempty(trialopt.LPfilt.do) && (trialopt.LPfilt.do==1 || trialopt.LPfilt.do==0)
        if trialopt.LPfilt.do 
            if isfield(trialopt.LPfilt,'fc')
                if length(trialopt.LPfilt.fc)==1
                    fc=trialopt.LPfilt.fc;
                    if fc==0
                        trialopt.LPfilt.do = 0;
                    else
                        disp(['Low-pass filter apply to trials with fc= ',num2str(fc),' Hz'])
                    end
                else
                    disp('----!!!!----')
                    disp('Bad option for low-pas frequency')
                    disp('trialopt.LPfilt.fc must be a scalar (fc in Hz)')
                    disp('Trials won''t be filtering')
                    trialopt.LPfilt.do = 0;
                end
            else
                disp('----!!!!----')
                disp('Bad option for redefined window')
                disp('trialopt.LPfilt.fc not defined')
                disp('Trials won''t be filtering')   
                trialopt.LPfilt.do = 0;
            end
        end
    else
        trialopt.LPfilt.do = 0;
    end
else
    trialopt.LPfilt.do = 0;
end

% -----
% Check for resampling option
if isfield(trialopt,'resamp') && isfield(trialopt.resamp,'do')
    if ~isempty(trialopt.resamp.do) && (trialopt.resamp.do==1 || trialopt.resamp.do==0)
        if trialopt.resamp.do 
            if isfield(trialopt.resamp,'fs')
                if length(trialopt.resamp.fs)==1
                    fs=trialopt.resamp.fs;
                    if fs==0
                        trialopt.resamp.do = 0;
                    else
                        disp(['Resample apply to trials with new fs= ',num2str(fs),' Hz'])
                    end
                else
                    disp('----!!!!----')
                    disp('Bad option for resample frequency')
                    disp('trialopt.resamp.fs must be a scalar (fs in Hz)')
                    disp('Trials won''t be resampling')
                    trialopt.resamp.do = 0;
                end
            else
                disp('----!!!!----')
                disp('Bad option for resample frequency')
                disp('trialopt.resamp.fs not defined')
                disp('Trials won''t be resampling')   
                trialopt.resamp.do = 0;
            end
        end
    else
        trialopt.resamp.do = 0;
    end
else
    trialopt.resamp.do = 0;
end  

% -----
% Check for redefined option
if isfield(trialopt,'redef') && isfield(trialopt.redef,'do')
    if ~isempty(trialopt.redef.do) && (trialopt.redef.do==1 || trialopt.redef.do==0)
        if trialopt.redef.do 
            if isfield(trialopt.redef,'win')
                if length(trialopt.redef.win)==2
                    win=trialopt.redef.win;
                    if win(1)==0 && win(2)==0
                        trialopt.redef.do = 0;
                    else
                        disp(['Trials redefined for time window : [ ',num2str(win(1)),' ',num2str(win(2)),' ] s'])
                    end
                else
                    disp('----!!!!----')
                    disp('Bad option for redefined window')
                    disp('trialopt.redef.win must be a vector : [t_prestim t_postim]')
                    disp('Trial window will be keep as it is by now')
                    trialopt.redef.do = 0;
                end
            else
                disp('----!!!!----')
                disp('Bad option for redefined window')
                disp('trialopt.redef.win not defined')
                disp('Trial window will be keep as it is by now')   
                trialopt.redef.do = 0;
            end
        end
    else
        trialopt.redef.do = 0;
    end
else
    trialopt.redef.do = 0;
end