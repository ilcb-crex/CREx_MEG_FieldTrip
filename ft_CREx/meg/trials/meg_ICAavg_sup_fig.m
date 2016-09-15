function meg_ICAavg_sup_fig(comp_MEGdata, avgcompS, fdos, pathmat)
% Special function to generate figures of ICA :
% Topographic + temporal (5 components per figure)
%
% comp_MEGdata : original ICA-components data structure, created by
%   FieldTrip "ft_componentanalysis"
%
% avgcompS : structure with sub-structures. One field per experimental
%   conditions. Each field contains the structure of the average ICA-components 
%   obtained from "ft_timelockanalysis" for the specific condition
%
% condnam : name of this specific condition [Default : "Cond"]
%
% fdos : directory where to save the figures [Default : pwd]
%
% pathmat : full path of ICA component data file which has been use to
% average over trials [Default : '']
%

if nargin<4
    tit = cell(1,1);
else
   [pdat,ndat] = fileparts(pathmat);
   tit = cell(3,1);
   tit{2} = [ndat,'.mat'];
   tit{3} = ['datapath = ',pdat];
end

if nargin<3
    fdos = pwd;
end

fnam = fieldnames(avgcompS);

lgc = length(comp_MEGdata.label);

nba = length(fnam);

colc = color_group(nba);

nbp = 5; % Une figure par 5 composantes
vfig = 1:nbp:lgc;
for nf = 1:length(vfig)
    nfs = num2str(nf);
    if length(nfs)==1
        nfss = ['0',nfs];
    else
        nfss = nfs;
    end
    figure 
    set(gcf,'units','centimeters','position',[6 2 15 25])
    for ns = 1:nbp
        numcomp = vfig(nf)+ns-1;
        if numcomp <= lgc
            cfg=[];
            cfg.component = numcomp;
            cfg.layout    = '4D248.lay';
            cfg.comment   = 'no';
            subplot(nbp,3,(ns-1)*3+1)
            ft_topoplotIC(cfg,comp_MEGdata);
            pos = get(gca,'position');
            set(gca,'position',[.05 pos(2:4)])
            subplot(nbp,3,(ns-1)*3+2:(ns-1)*3+3), hold on
            for na = 1:nba
                plot(avgcompS.(fnam{na}).time, avgcompS.(fnam{na}).avg(numcomp,:), 'color',colc(na,:))
            end
            pos = get(gca,'position');
            set(gca,'position',[pos(1)-0.06 pos(2) pos(3)+0.1 pos(4)]) 
            ylabel('Magnetic field (T)','fontsize',11)
            xlabel('Time (s)','fontsize',11)
            set(gca,'fontsize',11)
            yl = ylim;
            hold on, plot([0 0],yl,'--r','linewidth',1)
            box on
        end
    end
    if numcomp >= lgc
        iend = lgc;
    else
        iend = numcomp;
    end
    put_leg(fnam,colc)
    tit{1} = [' Average trial on ICA Components [',num2str(nf),']'];
    annotation(gcf,'textbox','String',tit,'interpreter','none',...
        'FontSize',10,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);
    namfig = ['AvgCompoPlot_SupCond_',nfss,'_comp_',num2str(vfig(nf)),'_to_',num2str(iend)];
    export_fig([fdos,filesep,name_save(namfig),'.jpeg'],'-m1.5')
    close
end

function put_leg(legcell,col)
lig = '^{\_\_ }'; 
for s = 1:length(legcell)
    legcell{s}(legcell{s}=='_') = '-';
    if s==1
        strtext = ['\color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s}];
    else
        strtext = [strtext,'  \color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s}]; %#ok
    end
end
annotation(gcf,'textbox','String',strtext,...
    'interpreter','tex','LineStyle','none',...
    'fontsize',11,'fontweight','bold',...
    'position',[0.1805 0.0263 0.7949 0.0382]);   % La dimension doit etre assez grande pour avoir le texte interprete en TeX