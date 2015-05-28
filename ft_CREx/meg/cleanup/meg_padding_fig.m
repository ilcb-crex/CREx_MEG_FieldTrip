function meg_padding_fig(cleanpadData,ftData,fdos)
tit=cell(2,1);
tit{2}=fdos;
[T,ind]=sort(max(abs(ftData.trial{1}),[],2)); %#ok
for nf=1:3
    nc=ind(end-nf+1);
    tit{1}=['Exemple of padding-artefact result : ',ftData.label{nc}];
    figure
    set(gcf,'units','centimeter','position',[1 1 27 17])

    subplot(211),  
    plot(cleanpadData.time{1},cleanpadData.trial{1}(nc,:))
    title(tit,'fontsize',14,'interpreter','none')
    xlabel('Time (s)','fontsize',14)
    ylabel('Magnetic field (T)','fontsize',14)
    set(gca,'fontsize',14)
    xlim([ftData.time{1}(1) ftData.time{1}(end)])
    %verif_label

    subplot(212), plot(ftData.time{1},ftData.trial{1}(nc,:))
    xlim([ftData.time{1}(1) ftData.time{1}(end)])
    xlabel('Time (s)','fontsize',14)
    ylabel('Magnetic field (T)','fontsize',14)
    set(gca,'fontsize',14)
    %verif_label
    put_figtext('B) Original data','nw',12,[1 1 1],[0 0 0]);
    pos=get(gca,'position');
    set(gca,'position',[pos(1) pos(2)+.05 pos(3:4)])

    subplot(211), put_figtext('A) Padded artefacts','nw',12,[1 1 1],[0 0 0]);
    export_fig([fdos,filesep,'PadArt_',ftData.label{nc},'.jpeg'],'-m1.5')
    close
end