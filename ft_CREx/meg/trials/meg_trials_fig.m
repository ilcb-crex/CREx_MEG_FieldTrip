function meg_trials_fig(trials,pathmat,namevent,fdos)

if nargin<3
    namevent='Event';
end
if nargin<4
    sav=0;
else
    sav=1;
end

warning off MATLAB:tex % M7.5 Disable unjustified warning messages

namevt=['[ ',namevent,' ]'];
namevt(namevt=='_')='-';

t_trial = trials.time;
x_trial = trials.trial;
chanlabel = trials.label;
if isfield(trials,'trialinfo')
	trigval=trials.trialinfo;
else
    trigval = [];
end
nchan=length(chanlabel);
nlig=ceil(sqrt(nchan));
Mtranst=repmat((0:nlig-1)',1,nlig);
Mtransx=repmat((nlig*2-1:-2:1),nlig,1);
for nt=1:length(x_trial)
    nums=num2str(nt);
    if length(nums)==1
        trialnum=['0',nums];
    else
        trialnum=nums;
    end
    t=t_trial{nt};
    x=x_trial{nt};
    tt=t-t(1);
    tt=tt.*0.8./(tt(end));
    maxabs=max(abs(x'))';
    mina=min(maxabs);
    maxa=max(maxabs);

    cpmap=colormap('jet');
    inc=(maxa-mina)/(length(cpmap(:,1))-1);
    dec=mina:inc:maxa;

    % Figure des donnees par channel pour chaque trial
    figure, set(gcf,'visible','off','units','centimeters','position',[8 1 30 24])
    set(gca,'position',[.05 .05 .88 .88])
    xlim([0 nlig]), ylim([0 nlig*2])
    axis off
    hold on
    for sub=1:nchan
        ts=tt+Mtranst(sub);
        xs=x(sub,:).*0.6./maxabs(sub)+Mtransx(sub);
        col=cpmap(find(dec>=maxabs(sub),1,'first'),:);
        plot(ts,xs,'color',col)
        text(Mtranst(sub),Mtransx(sub)+.9,chanlabel{sub})
    end
    h=colorbar('south');
    stick=num2str(dec(get(h,'xtick'))');

    set(h,'position',[0.0584 0.0202 0.8576 0.01],...   
        'xaxisLocation','bottom','xticklabel',stick)
    set(get(h,'title'),'String',...
        'Maximum absolute value of trial (T)','fontsize',12)
    if ~isempty(trigval)
    	trigs=[' - Trigger value [ ',num2str(trigval(nt)),' ] - ']; 
    else
        trigs = ' - ';
    end
    titfig={[namevt,trigs,'Trial [ ',trialnum,...
        ' ] - Extracted from dataset : '];pathmat};
    idt=title(titfig,'interpreter','none','fontsize',13);
    post=get(idt,'position');
    set(idt,'position',[post(1) 33 post(3)])

    namfig=['TrialPlot_',namevent,'_',trialnum];
    
    if sav==1
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
        close
    end

    v=mina-1e-13:1e-13:maxa+1e-13;
    count=histc(maxabs,v);

    % Figure de l'histogramme des valeurs absolues maximum par
    % canal et de la superposition des donnees des canaux
    figure, set(gcf,'visible','off','units','centimeters','position',[2 10 21 10.5])

    subplot(121)
    set(gca,'units','centimeters','position',[2.7 1.2 7 6.8]);
    h=bar(v,count); 
    set(h,'barwidth',1,'facecolor',[0 .5 .4]);
    title({'Histogram of maximum absolute','amplitude values per channel'})
    xlabel('Maximum absolute value (T)')
    ylabel('Number of channels')
    verif_label

    subplot(122)
    set(gca,'units','centimeters','position',[12 1.2 7 6.8]);
    plot(t,x) 
    hold on, 
    plot([0 0],ylim,'r:')
    xlim([t(1) t(end)])
    xlabel('Time (s)   [ t = 0s  : TRIGGER ]')
    ylabel('Magnetic field (T)')
    
    title({'Superimposition of trial per channel';'and mean value (red)'})
    annotation(gcf,'textbox','String',titfig,'interpreter','none',...
        'FontSize',11,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);
    verif_label
    
    namfig=['HistSupPlot_',namevent,'_',trialnum];
    if sav==1
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
        close
    end
end
warning on MATLAB:tex
