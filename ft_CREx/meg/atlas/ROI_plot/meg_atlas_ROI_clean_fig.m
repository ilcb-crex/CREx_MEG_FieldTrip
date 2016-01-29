function meg_atlas_ROI_clean_fig(atlas, ROIlist, figopt)
% Figures of 3D views representing MNI-Cloin atlas and specific highlight 
% ROIs (PAPER STYLE - no legend, grey patches)
% Figures of 3D views of the ROI patches of an atlas with specific 
% highlight ROIs 
%
% - atlas structure is issue to the preprocessing by ft_read_atlas and 
%   by ft_CREx toolbox functions to coregister atlas with template volume 
%   used for the source modelling (meg_atlas_coreg) and to extract ROI 
%   patches (meg_atlas_ROIpatch)
%
% - ROIlist : list of ROIs to highlight (cellule of string labels)
%   Can be partial names to find all matching with ROI names stored in 
%   atlas.tissuelabel cellule
%   Ex. with AAL atlas : ROIlist = {'tempo*pole*l','front*inf_orb*l'};
%   Those ROIs with be found :'Frontal_Inf_Orb_L', 'Temporal_Pole_Sup_L'
%   and 'Temporal_Pole_Mid_L'. 
%
% - figopt : options for figures
%
%       - figopt.savepath : path of the directory where to save figures. 
%           Figures will be saved in figopt.savepath inside a new directory 
%           "singleROI" [ default : pwd ]
%
%       - figopt.views : angle of views to display (string or cellule of
%       strings to display several kind of views)
%       Available views are : 
%           - 'left' : view of the lateral left side
%           - 'right' : lateral right
%           - 'frontal' : frontal view
%           - 'top' : from the top (superior)
%           - 'frontempoleft' : left fronto-temporal 
%           - 'frontemporight' : right fronto-temporal
%           - 'bottom' : from the bottom (inferior)
%           - 'back' : from the back 
%       To display all the views, set views option to 'all' 
%       Ex. : figopt.views = {'left', 'top'};
%       [ default : 'all' ]
%       To define customed views, set the figopt.structviews structure.
%
%       - figopt.custviews : structure of customized views to display
%       Contain sub-structures of views parameters. The 1st level field 
%       NAME attached to structviews represent the name of the view 
%       (ex. 'frontotempright'), as defined by the user.
%       Each substructure of view with the NAME of the view hold two
%       fields to define the view :
%       figopt.custviews.NAME.vect : angle vector [ azimuth, elevation ] 
%       figopt.custviews.NAME.title : view title to add on the figure
%       Ex. :   fiogopt.custviews.frontotempright.vect = [-200 0];
%               fiogopt.custviews.frontotempright.title = 'Fronto-temporal Right';
%       If figopt.views is defined too, the customized views are added to
%       those predefined views.
%       [ default : [] ]
%
%       - figopt.custcolors : vector of customized ROI colors
%
%   

%--- Check for inputs

% If subatlas field, merge the ROIpatchs and labels
if isfield(atlas, 'subatlas') && ~strcmp(atlas.tissuelabel{end}, atlas.sublabel{end})
    nsub = length(atlas.sublabel);
    for is = 1 : nsub        
        atlas.ROIpatch = [atlas.ROIpatch ; atlas.subatlas(is).ROIpatch];
    end
    atlas.tissuelabel = [atlas.tissuelabel, atlas.sublabel'];
end

% All ROI labels store in atlas
label = atlas.tissuelabel;

%--- Check for inputs

%- List of ROI names to plot
idROI = find_ROI(label, ROIlist);
if isempty(idROI)
    fprintf('\n---\n!!! No name matching between input ROI names and atlas labels')
    return;
end

%- Check for input figure options
defopt = struct('savepath', pwd, 'views', [], 'custviews', [], 'custcolors', [], 'closefig', true);
if nargin < 3
    figopt = defopt;
else
    figopt = check_opt(figopt, defopt);
end

pdir = make_dir([figopt.savepath, filesep, 'cleanROIs'],0);

%- Views options
Sview = set_views(figopt);
fview = fieldnames(Sview);

if figopt.closefig
    fvis = 'off';
else
    fvis = 'on';
end

%--- GO !

Apatch = atlas.ROIpatch;
Np = length(Apatch);
colall = [0.85 0.82 0.72];

if ~isempty(figopt.custcolors)
    ccol = true;
    colroi = figopt.custcolors;
else
    ccol = false;
    colroi = color_group(Np); %length(idROI));
end

savnam = def_savname(label, idROI);
    
% Change view according to Sview
for v = 1:length(fview)
    
    %- All ROIs to highlight (listed in ROIlist) on the same figure

    figure
    set(gcf,'visible',fvis,...
        'units','centimeters',...
        'position',[10 10 17 12.9],...
        'color',[0 0 0]);
    set(gca,'color',[0 0 0], 'position',  [0 -0.02 0.98 0.98]); %[0.05 0.05 0.95 0.95]);

    % Indices of all patches (minus the ROIs to highlight)
    ip = setxor(1:Np, idROI);
    draw_otherpatches(Apatch, ip, colall);
    
    % Add the patches of interest
    for i = 1 : length(idROI)
        ir = idROI(i);
        hroi = patch(Apatch{ir}, 'edgecolor','none',...
            'facealpha',0.95,... 
            'facelighting','gouraud');
        if ccol
            % Customized color for each ROI 
            set(hroi, 'facecolor', colroi(i, :))
        else
            % Default ROI color
            set(hroi, 'facecolor', colroi(ir, :))
        end
    end

    view(Sview.(fview{v}).vect)
    camlight('right','infinite'); 
    axis equal off;
    
    annotation(gcf,'textbox','String', Sview.(fview{v}).title,...
    'interpreter','none','FontSize',13,'fontname','AvantGarde','color',[1 1 1],...
    'LineStyle','none','HorizontalAlignment','center',...
    'FitBoxToText','off','Position',[0 0.9107 1 0.08]);
    
    export_fig([pdir, filesep,'atlasROIclean_', savnam,'_',fview{v},'.jpg'],'-m1.5')  
end

if figopt.closefig
    close all
end

function hpa = draw_otherpatches(ROIpatch, ipatch, col)
    Np = length(ipatch);
    ip = ipatch;
    hpa = zeros(Np,1);
    for p = 1: length(ip)
        hpa(p) = patch(ROIpatch{ip(p)}, 'edgecolor','none',...
                'facecolor',col ,'facealpha',0.25,... %0.35
                'facelighting','gouraud');
    end

function savname = def_savname(label, idROI)

    % Set name of figure file
    roilab = label(idROI);
    Nr = length(roilab);
    compnam = cell(Nr, 1);
    for i = 1 : Nr
        rsp = strsplit(roilab{i}, '_');
        clet = char(rsp');
        clet = clet(:,1)';            
        compnam{i} = clet;
    end

    unam = unique(compnam);
    combnam = ['_', strjoint(unam,'_')];
    if length(combnam) > 30
        combnam = [combnam(1:19),'_',datestr(now,'yymmdd_HHMM')];
    end
  
    savname = [num2str(length(idROI)),'ROIs',combnam];

%--- Check figopt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end

%--- Define all views : BE CAREFULL : views defined for atlas made after
%   ft_CREx toolbox processing (using coregistration with Colin27_BS
%   template used for source modelling by beamformer without aMRI)
function Sall = set_allviews
allv = {'left','right','frontal', 'top',...
    'frontempoleft', 'frontemporight', 'bottom', 'back'};
tview = {'Lateral left','Lateral right','Frontal', 'Superior',...
    'Fronto-temporal left', 'Fronto-temporal right', 'Inferior', 'Back'};
vview = [-90 0 ; 90 0 ; -180 0 ; 0 90; 
        -122 -2; 122 -2 ; 180 -90 ; 0 0]; 

Sall = struct;
for i = 1:length(allv)
    Sall.(allv{i}).title = tview{i};
    Sall.(allv{i}).vect = vview(i,:);    
end

%--- Check views to display options
function Sview = check_views_opt(vopt, Sall)


allv = fieldnames(Sall);

if any(strcmp(vopt,'all'))
    Sview = Sall;
else
    Sview = struct;
    if ischar(vopt)
        vopt = {vopt};
    end
    j = 1;
    for v = 1 : length(vopt)
        iv = find(strcmpi(allv, vopt{v})==1);
        if ~isempty(iv)
            Sview.(allv{iv}) = Sall.(allv{iv});
            j = j+1;
        end
    end
    if j==1
        Sview = Sall;
    end
end

function Sview = set_views(figopt)

% Empty predefined view structure
if isempty(figopt.views)
    % Apply customized views
    if ~isempty(figopt.custviews)
        Sview = figopt.custviews;
    else
        % Default views definition (according to atlas store in 
        % atlas_Colin27_BS.mat)
        Sview = set_allviews ;
    end
else
    % Define predefined views structure
    Sview  = check_views_opt(figopt.views, set_allviews);
    % Add the customized views definitions
    if ~isempty(figopt.custviews)
        fcv = fieldnames(figopt.custviews);
        for ic = 1 : length(fcv)
            Sview.(fcv{ic}) = figopt.custviews.(fcv{ic});
        end
    end
end        

 
 