function datapath = filepath4d(dirpath, dtyp)
% Return full access path to MEG (4D data) or S/EEG data in the
% directory specified by 'dirpath' path.
% dtyp is an optionnal parameter that indicates the data type to find in the
% search directory.
%
% dtyp values according to the requested data file type:
%   'raw'    : raw data ("c,rfDC")
%   'rawcor' : raw data with noise correction ("c,rfDC,n") [default]
%   'filt'   : filtered data ("c,rf*Hz")
%   'filtcor': filetered data with noise correction ("c,rf*Hz*n")
%   'seeg'   : S/EEG data with .eeg file extent
%
% If dtyp string is not supplied or empty, data will be searched with this
% default order (as soon as corresponding data is found, searching stops):
% (1) 'c,rfDC,n' : MEG 4D raw data with noise reduction (<=> dtyp = 'rawcor') 
% (2) 'c,rfDC'   : MEG 4D raw data ('raw')
% (3) 'c,rf*Hz*n': MEG 4D filtered with noise reduction ('filtcor')
% (4) 'c,rf*Hz'  : MEG 4D filtered ('filt')
% (5) '*.eeg'    : S/EEG data ('seeg')
% The path of the first found file is return.
%
%______
%-CREx 20131030 
%-CREx-BLRI-AMU project: https://github.com/blri/CREx_MEG/fieldtrip_process

rawdatanam = {'c,rfDC,n', 'c,rfDC', 'c,rf*Hz*n', 'c,rf*Hz', '*.eeg'}; 
dtypnam = {'rawcor', 'raw', 'filtcor', 'filt', 'seeg'};

if nargin==2 && isempty(dtyp) && sum(strcmp(dtyp,dtypnam))==1
    datnam = rawdatanam{strcmp(dtyp,dtypnam)==1};
    dpath = [dirpath,filesep,datnam];
    dp = dir(dpath);
    if isempty(dp)
        disp('!!')
        disp(['4D (or seeg) data "',datnam,'" not found in directory :'])
        disp(dirpath)
        disp(' ')
        datapath = [];
    else
        datapath = [dirpath,filesep,dp(1).name];
    end
else
    % Recherche des fichiers 4D par defaut
    goon = 1;
    i = 1;
  
    while goon && i<=length(rawdatanam)
        dpath = [dirpath,filesep,rawdatanam{i}];
        dp = dir(dpath);        
        if ~isempty(dp)
            datapath = [dirpath,filesep,dp(1).name];
            goon = 0;
        end
        i = i+1;
    end
    if goon==1
        disp('!!')
        disp('4D (or seeg) data not found in directory :')
        disp(dirpath)
        disp(' ')
        datapath = [];
    end
end
if ~isempty(datapath)
    [T,fnam] = fileparts(datapath); %#ok
    disp(' ')
    disp(['---- Found : ',fnam]), disp(' ')
end