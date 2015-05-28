function meg_multiplotER_single(Savg, opt)
% Display ERF signals on 4D248 layout - single condition
% Possible options in opt structure :
% opt.name : name of the condition that will appear on figure title
%        (default : [])
% opt.datapath : original path of data from which Savg comes from
%        (default : [])
% opt.figpath : path of directory where figures will be saved 
%        (default : pwd) 
%


%---
% Check for input 

if ~isfield(Savg,'avg')
    disp('!!! Bad data format - fieldtrip structure ')
    disp('with field "avg" required as first argument')
    return
end

defopt = struct('name','Undef_cond','datapath',[],'figpath',pwd);
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


%---
% Prepare layout according to data features

% Data label names 
Clab = Savg.label;

% Define layout according to data grad positions relative to subject's head
cfg = [];
cfg.grad = Savg.grad;
cfg.layout = '4D248.lay';
lay = ft_prepare_layout(cfg);

% Channel coordinates on layout (x,y)
x = lay.pos(:,1).*2;  % x.*2 because x will be scaling by a factor 2
y = lay.pos(:,2);

% Reject channels not present in Clab = channels that have been removed 
% from data 
if length(Clab)<length(lay.label)
    igood=zeros(length(lay.label),1);
    for i=1:length(lay.label)
        if any(strcmp(Clab,lay.label{i}))
            igood(i)=1;
        end
    end
    x=x(igood==1);
    y=y(igood==1);
    lay.label=lay.label(igood==1); 
end

% Sort coordinates in order that they correspond to labels in Clab
indsort=zeros(length(Clab),1);
for c=1:length(Clab)
    indsort(c)=find(strcmp(lay.label,Clab{c})==1);
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

x_avg = Savg.time; % Time vector (1 x Ntime)
y_avg = Savg.avg;  % Amplitudes (Nchan x Ntime)

% Normalise x_avg & y_avg to fit in the minipage
x_norm = (x_avg./x_avg(end)).*W; % Normalized time

maxy = max(max(y_avg));
y_norm = (y_avg./maxy).*H; % Normalized amplitude



% Define baseline length (before t_avg = 0 s)
nBL = length(x_avg(x_avg<0));
if nBL > 0
    isBL = true;
else
    isBL = false;
end

% Define colors : one for the baseline part (before stimulus onset), and
% one for the Evoked-Response Field part (after stimulus onset)
colBL = [1 .7 .7]; % not use if isBL == false
colER = [0.0078 0.31 0.62];

%---
% Draw ERF signals on the layout

hold on

for j = 1 : length(Clab)
    x_mini = x_norm + x(j);
    y_mini = y_norm(j,:) + y(j);
    plot(x_mini(nBL+1:end), y_mini(nBL+1:end), 'color',colER); 
    
    if isBL
        plot(x_mini(1:nBL), y_mini(1:nBL), 'color',colBL)
    end
    
    % Add channel name
    ht = text(x_mini(1)+.3*W, max(y_mini)+.3*H, Clab{j});
    set(ht,'color',[.5 .5 .5],'fontsize',8,'fontweight','bold')
end

% Add legend
legcell = {'Before stimulus onset','After stimulus onset'};
col = [colBL;colER];
put_leg(legcell,col)

% Add general title
put_title(Savg, opt);

%---
% Save 
export_fig([pres,filesep,'ERF_LayDisp_',opt.name,'_',opt.matname,'.jpg'],'-m3')
zoom on
saveas(gcf,[pres,filesep,'ERF_LayDisp_',opt.name,'_',opt.matname,'.fig'])

fprintf('\n------Figures jpg and fig saved here :\n%s------\n',pres)

close

%_____
% Functions for title and legend

%---
% Title 
function put_title(Savg, opt)
namcond = opt.name;
pmat = opt.datapath;

nbT = [];
if strcmp(Savg.dimord,'chan_time') == 1
    % Try to find number of single trials used to compute the average
    % Should be in the field trials : S.cfg.previous.trials
    vectrial = get_field(Savg,'trials','numeric');
    if ~isempty(vectrial)
        nbT = length(vectrial);
    end
elseif strcmp(Savg.dimord,'rpt_chan_time') == 1
    nbT = length(Savg.trial(:,1,1));
end
if ~isempty(nbT)
    partit = [' - Average computed from ',num2str(nbT),' trials'];
else
    partit = [];
end

titlefig = cell(2,1);
titlefig{1} = ['[ ',namcond,' ] - ERF display on the layout',partit];
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