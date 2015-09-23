function meg_cleanup_rmICA(path, badcomp)
% Reject ICA component(s)
% path : path of the FieldTrip data folder, containing the continuous 
% data (filt*.mat) and the associated ICA components (ICAcomp*.mat) data
% badcomp : vector of component numbers to reject

if nargin == 1 
    ask = true;
else
    ask = false;
end
fprintf('\n\t-------\nRemove ICA component(s)\n\t-------\n')
fprintf('\nProcessing of data in :\n%s\n\n',path);

[pdata, ndata] = dirlate(path, 'filtData*.mat');
[pica, nica] = dirlate(path, 'ICAcomp*.mat');
if ~isempty(pdata) && ~isempty(pica)
    disp(' '), disp('Original dataset :')
    disp(ndata), disp(' ')
    disp(' '), disp('Original components :')
    disp(nica), disp(' ')   
    if ask
        % Ask for bad component to remove
        badcomp = meg_rmcomp_input;
    end
    if ~isempty(badcomp)
        cfg = [];
        cfg.component = badcomp;
        fprintf('\n\t-------\nICA components removing from data...\n\t-------\n')
        disp(['This components : ',num2str(badcomp)]), disp(' ')
        try
            ICAcomp = loadvar(pica,'comp*');
            MEGdata = loadvar(pdata,'*Data*');
            cleancompData = ft_rejectcomponent(cfg,ICAcomp,MEGdata);
            if isfield(MEGdata,'artpad')
                cleancompData.artpad=MEGdata.artpad;
            end
            cleancompData.badcomp=badcomp;

            % Save the new data structure
            suff=[num2str(length(badcomp)),'rmC'];
            newsuff = meg_matsuff(ndata,suff);
            newnam = [path, filesep,'cleanData','_',newsuff];
            dm = dir([newnam,'.mat']);
            if ~isempty(dm)
                newnam = [newnam,'_n'];
            end
            save(newnam,'cleancompData')
        catch
            disp('!!!!!!! Reject of component impossible !!!!!!!')
        end
    end
end