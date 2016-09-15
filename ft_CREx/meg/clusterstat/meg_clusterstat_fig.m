function meg_clusterstat_fig(SavgROI, clustROI, opt)

% opengl('OpenGLWobbleTesselatorBug',1)
% opengl('OpenGLLineSmoothingBug', 1)
% opengl('OpenGLBitmapZbufferBug', 1)
% Set default parameters
defopt = struct('savepath', pwd, 'grpname', [],...
    'iROI', 'all', 'mode', 'full', 'ylim', [], 'xlim', []);

if nargin < 2 || isempty(opt)
    opt = defopt;
else
    opt = check_opt(opt, defopt);
end

if ~isempty(opt.grpname)
    grpnam = [opt.grpname,'_'];
else
    grpnam = '';
end

if strcmp(opt.mode, 'fast')
    onlyWhenClust = true;
else
    onlyWhenClust = false;
end

cond = fieldnames(SavgROI);
Alab = SavgROI.(cond{1}).label;   
if isempty(opt.iROI) || (ischar(opt.iROI))
    iroi = 1 : length(Alab);
else
    iroi = opt.iROI;
end

% Set waves colors
colcond = color_group(length(cond));
col = struct;
for i = 1 : length(cond)
    col.(cond{i}) = colcond(i,:);
end

supcond = fieldnames(clustROI);

% Extract statisticals parameters
durTHR = clustROI.(supcond{1}).durTHR;
alphaTHR = clustROI.(supcond{1}).clustat.alphaTHR;
Nrand = clustROI.(supcond{1}).clustat.Nrand;
sparam = ['Nrnd=',num2str(Nrand), '; alphaTHR=',num2str(alphaTHR), '; durTHR=',num2str(durTHR.*1000,'%4d'),'ms'];

Sylim = det_ylim(SavgROI, iroi);
 % Absolute ylim is given
if ~isempty(opt.ylim)
    yabs = opt.ylim;
    % ylim given to be apply for all groups, per ROI
    if length(yabs(:,1)) == length(Alab)
        Sylim.ylim_allgrp_eachroi = yabs;    
        Sylim.ylim_allgrp_allroi = [min(yabs(:,1)) max(yabs(:,2))];
    else
        Sylim.ylim_allgrp_allroi = yabs;
    end
end
fylim = fieldnames(Sylim);

if isempty(opt.xlim)
    XL = [ SavgROI.(cond{1}).time(1) SavgROI.(cond{1}).time(end)];
else
    XL = opt.xlim;
end

if isfield(SavgROI.(cond{1}), 'confintROI')
    dispCI = true;
else
    dispCI = false;
end

ssubj = num2str(length(SavgROI.(cond{1}).subj));

p0 = opt.savepath;
for i = 1 : length(supcond)
    psav = make_dir([p0,filesep,supcond{i}],0);
    
    disp(supcond{i})
    % Identify the 2 conditions to superimpose
    spcond = strsplitt(supcond{i}, '_');
    avgR1 = SavgROI.(spcond{1}).avgROI;
    avgR2 = SavgROI.(spcond{2}).avgROI;
   
    time = SavgROI.(spcond{1}).time;

    colsup = [col.(spcond{1}); col.(spcond{2})];
   
    for n = 1 : length(iroi)  
        ir = iroi(n);
        numdip = SavgROI.(spcond{1}).numdip(ir);
        if numdip > 0
            Cavg = [avgR1(ir) ; avgR2(ir)];
            cdur = clustROI.(supcond{i}).dur{ir};
            
            if ~isempty(cdur)
                Clust.dur = cdur;
                Clust.itime = clustROI.(supcond{i}).itime{ir};
                Clust.pval = clustROI.(supcond{i}).pval{ir};
            else
                Clust = struct('dur',[],'itime',[]);    
            end
            if ~onlyWhenClust || (onlyWhenClust && ~isempty(Clust.dur))
                snum = ['(Ndip=',num2str(numdip), '; Nsubj=', ssubj, '; ', sparam,')']; 
                
                tit = {['Mean source signal in ', Alab{ir},' ROI'];
                    snum};
                if dispCI
                    Cci = [SavgROI.(spcond{1}).confintROI(ir)
                        SavgROI.(spcond{2}).confintROI(ir)];
                else
                    Cci = [];
                end

                for k = 1 : length(fylim)
                    ylimits = Sylim.(fylim{k});
                    if length(ylimits(:,1)) == length(Alab)
                        YL = ylimits(ir,:);
                    else
                        YL = ylimits;
                    end

                    ROIfig(time, Cavg, colsup, spcond, tit, Clust, XL, YL, Cci)
                    addsav = def_name({supcond{i} ;  Alab{ir}});
                    savnam = ['clustime_aROI_', grpnam, addsav,'_', fylim{k}];
                    export_fig([psav, filesep, savnam,'.jpg'],'-m2.5','-nocrop') %,'-zbuffer') %'.eps'
                   % export_fig([psav, filesep, savnam,'.eps'],'-nocrop')
                    plot2svg([psav, filesep, savnam,'.svg'])
                    close
                end
            end
        end 
    end
end

function ROIfig(time, yc, col, legstr, titstr, Clust, xlimit, ylimit, Cci)
    if ~isempty(Clust.dur)
        dur = Clust.dur;
        itime = Clust.itime;
        pval = Clust.pval;
        psign = 1;
    else
        psign = 0;
    end
    
    figure
    set(gcf,'visible','off','units','centimeters','position',[10 10 8.4 7.1])
    set(gca, 'position', [0.142 0.153 0.798 0.642])
    %--- Signals plot
    %subplot(2, 6, [1:4 7:10])
    hold on
    hp = zeros(2,1);
    pci = zeros(2,1);
    % Need to crop the signal instead of simply changing the x-limits,  in
    % order to avoid axis disappearance when adding confidence intervals
    % patches with transparency (alpha) - the y axis disappears otherwise.
    XLF = xlimit;
    int = find(time>XLF(1) & time<XLF(2));
    for p = 1 : length(yc)
        if isempty(Cci)
            hp(p) = plot(time(int), yc{p}(int),'linewidth',1.5,'color',col(p,:));
        else
            [hp(p), pci(p)] = boundedline(time(int), yc{p}(int), Cci{p}(int));
            set(pci(p), 'facecolor', col(p,:), 'facealpha', .2);
            set(hp(p),'linewidth',1.5,'color',col(p,:));
        end
    end
     
    set(hp(1), 'linewidth', 1.8)
    set(hp(2), 'linewidth', 1.2)
    box on
    
    set(gca,'position',[0.142 0.1339 0.798 0.67]);
    % Way to get round the y-axis disappearance when plotting confidence
    % interval patches
    xl = XLF;
    xl(1) = xl(1) - 0.001;
    xlim(xl)    
    
%     
%       H = diff(ylimit);
%     ylimit = [ylimit(1)-0.08*H  ylimit(2)+ 0.08*H];
    yl = ylimit;
    %--- Put time grid and time labels in ms
    xu = put_xgrid(xl, yl, 0.100, 9);    
    %--- Time markers (vertical dotted lines), y and x-axis
%     
    % Time grid
%     dtg = 0.100;
%     vgini = -5 : dtg : 5; 
%     % Suppose no signal with pre- and post- stimulation duration < 10 s
%     igi = find(vgini > XLF(1), 1, 'first');
%     igf = find(vgini < XLF(2), 1, 'last');
%     vgrid = vgini(igi:igf);
%    vgrid = repmat(vgrid, 2, 1);

%     line(vgrid, repmat(ygrd, length(vgrid), 1)', 'color',[.45 .45 .45],'linestyle',':','linewidth', 0.8)
%     set(gca, 'xtick',[])
     
%     % Time labels in ms
%     for v = 1:length(vgrid(1,:))
%         text(vgrid(1,v), yl(1)-diff(yl)./20, num2str(vgrid(1,v)*1e3,'%3.0f'),...
%             'fontsize',9, 'horizontalalignment','center')
%     end
%     set(gca, 'xtick', vgrid)
%     set(gca, 'xtickLabel', vgrid*1000)
%     set(gca, 'xgrid', 'on')
    set(gca, 'fontsize', 9)
%     ylim(yl)
    % Add ANOVA window define by WOI in s
    if psign
        disp(' ')
        disp(titstr{1})
        for nr = 1 : length(dur)
            WOI = [itime(nr) itime(nr)+dur(nr)];
            disp(['[ ', num2str(nr),' ]'])
            disp(['[ ',num2str(WOI(1)*1e3), '-', num2str(WOI(2).*1e3),' ] ms'])
            hrec = put_rectangle(WOI, [.87 .85 .85]); %statcol(nr,:));
            set(hrec, 'curvature', 0.05) %0.025) % "Soyons fou !"    
            %--- Adding p values
            sval = num2str(pval(nr),'%1.4f');
            if ~strcmp(sval(1:5), '0.000')
                sval = sval(1:5);
            end
            put_pval(hrec, sval)
            disp(['pval = ',sval])
        end
    end
    disp(' ')
    
    uistack(hp, 'top');

    %--- Annotations (x and y label, title, legend) - disappear if done
    % before atlas drawing
    annotation(gcf,'textarrow',[0.812 0.812],[0.0443 0.0443],...
        'String',['Time from target onset (', xu,')'], 'FontSize',10,...
    'HeadStyle','none','LineStyle', 'none'); 

    %--- Scale of y axis (ylabel)
    ylab = 'Normalized amplitude'; 
    annotation(gcf,'textarrow',[0.041 0.041], [0.723 0.723], 'String',ylab, 'FontSize',10,...
        'HeadStyle','none','LineStyle', 'none', 'TextRotation',90); %,'color',[.5 .5 .5]);
    
    %--- General title
    annotation(gcf,'textbox','String', titstr{1},'interpreter','none','FontSize',8,...
        'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0.006 0.9277 0.98 0.079]); %[0.0126 0.8978 0.9842 0.0873]

    annotation(gcf,'textbox','String', titstr{2},'interpreter','none','FontSize',7,...
    'fontangle','italic','LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[ 0.0060 0.8694 0.98 0.079]); %[0.0095 0.8301 0.9779 0.0873]

	%--- Legend of signal plots
    put_leg(legstr,col) 
    
    box on
   % pause

%--- Define color of rectangle according to duration 
    
function put_pval(hrec, sval)
rpos = get(hrec, 'position');
x = rpos(1) + rpos(3)./20;
y = rpos(2)+ rpos(4)./20;

text(x, y, ['p = ',sval],'fontsize',8);

%--- Add legend 
function put_leg(legcell,col)
    lig='^{\_\_ }'; 
    strtext = cell(length(legcell),1);
    for s = 1:length(legcell)
        legcell{s}(legcell{s}=='_')='-';
        if s==1 % Morphological is in bold
            strtext{s} = ['{\bf\color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s},'}'];
        else
            strtext{s} = ['\color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s}];
        end
    end
    strtext = strjoint(strtext, '  ');
    % Find the best location 
   % lg = legend(legcell,'location','best','fontsize',8);
    %pos = get(lg, 'position'); % [0.1572 0.6608 0.315 0.153]
   % delete(lg);
    annotation(gcf,'textbox','String',strtext,...
        'BackgroundColor', [1 1 1],...
        'position', [0.1388 0.8246 0.8044 0.0597],... %[0.1388 0.8097 0.8265 0.0709],... 
        'LineStyle','none',...
        'backgroundcolor', 'none',...
        'HorizontalAlignment','right',...
        'VerticalAlignment','middle',...
        'fontsize',8); %,'fontweight','bold');    % 'margin',4,...
      
%- Determine ylim - should be identical for all conditions in each ROI      
function YL = det_ylim(SavgROI, iroi)
    fcond = fieldnames(SavgROI);
    Nc = length(fcond);
    Na = length(SavgROI.(fcond{1}).label);
    yroi = zeros(Na,2);
    Da = 0.2;
    if isfield(SavgROI.(fcond{1}), 'confintROI')
        isci = true;
    else
        isci = false;
    end
        
    for k = 1 : length(iroi)
        ir = iroi(k);
        ycond = zeros(Nc, 2);
        for ic = 1 : Nc
            avg = SavgROI.(fcond{ic}).avgROI{ir};
            if ~isci
                ycond(ic, 1) = min(avg);
                ycond(ic, 2) = max(avg);
            else
                ec = SavgROI.(fcond{ic}).confintROI{ir};
                ycond(ic, 1) = min(avg - ec);
                ycond(ic, 2) = max(avg + ec);
            end
        end
        yroi(ir,1) = min(ycond(:,1))-Da;
        yroi(ir,2) = max(ycond(:,2))+Da;
    end
    YL = struct('ylim_eachgrp_eachroi', yroi,...
                'ylim_eachgrp_allroi', [min(yroi(:,1)) max(yroi(:,2))]);

% Reduce length of file name to save (considere only the first 4 letters of
% each name to concatenate + reduce letters of names separated by '_')
function nam = def_name(Cnames)
    Cnamr = Cnames;
    for i = 1 : length(Cnames)
        spnam = strsplitt(Cnames{i}, '_');
        for j = 1 : length(spnam)
            if length(spnam{j}) > 4
                spnam{j} = spnam{j}(1:4);
            end
        end
        Cnamr{i} = strjoint(spnam, '_');
    end
    nam = strjoint(Cnamr, '_');
            
%--- Check opt options
function opt = check_opt(opt, defopt)
    fn = fieldnames(defopt);
    for ir = 1:length(fn)
        if ~isfield(opt, fn{ir}) || isempty(opt.(fn{ir}))
            opt.(fn{ir}) = defopt.(fn{ir});
        end
    end