function meg_padding_fig(cleanpadData, ftData, fdos)
% Make figure of continuous data to see the padding artefact effects
% Subplot of the padding data vs the original data, for the 3 channels that
% displayed the most important amplitude before the artefact correction

Nart = length(cleanpadData.artpad(:,1));

% Figures will be save in the general "Preproc_fig" directory inside the
% data directory
ppdir = make_dir(fullfile(fdos, '_preproc'), 0);
tit = cell(2,1);
tit{2} = fdos;

time = ftData.time{1};
xdat = ftData.trial{1};
xpad = cleanpadData.trial{1};

% Plot the data at the first 3 channels displaying the max amplitude
[T,ind] = sort(max(abs(xdat),[],2)); %#ok


for nf = 1:3
    nc = ind(end-nf+1);
    tit{1}=['Exemple of padding-artefact result : ',ftData.label{nc}];
    figure
    set(gcf,'units','centimeter','position',[1 1 27 17])

    subplot(211) 
    plot(time, xpad(nc,:))
    title(tit,'fontsize',14,'interpreter','none')
    xlabel('Time (s)','fontsize',14)
    ylabel('Magnetic field (T)','fontsize',14)
    set(gca,'fontsize',14)
    xlim([time(1) time(end)])
    %verif_label

    subplot(212)
    plot(time, xdat(nc,:))
    xlim([time(1) time(end)])
    xlabel('Time (s)','fontsize',14)
    ylabel('Magnetic field (T)','fontsize',14)
    set(gca,'fontsize',14)
    %verif_label
    put_figtext('B) Original data','nw',12,[1 1 1],[0 0 0]);
    pos=get(gca,'position');
    set(gca,'position',[pos(1) pos(2)+.05 pos(3:4)])

    subplot(211), put_figtext('A) Padded artefacts','nw',12,[1 1 1],[0 0 0]);
    
    padnam = ['PadArt_',num2str(Nart), 'rmA_',ftData.label{nc}];
    
    export_fig([ppdir, filesep, padnam, '.jpeg'],'-m1.5')
    close
end