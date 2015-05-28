function meg_ICAavg_fig(comp_MEGdata,avgcomp,condnam,fdos,pathmat)
% Special function to generate figures of ICA :
% Topographic + temporal (5 components per figure)
%
% comp_MEGdata : original ICA-components data structure, created by
%   FieldTrip "ft_componentanalysis"
%
% avgcomp : average ICA-components obtained from "ft_timelockanalysis", and
%   associated to one condition
%
% condnam : name of this specific condition [Default : "Cond"]
%
% fdos : directory where to save the figures [Default : pwd]
%
% pathmat : full path of ICA component data file which has been use to
% average over trials [Default : '']
%

if nargin<5
    tit=cell(1,1);
else
   [pdat,ndat]=fileparts(pathmat);
   tit=cell(3,1);
   tit{2}=ndat;
   tit{3}=['datapath = ',pdat];
end

if nargin<4
    fdos=pwd;
end
if nargin<3
    condnam='Cond';
end

condnam(condnam=='_')='-';
condnamf=['[ ',condnam,' ]'];


lgc = length(comp_MEGdata.label);
nbp = 5; % Une figure par 5 composantes
vfig = 1:nbp:lgc;
for nf = 1:length(vfig)
    nfs=num2str(nf);
    if length(nfs)==1
        nfss=['0',nfs];
    else
        nfss=nfs;
    end
    figure 
    set(gcf,'units','centimeters','position',[6 2 15 25])
    for ns=1:nbp
        numcomp = vfig(nf)+ns-1;
        if numcomp <= lgc
            cfg=[];
            cfg.component = numcomp;
            cfg.layout    = '4D248.lay';
            cfg.comment   = 'no';
            subplot(nbp,3,(ns-1)*3+1)
            ft_topoplotIC(cfg,comp_MEGdata);
            pos=get(gca,'position');
            set(gca,'position',[.05 pos(2:4)])
            subplot(nbp,3,(ns-1)*3+2:(ns-1)*3+3)
            plot(avgcomp.time,avgcomp.avg(numcomp,:))
            pos=get(gca,'position');
            set(gca,'position',[pos(1)-0.06 pos(2) pos(3)+0.1 pos(4)]) 
            ylabel('Magnetic field (T)','fontsize',11)
            xlabel('Time (s)','fontsize',11)
            set(gca,'fontsize',11)
            yl=ylim;
            hold on, plot([0 0],yl,'--r','linewidth',1)
        end
    end
    if numcomp >= lgc
        iend=lgc;
    else
        iend=numcomp;
    end

    tit{1}=[condnamf,' - Average trial on ICA Components [',num2str(nf),']'];
    annotation(gcf,'textbox','String',tit,'interpreter','none',...
        'FontSize',10,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);
    namfig = ['AvgCompoPlot_',condnam,'_',nfss,'_comp_',num2str(vfig(nf)),'_to_',num2str(iend)];
    export_fig([fdos,filesep,name_save(namfig),'.jpeg'],'-m1.5')
    close
end