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
    addsav = [opt.grpname,'_'];
else
    addsav = '';
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

if isempty(opt.ylim)
    YL = det_ylim(SavgROI, iroi);
else
    YL = opt.ylim;
end

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
   
    for n = iroi  
        
        numdip = SavgROI.(spcond{1}).numdip(n);
        if numdip > 0
            Cavg = [avgR1(n) ; avgR2(n)];
            cdur = clustROI.(supcond{i}).dur{n};
            
            if ~isempty(cdur)
                Clust.dur = cdur;
                Clust.itime = clustROI.(supcond{i}).itime{n};
                Clust.pval = clustROI.(supcond{i}).pval{n};
            else
                Clust = struct('dur',[],'itime',[]);    
            end
            if ~onlyWhenClust || (onlyWhenClust && ~isempty(Clust.dur))
                snum = ['(Ndip=',num2str(numdip), '; Nsubj=', ssubj, '; ', sparam,')']; 
                
                tit = {['Mean source signal in ', Alab{n},' ROI'];
                    snum};
                if dispCI
                    Cci = [SavgROI.(spcond{1}).confintROI(n)
                        SavgROI.(spcond{2}).confintROI(n)];
                else
                    Cci = [];
                end
%                 yc = Cavg;
%                 col = colsup;
%                 legstr = spcond;
%                 titstr = tit;
%                 ylimit = YL(n,:);
                
                ROIfig(time, Cavg, colsup, spcond, tit, Clust, XL, YL(n,:), Cci)

                export_fig([psav, filesep, 'clustime_aROI_', addsav, supcond{i}, '_', Alab{n},'.jpg'],'-m2.5','-nocrop') %,'-zbuffer') %'.eps'
          %      export_fig([psav, filesep, 'clustime_aROI_', addsav, supcond{i}, '_', Alab{n},'.eps'],'-m1.5','-nocrop')
                plot2svg([psav, filesep, 'clustime_aROI_', addsav, supcond{i}, '_', Alab{n},'.svg'])
                close 
            end
        end 
    end
end
 
% yc = Cavg;
% col = colsup;
% legstr = spcond;
% titstr = tit;


function ROIfig(time, yc, col, legstr, titstr, Clust, xlimit, ylimit, Cci)
    if ~isempty(Clust.dur)
        dur = Clust.dur;
        itime = Clust.itime;
        pval = Clust.pval;
        psign = 1;
    else
        psign = 0;
    end
    
    figure, set(gcf,'visible','off','units','centimeters','position',[10 10 8.4 7.1]) % 'off'
    
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
    
    yl = ylimit;
    
    %--- Time markers (vertical dotted lines), y and x-axis
    
    % Time grid
    dtg = 0.100;
    vgini = -5 : dtg : 5; 
    % Suppose no signal with pre- and post- stimulation duration < 10 s
    igi = find(vgini > XLF(1), 1, 'first');
    igf = find(vgini < XLF(2), 1, 'last');
    vgrid = vgini(igi:igf);
    vgrid = repmat(vgrid, 2, 1);
    line(vgrid, repmat(yl,length(vgrid),1)', 'color',[.45 .45 .45],'linestyle',':','linewidth', 0.8)
    set(gca, 'xtick',[])
    ylim(yl) 
    % Time labels in ms
    for v = 1:length(vgrid(1,:))
        text(vgrid(1,v), yl(1)-diff(yl)./20, num2str(vgrid(1,v)*1e3,'%3.0f'),...
            'fontsize',9, 'horizontalalignment','center')
    end

    set(gca, 'fontsize', 8)
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
    annotation(gcf,'textarrow',[0.812 0.812],[0.0443 0.0443], 'String','Time from target onset (ms)', 'FontSize',10,...
    'HeadStyle','none','LineStyle', 'none'); %,'color',[.5 .5 .5]  % [0.812 0.812],[0.063 0.063]
    
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
    'FitBoxToText','off','Position',[0.006 0.8657 0.98 0.079]); %[0.0095 0.8301 0.9779 0.0873]

	%--- Legend of signal plots
    put_leg(legstr,col) 
    
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
        'position',[0.1388 0.8097 0.8265 0.0709],... 
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
    YL = zeros(Na,2);
    Da = 0.2;
    if isfield(SavgROI.(fcond{1}), 'confintROI')
        isci = true;
    else
        isci = false;
    end
        
    for n = iroi
        yc = zeros(Nc, 2);
        for ic = 1 : Nc
            if ~isci
                yc(ic, 1) = min(SavgROI.(fcond{ic}).avgROI{n});
                yc(ic, 2) = max(SavgROI.(fcond{ic}).avgROI{n});
            else
                ec = SavgROI.(fcond{ic}).avgROI{n}.confintROI{n};
                yc(ic, 1) = min(SavgROI.(fcond{ic}).avgROI{n}-ec);
                yc(ic, 2) = max(SavgROI.(fcond{ic}).avgROI{n}+ec);
            end
        end
        YL(n,1) = min(yc(:,1))-Da;
        YL(n,2) = max(yc(:,2))+Da;
    end

%--- Check opt options
function opt = check_opt(opt, defopt)
    fn = fieldnames(defopt);
    for n = 1:length(fn)
        if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
            opt.(fn{n}) = defopt.(fn{n});
        end
    end