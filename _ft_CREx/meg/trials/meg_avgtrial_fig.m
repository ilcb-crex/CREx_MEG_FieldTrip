function meg_avgtrial_fig(avgtrial,pathtrials,namcond,fdos)

if nargin<3
    namcond='Condition';
end
if nargin<4
    sav=0;
else
    sav=1;
end

warning off MATLAB:tex % M7.5 Disable unjustified warning messages

namcondt=['[ ',namcond,' ]'];
namcondt(namcondt=='_')='-';

t_trial = avgtrial.time;
x_trial = avgtrial.avg;
chanlabel = avgtrial.label;
nchan=length(chanlabel);
nlig=ceil(sqrt(nchan));
Mtranst=repmat((0:nlig-1)',1,nlig);
Mtransx=repmat((nlig*2-1:-2:1),nlig,1);

tt=t_trial-t_trial(1);
tt=tt.*0.8./(tt(end));
maxabs=max(abs(x_trial'))';
mina=min(maxabs);
maxa=max(maxabs);



% Figure des donnees par channel pour chaque trial
figure, set(gcf,'visible','off','units','centimeters','position',[8 1 30 24])
set(gca,'position',[.05 .05 .88 .88])
cpmap=colormap('jet');
inc=(maxa-mina)/(length(cpmap(:,1))-1);
dec=mina:inc:maxa;
xlim([0 nlig]), ylim([0 nlig*2])
axis off
hold on
for sub=1:nchan
    ts=tt+Mtranst(sub);
    xs=x_trial(sub,:).*0.6./maxabs(sub)+Mtransx(sub);
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
titfig={[namcondt,' - Average of trials - Extracted from dataset : '];pathtrials};
idt=title(titfig,'fontsize',13,'interpreter','none');
post=get(idt,'position');
set(idt,'position',[post(1) 33 post(3)])



if sav
    namfig=['AvgTrial_ChanPlot_',namcond];
    export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
    close
end

% Figure des superpositions des moyennes et de la moyenne des essais au
% carre a travers tous les canaux
figure, set(gcf,'visible','off','units','centimeters','position',[2 10 21 10.5])

subplot(121)
set(gca,'units','centimeters','position',[2.7 1.2 7 6.8]);
plot(t_trial,x_trial) %,'k',t_trial,mean(x_trial),'r','linewidth',1)
hold on, plot([0 0],ylim,'r:')
xlabel('Time (s)   [ t = 0s  : TRIGGER ]')
ylabel('Magnetic field (T)')
xlim([t_trial(1) t_trial(end)])
title({'Superimposition of average trials per channel';'and mean value (red)'})
verif_label

subplot(122)
set(gca,'units','centimeters','position',[12 1.2 7 6.8]);
plot(t_trial,mean(x_trial.^2),'color',[.4 .4 .4],'linewidth',1)
hold on, plot([0 0],ylim,'r:')
xlabel('Time (s)   [ t = 0s  : TRIGGER ]')
ylabel('Square magnetic field (T^2)')
xlim([t_trial(1) t_trial(end)])
title({'Mean square value of all trials';' '})
verif_label

annotation(gcf,'textbox','String',titfig,'interpreter','none',...
    'FontSize',11,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);

if sav
    namfig=['AvgTrial_SupPlot_',namcond];
    export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5','-zbuffer')
    close
end

warning on MATLAB:tex
