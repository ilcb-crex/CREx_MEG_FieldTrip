function meg_atlas_ROI_multi_fig(atlas, ROIlist, figopt)
% Figures of 3D views representing MNI-Cloin atlas and specific highlight 
% ROIs 
% ROIlist : list of ROIs to highlight

label = atlas.tissuelabel;

%--- Check for inputs

%- List of ROI names to plot
idROI = find_ROI(label, ROIlist);
if isempty(idROI)
    fprintf('\n---\n!!! No name matching between input ROI names and atlas labels')
    return;
end

%- Figure options
defopt = struct('savepath',pwd, 'views', 'all', 'closefig', true);
if nargin < 3
    figopt = defopt;
else
    figopt = check_opt(figopt, defopt);
end
pdir = make_dir([figopt.savepath, filesep, 'multiROIs'],0);

%- Views options
if isfield(figopt, 'allviews')
    Sall = figopt.allviews;
else
    % Default views definition (according to atlas store in 
    % atlas_Colin27_BS.mat)
    Sall = set_allviews ;
end
Sview  = check_views_opt(figopt.views, Sall);
fview = fieldnames(Sview);

if figopt.closefig
    fvis = 'off';
else
    fvis = 'on';
end

%--- GO !

Apatch = atlas.ROIpatch;
Np = length(Apatch);
colall = [0 0.55 0.45];

%- [ 2 ] - All ROIs to highlight (listed in ROIlist) on the same figure
figure, set(gcf, 'visible', fvis, 'color',[0 0 0])
set(gca,'color', [0 0 0], 'position', [0.005 0.005 0.7 0.85])
  
roinams = label(idROI);

% Set name of figure file

cnam = char(roinams);
cnam = cellstr(cnam(:, 1:6));
unam = unique(cnam);
combnam = ['_', strjoint(unam,'_')];
if length(combnam) > 30
    combnam = '';
end
savnam = [num2str(length(idROI)),'ROIs',combnam,'_',datestr(now,'yymmdd_HHMM')];

% Indices of all patches (minus the ROIs to highlight)
ip = setxor(1:Np, idROI);
hpa = draw_otherpatches(Apatch, ip, colall);

% Add the patches of interest
colroi = color_group(length(idROI));
hroi = zeros(length(idROI), 1);
for i = 1 : length(idROI)
    hroi(i) = patch(Apatch{idROI(i)}, 'edgecolor','none',...
                'facecolor',colroi(i,:) ,'facealpha',.9,... 
                'facelighting','gouraud');
end

% Change view according to Sview

for v = 1:length(fview)
    view(Sview.(fview{v}).vect)
    axis equal;
    lig = camlight('right','infinite'); %light('Parent',gca,'Position',[-0.75 -0.433 0.5]);
     %- Add legend
    lg = put_legend(hroi, roinams);
    
    title({'AAL MNI-Colin27 atlas';...
    [Sview.(fview{v}).title,' view']},'fontsize',12, 'color', [1 1 1],...
    'interpreter','none')
    export_fig([pdir, filesep,'atlasROI_', savnam,'_',fview{v},'.jpg'],'-m1.5')
    delete([lg;lig])
end

% Figure with all views
draw_4views(hpa, hroi, Sall, roinams, fvis)
export_fig([pdir, filesep,'atlasROI_', savnam,'_4views.jpg'],'-m1.5')
if figopt.closefig
    close all
end

function hpa = draw_otherpatches(ROIpatch, ipatch, col)
    Np = length(ipatch);
    ip = ipatch;
    hpa = zeros(Np,1);
    for p = 1: length(ip)
        hpa(p) = patch(ROIpatch{ip(p)}, 'edgecolor','none',...
                'facecolor',col ,'facealpha',.1,... 
                'facelighting','gouraud');
    end

    set(hpa, 'AmbientStrength', 1, 'DiffuseStrength', 0.5, ...
        'SpecularColorReflectance', 0,...
        'SpecularStrength', 0) 

    
function lg = put_legend(hdl, names) 

    % Define legend position according to gca's one
    posa = get(gca,'outerposition');    
    lg = legend(hdl, names,'location','eastoutside');   
    posl = get(lg, 'position');
    
    pos = [posa(1)+posa(3)-0.02 (1-posl(4))./2 0.2 posl(4)];

    set(lg, 'position', pos,...
        'interpreter', 'none', 'fontsize', 8, 'color', [0 0 0], 'textcolor', [1 1 1])  
    
    % The color rectangles are of type 'patch' and the
    % associated texts of type 'text'.
    
    % Reduced rectangle size
    cpa = findobj(lg, 'type', 'patch');
    for j = 1 : length(cpa)
        xd = get(cpa(j), 'XData');
        newxd = [xd(1:2); xd(3:4)./2]; 
        set(cpa(j), 'XData', newxd)
    end
    % Move text closer to the color rectangle
    ctx = findobj(lg, 'type', 'text');
    for k = 1 : length(ctx)
        pos = get(ctx(k), 'position');
        pos(1) = newxd(3) + 0.02; 
        set(ctx(k),'position', pos);
    end   


function draw_4views(hpa, hroi, Aview, ROIname, fvis)
    fv = fieldnames(Aview);
    
    hSu = zeros(4,1);
    
    figure, 
    set(gcf,'visible', fvis,'color',[0 0 0])
    set(gcf,'units','centimeters','position', [7 4 22 14]) % W 14

    %- Subplot positions
    W = 0.375; 
    H = 0.375; 
    ma = 0.042;

    pos = zeros(4,4);
    pos(1,:) = [ ma     3*ma+H   W H ];
    pos(2,:) = [ ma+W   pos(1,2) W H ];
    pos(3,:) = [ ma         ma*2   W H ];
    pos(4,:) = [ pos(2,1)   ma*2   W H ];

    for s = 1:4
        hSu(s) = subplot(2,2,s);
        if ~isempty(hpa)
            copyobj(hpa, hSu(s));
        end
        H = copyobj(hroi, hSu(s));

        set(hSu(s), 'color', [0 0 0], 'view', Aview.(fv{s}).vect)

        camlight('right','infinite')

        axis tight equal;
        title(Aview.(fv{s}).title,'fontsize',12,'color',[1 1 1]) 
        set(hSu(s), 'position', pos(s, :))
    end
    %- Add legend
    put_legend(H, ROIname);
    %- Add the famous general title
    annotation(gcf,'textbox','String', 'MNI-Colin27 atlas',...
        'interpreter','none','FontSize',14,'fontname','AvantGarde','color',[1 1 1],...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 0.91 0.73 0.086]);
    
%--- Check figopt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end

function Sall = set_allviews
allv = {'left','right','frontal','superior'};
tview = {'Lateral Left','Lateral Right','Frontal','Superior'};
vview = [-90 0 ; 90 0 ; -180 0 ; 0 90]; 

Sall = struct;
for i = 1:length(allv)
    Sall.(allv{i}).title = tview{i};
    Sall.(allv{i}).vect = vview(i,:);
end

%--- Check views to display options
function Sview = check_views_opt(vopt, Sall)

allv = fieldnames(Sall);
callv = char(allv');
callv = cellstr(callv(:,1));

if any(strcmp(vopt,'all'))
    Sview = Sall;
else
    Sview = struct;
    if ischar(vopt)
        vopt = {vopt};
    end
    j = 1;
    for v = 1 : length(vopt)
        iv = find(strcmpi(callv, vopt{v}(1))==1);
        if ~isempty(iv)
            Sview.(allv{iv}) = Sall.(allv{iv});
            j = j+1;
        end
    end
    if j==1
        Sview = Sall;
    end
end

    
