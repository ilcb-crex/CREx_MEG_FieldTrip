function meg_multiplotER_multiNEW(SavgCond, opt)
% Display ERF signals on 4D248 layout - several conditions to superimpose
% Possible options in opt structure :
% opt.fnames : names of the fields which contain ERF to plot
%        (default : all fieldtrip structures in SavgCond)
% opt.datapath : original path of data from which Savg comes from
%        (default : [])
% opt.figpath : path of directory where figures will be saved 
%        (default : pwd) 



%---
% Check for input 
fn = fieldnames(SavgCond)';
if ~isfield(SavgCond.(fn{1}),'avg')
    disp('!!! Bad data format - fieldtrip structures')
    disp('with field "avg" required inside the structure')
    disp('SavgCond (first argument)')
    return
end

defopt = struct('fnames',[],'datapath',[],'figpath',pwd);
defopt.fnames = fn;
fopt = fieldnames(defopt);
if nargin == 1
    % Default options
    opt = defopt;
else
    for f = 1:length(fopt)
        if ~isfield(opt,fopt{f})
            opt.(fopt{f}) = defopt.(fopt{f});
        end
    end
end

% Results directory
pres = opt.figpath;
if isempty(dir(pres))
    pres = pwd;
end

pmat = opt.datapath;
if ~isempty(pmat)
    [T, opt.matname] = fileparts(pmat);  %#ok - Compat Matlab 7.5
else
    opt.matname = 'avgTrials';
end

nlig = size(opt.fnames,1);
if nlig > 1
    opt.fnames = opt.fnames';
end

effects = opt.fnames;

%---
% Prepare layout according to data features

% Data label names - not necessary the same for all conditions : case when
% we compare 2 groups of data for instance
Clab = SavgCond.(effects{1}).label;
for e = 2:length(effects)
    Clab = intersect(Clab, SavgCond.(effects{e}).label,'stable');
end

% Define layout according to data grad positions relative to subject's head
cfg = [];
cfg.grad = SavgCond.(effects{1}).grad;
cfg.layout = '4D248.lay';
lay = ft_prepare_layout(cfg);

% Channel coordinates on layout (x,y)
x = lay.pos(:,1).*2;  % x.*2 because x will be scaling by a factor 2
y = lay.pos(:,2);

% Reject channels not present in Clab = channels that have been removed 
% from data 
if length(Clab) < length(lay.label)
    igood = zeros(length(lay.label),1);
    for i = 1:length(lay.label)
        if any(strcmp(Clab, lay.label{i}))
            igood(i) = 1;
        end
    end
    x = x(igood==1);
    y = y(igood==1);
    lay.label = lay.label(igood==1); 
end

% Sort coordinates in order that they correspond to labels in Clab
indsort = zeros(length(Clab),1);
for c = 1:length(Clab)
    indsort(c) = find(strcmp(lay.label,Clab{c})==1);
end
x = x(indsort);
y = y(indsort);

%---
% Go !

figure
set(gcf,'units','centimeters','position',[9 9 17 13])    
lay.label = lay.label(1:end-2);
lay.pos = lay.pos(1:end-2,:);
ft_plot_lay(lay, 'point', 'no',...
    'box', false, 'label', 'no','outline', true,'height',1,'width',2);

% Reduce layout linewidth and change color to grey
h = findobj(gca,'type','line','color',[0 0 0]);
set(h,'color',[.7 .7 .7],'linewidth',.5)

% Change figure & axes dimensions
set(gcf,'units','centimeters','position', [2 3 46 23])
set(gca,'position',[-.25 -.25 1.5 1.5])
% -- "more specific you die" (in "frenglish")

% Define dimension of the "minipage" for plotting data at each channel
% location  
W = 0.0496;  % Width
H = 0.0274;  % Height

x_avg = SavgCond.(effects{1}).time; % Time vector (1 x Ntime)
y_avg = cell(length(effects),1);
y_lab = cell(length(effects),1);
vmaxy = zeros(length(effects),1);
for e = 1:length(effects)
    y_avg{e} = SavgCond.(effects{e}).avg;  % Amplitudes (Nchan x Ntime)
    vmaxy(e) = max(max(y_avg{e}));
    y_lab{e} = SavgCond.(effects{e}).label;
end


% Normalise x_avg & y_avg to fit in the minipage
x_norm = (x_avg./x_avg(end)).*W; % Normalized time

maxy = max(vmaxy);
y_norm = cell(length(effects),1);
for e = 1:length(effects)
    y_norm{e} = (y_avg{e}./maxy).*H; % Normalized amplitude
end

% Define baseline length (before t_avg = 0 s)
nBL = length(x_avg(x_avg<0));
if nBL > 0
    isBL = true;
else
    isBL = false;
end

% Define colors : one for the baseline part (before stimulus onset), and
% one for the Evoked-Response Field part (after stimulus onset)
colBL = [.7 .7 .7]; % not use if isBL == false
colER = mycolorsup;

%---
% Draw ERF signals on the layout

hold on

vmaxp = zeros(length(effects),1);
for j = 1 : length(Clab)
    x_mini = x_norm + x(j);
    
    for e = 1:length(effects)
        y_mini = y_norm{e}(strcmp(y_lab{e}, Clab{j})==1, :) + y(j);
        plot(x_mini(nBL+1:end), y_mini(nBL+1:end), 'color',colER(e,:)); 
        if isBL
            plot(x_mini(1:nBL), y_mini(1:nBL), 'color',colBL)
        end
        vmaxp(e) = max(y_mini);
        
    end
    % Add channel name
    ht = text(x_mini(1)+.3*W, max(vmaxp)+.3*H, Clab{j});
    set(ht,'color',[.5 .5 .5],'fontsize',8,'fontweight','bold')
end

% Add legend

legcell = ['Before stimulus onset' , effects];
col = [colBL;colER];
put_leg(legcell,col)

% Add general title
put_title(opt);

%---
% Save 
namcond = strjoint(opt.fnames,'_');
namcond(namcond=='-')='_';
export_fig([pres,filesep,'ERF_LayDispSup_',namcond,'_',opt.matname,'.jpg'],'-m3')
zoom on
saveas(gcf,[pres,filesep,'ERF_LayDispSup_',namcond,'_',opt.matname,'.fig'])

fprintf('\n------Figures jpg and fig saved here :\n%s\n------\n',pres)

close

%_____
% Functions for title and legend

%---
% Color for dissociated conditions  
function col = mycolorsup
    col=[ 0.0431    0.5176    0.7804
          0.8471    0.1608         0
          0         0.6000    0.4000
          0.8706    0.4902         0
          0         0.7490    0.7490
          0.16      0.84     0 ];
%---
% Title 
function put_title(opt)
namcond = strjoint(opt.fnames,', ');
pmat = opt.datapath;


titlefig = cell(2,1);
titlefig{1} = ['[ ',namcond,' ] - ERF display on the layout'];
if ~isempty(pmat)
    titlefig{2} = ['Data path : ',pmat];   
end
annotation(gcf,'textbox','String',titlefig,'interpreter','none',...
        'FontSize',13,'fontname','AvantGarde',...
        'color',[0 0 0],'backgroundcolor',[1 1 1],...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 0.9391 0.9 0.0584]);

%---
% Legend
function put_leg(legcell,col)
lig='^{\_\_ }'; 
strtext = cell(length(legcell),1);
for s=1:length(legcell)
    legcell{s}(legcell{s}=='_')='-';
    strtext{s}=['\color[rgb]{',num2str(col(s,:)),'}',lig,legcell{s}];
end
annotation(gcf,'textbox','String',strtext,...
    'LineStyle','none','fontsize',10,'fontweight','bold',...
    'position',[0.7971 0.0702 0.1690 0.0702]);    

