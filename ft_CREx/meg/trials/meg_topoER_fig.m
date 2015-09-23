function meg_topoER_fig(Savgtrial, figopt)
% MEG_TOPOER_FIG Display topographic views of ERF
%
% Topographic representations of ERFs are done for each time step defined 
% by figopt.slidwin parameter. All of them are subploted on the same figure. 
%
% The topographic representation corresponds to an interpolation of the mean 
% amplitude of the ERF signal calculated at a given time window and for each 
% sensor. The time windows are specified in the figopt structure. 
%
% ---
% Input parameters 
%
% - Savgtrial : the ERF data as a FieldTrip structure
% - figopt : figure options structure :
%
%   figopt.slidwin : vector of the beginning times of each sliding time 
%                   window (in seconds) [default: [-0.100 : 0.050 : 0.900]]
%
%   figopt.lgwin : duration of each windows (the same for all sliding versions)
%                   (in seconds) [default: 0.050]
%
%   figopt.fname : names of the experimental condition, which will be added
%                   to the title of the figure [default: '']
%
%   figopt.savpath : path of the directory where figures will be saved
%                   [default: './TopoERF']
%
%   figopt.matpath : path of the data used for the calculation (if provided,
%                   it will be added to the figure title) [default:
%                   'avgTrial.mat']
%
%   figopt.visible : set 'visible' property of the figure [default : 'off']
%
% ---
% Required these external functions :
% FieldTrip : ft_topoplotER
% ft_CREx : set_whbg ; name_save ; colormap_blue2red ; make_dir ; export_fig
%
%- CREx 20150923

% Set figure's default backgroung color to white
set_whbg;

% Check for input parameters and set defaults
defopt = struct('slidwin', -0.100 : 0.050 : 0.850,...
                'lgwin', 0.050,...
                'fname','',...
                'savpath', '',...
                'matpath', 'avgTrial.mat',...
                'visible', 'off');

if nargin < 2 || isempty(figopt)
    figopt = defopt;
else
    figopt = check_opt(figopt, defopt);
end

iwin = figopt.slidwin;
lgw = figopt.lgwin; 

% Figures add-on information
% Indication on stimulus condition's name
if ~isempty(figopt.fname) 
    addtit = ['[ ',figopt.fname, ' ] - '];
    addsav = ['_', name_save(figopt.fname)];
else
    addtit = '';
    addsav = '_Cond';
end

[matpath,matnam,ext] = fileparts(figopt.matpath);
matnam = [matnam,ext];

fdos = figopt.savpath;
 
% Check if magnetometer or planar gradient data
% A priori, magnetometer : the average values are positive AND negative,
% whereas for the combined planar gradient : only positive average values
if isfield(Savgtrial,'planar')
    datyp = 'ERF (planar grad)';
    zlab = 'Planar gradient (T m^{-1})';    
    savt = 'Planar';
else    
    datyp = 'ERF';
    zlab = 'Magnetic field (T)';
    savt = '';
end

Savgtrial.dimord = 'chan_time';
avg = Savgtrial.avg;
time = Savgtrial.time;

%---
% Prepare data for the topographic representation

% Define figure dimension (number of lines of subplots and associated height)
% Number of columns is fixed at 5.
% Default sliding window parameters ensures good proportions of topographic
% visualizations  : -0.100 : 0.050 : 0.900 s

% Define H : height of the figure, in centimeters
nlig = ceil((length(iwin))./5);
if nlig <= 4
    H = 23;
else
    H = 28;
end

% Store mean data for each time window in order to find the range of the
% colormap, identical for each time window
avgmeanwin = zeros(length(avg(:,1)),length(iwin));
msi = cell(length(iwin),1);
msf = cell(length(iwin),1);

for w = 1:length(iwin)
    % Mean ERF for each sliding window
    avgmeanwin(:,w) = mean(avg(:,time>=iwin(w) & time<=iwin(w)+lgw),2);
    % String of the window boundaries, in ms
    [msi{w}, msf{w}] = win_ms(iwin(w), lgw);
end

 % Fixe the range of the colormap (fixed over the entire scanning signal)
zlimcol = [min(min(avgmeanwin)) max(max(avgmeanwin))];
if zlimcol(1)<0
    zlimcol = [-1.*max(abs(zlimcol)) max(abs(zlimcol))];
end
   
%---
% Figure

figure, set(gcf,'visible', figopt.visible, 'units', 'centimeters', 'position', [2 2 28 H])

cfg = [];
cfg.parameter = 'avg';
cfg.interactive ='no';
cfg.colorbar = 'no';
cfg.zlim = zlimcol;
cfg.comment = 'no'; 
cfg.layout = '4D248.lay';
cfg.colormap = colormap_blue2red;

for s = 1 : length(iwin)
    if iwin(s)+lgw < time(end)
        
        subplot(nlig, 5, s)
        
        cfg.xlim = [iwin(s) iwin(s)+lgw];
        
        ft_topoplotER(cfg,Savgtrial);
        
        axis tight 
        titfig = ['t = [ ',msi{s},'  ',msf{s},' ] ms'];
        title(titfig,'fontsize',10,'fontweight','bold')
        pos = get(gca,'position');
        set(gca,'position',[pos(1) pos(2)-.04 pos(3) pos(4)]);
        
        % Add min and max values label for each topo
        meanval = mean(avg(:,time >= iwin(s) & time <= iwin(s)+lgw), 2);
        minavg = num2str(min(meanval), 2);
        maxavg = num2str(max(meanval), 2);
        pos = get(gca,'position');
        annotation(gcf,'textbox','String',['val=[', minavg,'  ', maxavg,']' ],...
            'HorizontalAlignment','center','FontSize',8,'FitBoxToText','on',...
            'LineStyle','none','position',[pos(1) pos(2)-.005 pos(3)+.01 .01]);
    end
end

% Change colorbar location and size
cb = colorbar('location','westoutside');
set(cb,'position',[0.0751 0.0632 0.0174 0.3586],'fontsize',12)
% Add units
set(get(cb,'ylabel'),'string', zlab,'fontsize',12)

% General title of the figure
gentit = {[addtit,'Topographic representations of ',datyp,' : ', matnam]; matpath};
annotation(gcf,'textbox','String',gentit,...
            'interpreter','none',...
            'FontSize',13,...
            'fontname','AvantGarde',...
            'fontweight','bold',...
            'LineStyle','none',...
            'HorizontalAlignment','center',...
            'FitBoxToText','off',...
            'Position',[0.05 .88 0.9 0.12]);
% Name of the figure file which will be saved
namsav = name_save(['Topo', savt,'ERPlot', addsav,'_',msi{1},'_to_',msf{end},'ms']);

export_fig([fdos, filesep, namsav,'.jpeg'],'-m1.5')
close

disp(' '),disp('- - - - - -')
disp('Figure saved in :')
disp(fdos)
disp('- - - - - -'),disp(' ')
 
%--- Check figopt structure
function figopt = check_opt(figopt, defopt)
% defopt = struct('slidwin', -0.08 : 0.01 : 0.8 ,'lgwin', 0.02,...
%     'fname','', 'savpath', [], 'matpath', 'avgTrial.mat', 'visible', 'off');

defn = fieldnames(defopt);
optn = fieldnames(figopt);

for j = 1 : length(defn)
    if strcmp(optn, defn{j})==0
       figopt.(defn{j}) = defopt.(defn{j});
    end
end

if ~ischar(figopt.matpath)
   figopt.matpath = defopt.matpath;
end

if isempty(dir(figopt.savpath))
    figopt.savpath = make_dir([pwd, filesep, 'TopoERF'],1);
end


%--- String names of time intervals
function [msi, msf] = win_ms(startw, lgw)
    msi = num2str(startw.*1e3);
    msf = num2str((startw+lgw).*1e3);
    if ~isempty(strfind(msi,'e'))
        msi = num2str(round(startw).*1e3);
    end
    if ~isempty(strfind(msf,'e'))
        msf = num2str(round(startw+lgw).*1e3);
    end  