function [pdata,ndata]=find_thismat(path, prefix, procsuffix)
% Special function to find MAT data file with the specific name :
%                  [prefix,'*',procsuffix,'*.mat']
%
% Regarding to the pre-processing done on trial signals before computing
% the model of source localisation, a suffix is adding to the name of the
% results, SourceModel*.mat; for example :
% SourceModel_LP40Hz_Res240Hz_Crop0p2to1.mat
% Here : procsuffix = '_LP40Hz_Res240Hz_Cropm0p2to1';
% (a LP filter with fc=40 Hz has been done, as well as a resampling at 240
% Hz and a re-definition of the trial temporal window from -0.2 to 1 s).
%
% If procsuffix is empty or not specified, the SourceModel*.mat obtained 
% without any special preprocessing of the trials is seeking. This is done
% by selecting the SourceModel*.mat which name doesn't contain the string
% 'LP', 'Res' or 'Crop'.
% If the "raw" results matrix is not found, the most recent one is selecting,
% regardless to its name.
%
% path : directory path where the data matrix is searched
% prefix : the prefix name of the matrix ('avg', 'clean', 'source'...)
% procsuffix : string of processing done as added 
%
% This function uses "dirlate.m" function (which returns the path of the 
% most recent file corresponding to the input name, found inside the search 
% directory.

            
namat=[prefix,'*',procsuffix,'*.mat'];
disp(' '), disp(['Search of : ',namat]), disp(' ')

dfil=dir([path,filesep,namat]);
            
if ~isempty(dfil)
    if length(dfil)>1
        ve=1:length(dfil);
        % Plusieurs matrices SourceModel*.mat trouvees :
        % tres probablement celle sans pre-traitement
        % (strproc=[]) et d'autres avec pre-traitement
        for nf=1:length(dfil)
            if ~isempty(strfind(dfil(nf).name,'LP')) && ...
                    ( isempty(procsuffix) || isempty(strfind(procsuffix,'LP')) )
                ve(nf)=0;
            end
            if ~isempty(strfind(dfil(nf).name,'Res')) && ...
                    ( isempty(procsuffix) || isempty(strfind(procsuffix,'Res')) )
                ve(nf)=0;
            end
            if ~isempty(strfind(dfil(nf).name,'Crop')) && ...
                    ( isempty(procsuffix) || isempty(strfind(procsuffix,'Crop')) )
                ve(nf)=0;
            end   
        end
        ve=ve(ve>0);
        if ~isempty(ve) && length(ve)==1
            namat=dfil(ve).name;
        end
    end
    [pdata,ndata]=dirlate(path,namat);
else
    disp(' '), disp('!!! MAT data not found'), disp(' ')
    pdata=[];
    ndata=[];
end
          