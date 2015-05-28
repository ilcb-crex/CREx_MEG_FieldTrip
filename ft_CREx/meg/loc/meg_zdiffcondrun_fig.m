function meg_zdiffcondrun_fig(datori,fdos,subjpath,navgmat)

if ~isfield(datori,'modal')
    modal = 'All';
    modaltit = '';
else
    modal = datori.modal;
    modal(modal=='_') = '-';
    modaltit = ['[ ',modal,' ] - '];
end

time = datori.time;
[path,subjnam] = fileparts(subjpath); %#ok

funiq = unique(datori.fnam); % Si plusieurs conditions identiques trouvees <=> plusieurs sessions pour la meme condition

% Separation par run
urun = unique(datori.run);
nbrun = length(urun);
srun = cell(nbrun,1);
for r=1:nbrun
    indr = find(datori.run==urun(r));
    dat = struct;
    dat.allfnam = datori.fnam(indr);  % Noms des conditions differentes
    dat.allrun = datori.run(indr);    % Numero des runs pour chaque moyenne des essais
    dat.allzm2 = datori.zm2(indr);% Moyenne des essais en valeur absolue
    srun{r} = dat;
end

% Nombre de combinaisons possibles pour faire la difference entre 2
% conditions
n_ele = length(funiq);
k = 2;
nbcomb = factorial(n_ele)./(factorial(k).*factorial(n_ele-k));

% Toutes les combinaisons de conditions possibles sont testees pour chaque
% run, la difference est tracee si la combinaison est trouvee dans les
% donnees du run
% allavgdiff=zeros(nbcomb,length(datori.time));
% allavgadiff=zeros(nbcomb,length(datori.time));
% alldiffnam=cell(nbcomb,1);
co=1;
runum=zeros(nbcomb,nbrun);
diffzM2=cell(nbcomb,nbrun);
combnam=cell(nbcomb,1);
for i=1:length(funiq)-1
    condnam1=funiq{i};
    for j=i+1:length(funiq)
        condnam2=funiq{j};
        combnam{co}=[condnam1,' - ',condnam2];
        for r=1:nbrun
            fc1=strcmpi(condnam1,srun{r}.allfnam);
            fc2=strcmpi(condnam2,srun{r}.allfnam);
            if sum(fc1)>0 && sum(fc2)>0 % Combinaison possible pour ce run
                diffzM2{co,r}=srun{r}.allzm2{fc1}-srun{r}.allzm2{fc2};
                runum(co,r)=srun{r}.allrun(1);
            end
        end
        co=co+1;
    end
end
                     
%___
% Figures of difference between two conditions 
% Difference of the mean signal of trials and difference of the mean 
% absolute signal of trials are plotted.
% One subplot is done per possible combinaison of differences between two
% conditions.
% If more than one run present the same condition, signal of each run are
% superimposed on the subplot.

% Des figures avec 12 subplots par defaut
nfig=ceil(nbcomb./12); % Devrait etre = 1

co=1;
for nf=1:nfig
    figure
    set(gcf,'units','centimeters','position',[2 -9 38 35]);
    if nf==1
        colcol=get(gca,'colororder');
        colc=[colcol ; [colcol(:,[2 3]) abs(colcol(:,1)-.2)] ; abs(1-colcol-.6)];
    end
    yl=NaN(12,2);
    for nsub=1:12
        if co<=nbcomb %#ok
            subplot(4,3,nsub),hold on
            irun=find(runum(co,:)>0);
            leg=cell(length(irun),1);
            for r=1:length(irun)
                pl=plot(time,diffzM2{co,irun(r)},'color',colc(runum(co,irun(r)),:));
                set(pl,'linewidth',1.5)
                leg{r}=['Run°',num2str(runum(co,irun(r)))];
            end
            if r>1
                legh=legend(leg,'location','northwest');
                set(legh,'fontsize',9)
            end
            yl(nsub,:)=ylim;
            grid on
            set(gca,'xminorgrid','on')
            box on
            xlabel('Time (s)','fontsize',12)
            ylabel('Sqr norm. source signal','fontsize',12)
            title(['[ ',combnam{co},' ]'],'interpreter','none','fontsize',12)
            set(gca,'fontsize',12)
        end
        co=co+1;
    end
    for nsub=1:12
        yll=yl(~isnan(yl(:,1)),:);
        if ~isnan(yl(nsub,1))
            subplot(4,3,nsub),
            plot([0 0],[min(yll(:,1)) max(yll(:,2))],'r--','linewidth',1)
            ylim([min(yll(:,1)) max(yll(:,2))])
            verif_label
        end
    end
    titfig=[modaltit,'Mean square normalized source signal differences between conditions : ',subjpath,' using ',navgmat];
    annotation(gcf,'textbox','String',titfig,'interpreter','none','FontSize',13,...
        'fontname','AvantGarde','fontweight','bold',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);

    export_fig([fdos,filesep,'DiffAvgCond_Zm2_',modal,'_',subjnam,'_',num2str(nf),'.jpeg'],'-m1.5','-zbuffer')
    close
end
dat=struct;
dat.diffavgzm2=diffzM2;
dat.runum=runum;
dat.combnam=combnam;
dat.time=time; %#ok
save([fdos,filesep,'DiffAvgZCond_',modal,'_',subjnam],'dat')