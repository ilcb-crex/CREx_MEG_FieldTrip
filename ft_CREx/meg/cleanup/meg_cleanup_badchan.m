function badopt = meg_cleanup_badchan(dpath,badopt)

disp('------')
fprintf('\n\nCheck for recording - Input of bad channel\n\n')

fprintf('\nProcessing of data in :\n%s\n\n', dpath);


badopt.dirpath = dpath;

if isfield(badopt,'prevCHANstr') && length(badopt.prevCHANstr)>1
    disp(' '), disp('----')
    disp('Channels selection for the previous data set :')
    disp(badopt.prevCHANstr(2:end)), disp(' ')
    disp(' ')
    disp('For this new recording :')
    disp('Keep this selection   -> 1')
    disp('Select a new one      -> 2')
    rep = input('                      -> ');
    disp(' ')
    if rep==1
        CHANstr = badopt.prevCHANstr;
    else
        CHANstr = meg_check_chan(badopt);
    end
else
    CHANstr = meg_check_chan(badopt);
end

badopt.prevCHANstr = CHANstr;

if ~isfield(badopt,'datatyp') || isempty(badopt.datatyp) 
    badopt.datatyp = '4d';
end


if length(CHANstr)>1  % Seulement s'il faut oter des capteurs
    fprintf('\n\t-------\nLoad dataset\n\t-------\n')
    if strcmpi(badopt.datatyp,'4d')==1
        ftData = meg_extract4d(badopt.dirpath);
    else
        pdat = dirlate(badopt.dirpath,[badopt.datatyp,'*.mat']);
        if ~isempty(pdat)
            ftData = loadvar(pdat,'*Data*');
        else
            CHANstr = [];
        end
    end
end


if length(CHANstr)>1
    cfg = [];
    cfg.channel = CHANstr;
    ftDataOK = ft_preprocessing(cfg,ftData);       

    %_____
    % Figures of removed channels
    figure
    set(gcf,'units','centimeters','position',[1 1 24.6 9.25])
    set(gca,'units','centimeters','position',[2.25 1.1 20.4 6.3])
    xlabel('Time (s)','fontsize',13)
    hold on; box on;
    tit=cell(2,1);
    tit{2} = dpath;

    for nbc=2:length(CHANstr)
        bad = CHANstr{nbc}(2:end);
        cfg.channel = bad;
        ftDataKO = ft_preprocessing(cfg, ftData);
        tit{1}=['BAD channel ',bad,' : removed from dataset'];
        p=plot(ftDataKO.time{1},ftDataKO.trial{1});
        xlim([ftDataKO.time{1}(1) ftDataKO.time{1}(end)])
        ylabel('Magnetic field (T)','fontsize',13)
        title(tit,'fontsize',14,'interpreter','none')
        set(gca,'fontsize',13)
        verif_label
        ppdir = make_dir(fullfile(dpath, '_preproc'), 0);
        export_fig([ppdir,filesep,'BADchan_',bad,'.jpeg'],'-m1.5') 
        % Good figures but too long (the idea is to process a set
        % of data)
        delete([p;gca])
    end
    close
    namsav = ['_',num2str(length(CHANstr)-1),'rmS'];
else
    namsav='';
end

%_____
% Save new data
if strcmpi(badopt.datatyp,'4d')==1
    ftDataOK.CHANstr = CHANstr;
    S=struct;
    S.(['rawData',namsav]) = ftDataOK;  %#ok
    save([dpath,filesep,'rawData',namsav],'-struct','S')
    disp(' '),disp('New data saved as ----')
    disp(['----> ',dpath,filesep,'rawData',namsav]),disp(' ')
else
    if length(CHANstr)>1
        [T,nmat] = fileparts(pdat); %#ok
        newsuff = meg_matsuff(nmat,namsav);
        ftDataOK.CHANstr = CHANstr;
        S = struct;
        S.([badopt.datatyp,'Data_',newsuff]) = ftDataOK; %#ok
        save([dpath,filesep,badopt.datatyp,'Data_',newsuff],'-struct','S') 
        disp(' '),disp('New data saved as ----')
        disp(['----> ',dpath,filesep,badopt.datatyp,'Data_',newsuff]),disp(' ')
    end
end


