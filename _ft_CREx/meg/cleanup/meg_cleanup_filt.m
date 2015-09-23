function meg_cleanup_filt(path,filtopt)

fprintf('\n\t\t-------\nApply filter on dataset\n\t\t-------\n')
fprintf('\nProcessing of data in :\n%s\n\n', path);
        
[pmat,nmat] = dirlate(path,'rawData*.mat');

% Extract data from raw 4D file if rawData*.mat not found 
if isempty(pmat)
    rawData = meg_extract4d(path);
    pmat = '4D file';
else
    rawData = loadvar(pmat,'*Data*');
end
if ~isempty(rawData)
    disp(' '), disp('Input data :')
    disp(pmat), disp(' ')
    
    % Check for filtopt options
    filtopt = meg_filtopt(filtopt);
    
    % Apply filter
    filtData = meg_filt_dataset(rawData,filtopt);

    fopt=filtopt.type;
    fc=filtopt.fc;
    if ~strcmp(fopt,'none') && ~isempty(filtData)
        % Save the FieldTrip structure of the filtered data
        fstri=['fc',upper(fopt),'_'];
        if numel(fc)==1
            fstr=[fstri,num2str(fc),'Hz'];
        else
            fstr=[fstri,num2str(fc(1)),'_',num2str(fc(2)),'Hz'];
        end
        fstr(strfind(fstr,'.'))='p'; 
        newsuff = meg_matsuff(nmat,fstr);
        save([path,filesep,'filtData_',newsuff],'filtData')

        if filtopt.figflag==1
            % Make some figures of the results
            meg_filt_fig(filtData,rawData,filtopt,path,1:3) 
            % 1:3 : index of the channels to be plotted
        end
    end
else
    disp('Data not found...')
    disp(' ')
end