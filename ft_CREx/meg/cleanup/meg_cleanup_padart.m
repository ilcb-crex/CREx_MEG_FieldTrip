function meg_cleanup_padart(dpath)
% Removing the strong artefacts from the continuous data.
%
% --- CREx 201
% CREx-BLRI-AMU project:

fprintf('\n\t\t-------\nExclude strong artefact (on all channels) \n\t\t-------\n')
fprintf('\nProcessing of data in :\n%s\n\n',dpath);
        
[pmat,nmat] = dirlate(dpath,'filtData*.mat');
% Data are assumed to be filtered
if ~isempty(pmat)
    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')
    disp(' ')
    % Define the time windows of artefact to remove : wina
    wina = meg_padding_win;

    if ~isempty(wina)
        disp(' '); disp('Load data...')
        ftData = loadvar(pmat,'*Data*');

        % Eliminate artefacts defined by wina 
        cleanpadData = meg_padding_artefact(ftData, wina);

        % Save new data
        suff = [num2str(length(cleanpadData.artpad(:,1))),'rmA'];
        newsuff = meg_matsuff(nmat,suff);
        newnam = ['filtData_',newsuff];
        D = struct;
        D.(newnam) = cleanpadData; %#ok
        save([dpath, filesep, newnam],'-struct','D')
        clear D
        disp(' '),disp('New cleaned data saved as ----')
        disp(['----> ',dpath,filesep,newnam]),disp(' ')

        % Some figures of the results
        meg_padding_fig(cleanpadData,ftData,dpath)

        % Remove trials that are comprised on the time windows 
        % definition of artefacts
        pmat = dirlate(dpath,'cfg_event.mat');
        if isempty(pmat)
            pmat = dirlate(dpath,'cfg_rawData.mat');
            if isempty(pmat)
                fprintf('Reading of events by ft_definetrial\n\n')
                datpath = filepath4d(dpath);
                cfg_rawData = meg_disp_event(datpath);
            else
                cfg_rawData = loadvar(pmat,'cfg_rawData');
            end
            cfg_event = cfg_rawData.event;
        else
            load(pmat)
        end
        fs = ftData.fsample;
        disp(' ')
        disp('Remove events localised inside bad portion(s) of data')
        % 1 seconde ajoutee de part et d'autre de la fenetre 
        winpad = [cleanpadData.artpad(:,1)-fs cleanpadData.artpad(:,2)+fs];
        S = cfg_event;
        sval = cell2mat({S.sample})';
        for nw = 1:length(winpad(:,1))
            ide = find(sval>=winpad(nw,1) & sval<=winpad(nw,2));
            if ~isempty(ide)
                for e = 1:length(ide)
                    S(ide(e)).type = 'INSIDE_PADART';
                end
            end
        end
        cfg_event = S; %#ok
        save([dpath,filesep,'cfg_event.mat'],'cfg_event')
        disp(' '),disp('New cleaned events config saved as ----')
        disp(['----> ',dpath,filesep,'cfg_event.mat']),disp(' ')
    end
end