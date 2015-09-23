function meg_filt_fig(filtData,rawDataOK,filtopt,fdos,vind)
% Make and save figures of filtered data compare to raw data
%
fopt=filtopt.type;
fc=filtopt.fc;
fstri=['fc',upper(fopt),'_'];
if numel(fc)==1
    fstr=[fstri,num2str(fc),'Hz'];
    if strcmpi(fopt,'hp')
        figs=['High-Pass : ',num2str(fc),' Hz'];
    else
        figs=['Low-Pass : ',num2str(fc),' Hz'];
    end
else
    fstr=[fstri,num2str(fc(1)),'_',num2str(fc(2)),'Hz'];
    figs=['Band-Pass : [',num2str(fc(1)),' - ',num2str(fc(2)),' ] Hz'];
end
tit=cell(2,1);
tit{2}=fdos;
for nc=vind
    tit{1}=['Exemple of filtering result : ',filtData.label{nc}];
    figure
    set(gcf,'units','centimeter','position',[1 1 27 17])

    subplot(211), plot(filtData.time{1},filtData.trial{1}(nc,:))
    xlim([filtData.time{1}(1) filtData.time{1}(end)])
    xlabel('Time (s)','fontsize',14)
    ylabel('Magnetic field (T)','fontsize',14)
    set(gca,'fontsize',14)
    title(tit,'fontsize',14,'interpreter','none')
    subplot(212), plot(rawDataOK.time{1},rawDataOK.trial{1}(nc,:))
    xlim([filtData.time{1}(1) filtData.time{1}(end)])
    xlabel('Time (s)','fontsize',14)
    ylabel('Magnetic field (T)','fontsize',14)
    set(gca,'fontsize',14)
    verif_label
    put_figtext('B) Original data','nw',12,[1 1 1],[0 0 0]);
    pos=get(gca,'position');
    set(gca,'position',[pos(1) pos(2)+.05 pos(3:4)])
    hold on;

    subplot(211), put_figtext(['A) Filtered by ',figs],'nw',12,[1 1 1],[0 0 0]);
    verif_label    
    fsav=name_save(['filtData_',fstr,'_',filtData.label{nc}]);
    export_fig([fdos,filesep,fsav,'.jpeg'],...
        '-m1.5')
    close
end