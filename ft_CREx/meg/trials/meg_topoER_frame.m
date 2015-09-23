function meg_topoER_frame(Savgtrial, figopt)
% MEG_TOPOER_FRAME Display topographic frames of ERF
% Figures of topographic representation of ERFs combined with the temporal 
% plots of ERFs (as the superposition of ERF signals from all channels) and
% of the associated "global field power" (as the square of ERFs)
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
%                   window (in seconds) [default: [-0.08 : 0.01 : 0.80]]
%
%   figopt.lgwin : duration of each windows (the same for all sliding versions)
%                   (in seconds) [default: 0.020]
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
%- CREx 20150601

% Set figure's default backgroung color to white
set_whbg;

% Check for input parameters and set defaults
defopt = struct('slidwin', -0.08 : 0.01 : 0.8 ,...
                'lgwin', 0.02,...
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
    addsav = 'Cond';
end

[matpath,matnam,ext] = fileparts(figopt.matpath);
matnam = [matnam,ext];

fdos = figopt.savpath;
 
% Check if magnetometer or planar gradient data
% A priori, magnetometer : the average values are positive AND negative,
% whereas for the combined planar gradient : only positive average values
if isfield(Savgtrial,'planar')
    ylab = 'Planar gradient (T m^{-1})';
    ylab2 = 'Sqr planar gradient (T^2 m^{-2})';
    zu = 'T m^{-1}';
    datyp = 'ERF (planar grad)';
    savt= 'Planar';
else
    ylab = 'Magnetic field (T)';
    ylab2 = 'Sqr magnetic field (T^2)';
    zu = 'T';
    datyp = 'ERF';
    savt= '';
end

Savgtrial.dimord = 'chan_time';
avg = Savgtrial.avg;
time = Savgtrial.time;

%---
% Prepare data for the topographic representation

% Store mean data for each time window in order to find the range of the
% colormap, identical for each time window
avgmeanwin = zeros(length(avg(:,1)),length(iwin));
msi = cell(length(iwin),1);
msf = cell(length(iwin),1);
namsav = cell(length(iwin),1);

for w = 1:length(iwin)
    % Mean ERF for each sliding window
    avgmeanwin(:,w) = mean(avg(:,time>=iwin(w) & time<=iwin(w)+lgw),2);
    % String of the window boundaries, in ms
    [msi{w}, msf{w}] = win_ms(iwin(w), lgw);
    if w < 10
        numfram = ['0',num2str(w)];
    else
        numfram = num2str(w);
    end
    % Name of the figure file which will be saved
    namsav{w} = name_save(['TopoER',savt,'Frame',addsav,'_',numfram,'_',msi{w},'_to_',msf{w},'ms']);
end

 % Fixe the range of the colormap (fixed over the entire scanning signal)
zlimcol = [min(min(avgmeanwin)) max(max(avgmeanwin))];
if zlimcol(1)<0
    zlimcol = [-1.*max(abs(zlimcol)) max(abs(zlimcol))];
end
   
%---
% Figure

figure, set(gcf,'visible', figopt.visible, 'units', 'centimeters', 'position',[16 8 15.7 17.5]);

% Font color of the subtitles, axes and labels
grey = [.6 .6 .6]; 

% FieldTrip parameters for the ft_topoplotER function
cfg = [];
cfg.parameter = 'avg';
cfg.interactive ='no';
cfg.colorbar = 'no';
cfg.zlim = zlimcol;
cfg.comment = 'no'; 
cfg.layout = '4D248.lay';
cfg.colormap = colormap_blue2red; % Blue to red colormap

% One figure by sliding window
for s = 1 : length(iwin)
    if iwin(s)+lgw < time(end)
        indw = find(time>=iwin(s) & time<=iwin(s)+lgw);
        if s==1
            %-- ERF signal plot in blue (remain for each figure)
            subplot(312)
            pos = get(gca,'position');
            % Move it down
            set(gca, 'position', [pos(1) pos(2)-0.08 pos(3:4)]);
            p1 = gca;
            
            plot(time, Savgtrial.avg, 'color', [0 0 .8])
            axis tight; box off;
            set(gca,'ycolor', grey,'xcolor','w')
            ylabel(ylab, 'color', grey)
            title('All channels', 'fontsize', 12, 'color', grey)
            hold on
            % Superimpose in red the part of the signal corresponding to 
            % the sliding window
            c1 = plot(time(indw), Savgtrial.avg(:,indw), 'color', 'r', 'parent', p1);
            
            %-- Mean square ERF signal
            subplot(313)
            plot(time, mean(Savgtrial.avg.^2), 'color', [.3 .3 .3])
            pos = get(gca,'position');
            % Move it down
            set(gca,'position',[pos(1) pos(2)-.05 pos(3:4)]);
            p2 = gca;
            axis tight; box off;
            set(gca,'ycolor', grey, 'xcolor', grey)
            ylabel(ylab2, 'color', grey)
            xlabel('Time (s)', 'color', grey)
            title('Mean square', 'fontsize', 12, 'color', grey)
            hold on
            % Superimpose the sliding window location in red
            c2 = plot(time(indw), mean(Savgtrial.avg(:,indw).^2),'r','linewidth',3,'parent',p2);
        else
            % Remove red part indicating location of the previous sliding
            % window
            delete([c1; c2])
            % Superimpose in red the part of the signal corresponding to 
            % the new sliding window
            % On ERF subplot
            c1 = plot(time(indw),Savgtrial.avg(:,indw),'color','r','parent',p1);
            % On mean square subplot
            c2 = plot(time(indw),mean(Savgtrial.avg(:,indw).^2),'r',...
                'linewidth',2,'parent',p2);
        end
        
        % First subplot : the topographic representation made by
        % ft_topoplotER
        subplot(311)
        cfg.xlim = [iwin(s) iwin(s)+lgw];
        ft_topoplotER(cfg, Savgtrial);
        axis tight
        
        titfig = ['t = [ ',msi{s},'  ',msf{s},' ] ms'];
        title(titfig, 'fontsize', 10, 'fontweight', 'bold')
        pos = get(gca, 'position');
        
        % Move it and make it larger
        set(gca,'position',[pos(1)-.025 pos(2)-.1 pos(3)+.05 pos(4)+.05]) 

        % Change colorbar location and size
        cb = colorbar('location','eastoutside');
        set(cb, 'position', [0.8507 0.6269 0.0118 0.2659])
        % Add units
        set(get(cb,'title'), 'string', zu, 'fontsize',10)

        % General title of the figure
        gentit = {[addtit,'Topographic representation of ',datyp,' : ', matnam]; matpath};
        annotation(gcf, 'textbox', 'String', gentit,...
                    'interpreter', 'none',...
                    'FontSize', 9,...
                    'fontname', 'AvantGarde',...
                    'LineStyle', 'none',...
                    'HorizontalAlignment','center',...
                    'FitBoxToText', 'off',...
                    'Position',[0.05 .94 0.9 0.058]);
        % Save this frame
        export_fig([fdos, filesep, namsav{s},'.jpeg'],'-m1.5')
    end
end
disp(' ')
disp('---- Figures saved here :')
disp(fdos)
disp(' ')
close


%____
% Additional functions

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