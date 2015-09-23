function meg_zcondrun_fig(dat,fdos,subjpath,navgmat)
if ~isfield(dat,'modal')
    modal='All';
    modaltit='';
else
    modal=dat.modal;
    modal(modal=='_')='-';
    modaltit=['[ ',modal,' ] - '];
end

allfnam=dat.fnam; % Noms des conditions differentes
allrun=dat.run;   % Numero des runs pour chaque moyenne des essais
allz=dat.z;   % Moyenne des essais
allzm2=dat.zm2; % Moyenne des essais en valeur absolue
time=dat.time;       % Vecteur temps des essais

[funiq,T,c]=unique(allfnam); %#ok

[path,subjnam]=fileparts(subjpath); %#ok
% Des figures avec 9 subplots par defaut
nfig=ceil(length(funiq)./9); % Devrait etre = 1    

%___
% Figures of mean signal of trials and mean absolute signal of trials
% One subplot is done per condition
% If more than one run present the same condition, signal of each run are
% superimposed on the subplot.

avgt={allz;allzm2};
titt={'Average','Square average'};
tittaj={' (all channels) ',' (mean of all channel) '};
savt={'all','m2'}; 
ylab={'Norm. magnetic field','Sqr norm. magnetic field'};
loct={'southwest','northwest'};
for ntyp=1:length(avgt)
    nu=1;
    for nf=1:nfig
        figure
        set(gcf,'units','centimeters','position',[2 -9 38 25]);
        if nf==1 && ntyp==1
            colcol=get(gca,'colororder');
            colc=[colcol ; [colcol(:,[2 3]) abs(colcol(:,1)-.2)] ; abs(1-colcol-.6)];
        end
        yl=NaN(9,2);
        for nsub=1:9
            if nu<=length(funiq)
                ucond=funiq{nu};
                subplot(3,3,nsub),hold on
                idind=find(c==nu);
                leg=cell(length(idind),1);
                for nsam=1:length(idind)
                    run=allrun(idind(nsam));
                    pl=plot(time,avgt{ntyp}{idind(nsam)},'color',colc(run,:));
                    if length(pl)<10
                        set(pl,'linewidth',1.5)
                    end
                    leg{nsam}=['Run°',num2str(run)];
                end
                if nsam>1
                    legh=legend(leg,'location',loct{ntyp});
                    set(legh,'fontsize',9)
                end
                yl(nsub,:)=ylim;
                grid on
                set(gca,'xminorgrid','on')
                box on
                xlabel('Time (s)','fontsize',12)
                ylabel(ylab{ntyp},'fontsize',12)
                ucondt=ucond;
                ucondt(ucondt=='_')='-';
                title(['[ ',ucondt,' ]'],'fontsize',12)
                set(gca,'fontsize',12)                
            end
            nu=nu+1;
        end
        for nsub=1:9
            yll=yl(~isnan(yl(:,1)),:);
            if ~isnan(yl(nsub,1))
                subplot(3,3,nsub),
                plot([0 0],[min(yll(:,1)) max(yll(:,2))],'r--','linewidth',1)
                ylim([min(yll(:,1)) max(yll(:,2))])
                verif_label
            end
        end
        titfig=[modaltit,titt{ntyp},' source signal Z per condition',tittaj{ntyp},': ',subjpath,' using ',navgmat];
        annotation(gcf,'textbox','String',titfig,'interpreter','none','FontSize',13,...
            'fontname','AvantGarde','fontweight','bold',...
            'LineStyle','none','HorizontalAlignment','center',...
            'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);
        
        export_fig([fdos,filesep,'AvgCond_Z',savt{ntyp},'_',modal,'_',subjnam,'_',num2str(nf),'.jpeg'],'-m1.5','-zbuffer')
        close
    end
end

%____
% Figure superposition

% One color per specific condition, the same for all runs showing this
% condition
ntyp=2;
leg=cell(length(funiq),1);
figure
box on
set(gcf,'units','centimeters','position',[15 9 20 13])
hold on
for nu=1:length(funiq)
    ucond=funiq{nu};
    idind=find(c==nu);
    for nsam=1:length(idind)
        pl=plot(time,avgt{ntyp}{idind(nsam)},'color',colc(nu,:));
        set(pl,'linewidth',1)
    end
     if length(idind)>1
         leg{nu}=[ucond, ' (',num2str(length(idind)),' runs)'];
     else
         leg{nu}=[ucond, ' (',num2str(length(idind)),' run)'];
     end
end
legh=legend(leg,'location',loct{ntyp});
set(legh,'fontsize',10,'interpreter','none')
xlabel('Time (s)','fontsize',12)
ylabel(ylab{ntyp},'fontsize',12)
titfig={[modaltit,titt{ntyp},' source signal Z per condition',tittaj{ntyp},': '];...
    [subjpath,' using ',navgmat]};
title(titfig,'fontsize',12,'interpreter','none')
set(gca,'fontsize',12)
verif_label
yl=ylim;
grid on
set(gca,'xminorgrid','on')
hold on, plot([0 0],[yl(1) yl(2)],'r:','linewidth',1.5)
export_fig([fdos,filesep,'AvgCondSup_Z',savt{ntyp},'_',modal,'_',subjnam,'.jpeg'],'-m1.5')
close  
