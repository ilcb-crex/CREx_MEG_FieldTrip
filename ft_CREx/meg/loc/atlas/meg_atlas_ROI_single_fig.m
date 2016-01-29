function meg_atlas_ROI_single_fig(atlas, ROIlist, figopt)
% Figures of 3D views of the ROI patches of an atlas with specific 
% highlight ROIs 
% One figure is done per ROI to underline and per view.
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
%   


%--- Check for inputs

% All ROI labels store in atlas
label = atlas.tissuelabel;

%- List of ROI names to plot
idROI = find_ROI(label, ROIlist);
if isempty(idROI)
    fprintf('\n---\n!!! No name matching between input ROI names and atlas labels')
    return;
end

%- Check for input figure options
defopt = struct('savepath', pwd, 'views', [], 'custviews', [], 'closefig', true);
if nargin < 3
    figopt = defopt;
else
    figopt = check_opt(figopt, defopt);
end

%- Figure directory
pdir = make_dir([figopt.savepath, filesep, 'singleROI'], 0);

%- Views options
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


if figopt.closefig
    fvis = 'off';
else
    fvis = 'on';
end
%--- GO !

Apatch = atlas.ROIpatch;
Np = length(Apatch);
colall = [0 0.55 0.45];
colroi = [0.87 0.49 0];

%- [ 1 ] - One figure per ROI to highlight (listed in ROIlist)
figure, set(gcf, 'visible', fvis, 'color',[0 0 0])
set(gca,'color', [0 0 0], 'position', [0.005 0.005 0.99 0.88])

for i = 1:length(idROI)

    iroi = idROI(i);
    roinam = label{iroi};
     
    % Indices of all patches (minus the ROI to highlight)
    ipo = setxor(1:Np , iroi);
    hpa = draw_otherpatches(Apatch, ipo, colall);

    % Add the patch of interest
    hroi = patch(Apatch{iroi}, 'edgecolor','none',...
                'facecolor',colroi ,'facealpha',0.9,... 
                'facelighting','gouraud');
 
    % Change view according to Sview
    save_viewsfig(Sview, roinam, pdir)

    % Figure with all views
    draw_4views([hpa; hroi], Sall, roinam, fvis)
    export_fig([pdir, filesep,'atlasROI_', roinam,'_4views.jpg'],'-m1.5')
    if figopt.closefig
        close
    end
    
    delete([hroi; hpa])
end
if figopt.closefig
    close
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
    
function save_viewsfig(Sview, ROIname, savepath)
    fview = fieldnames(Sview);
    for v = 1:length(fview)
        view(Sview.(fview{v}).vect)
        axis equal;
        hlig = camlight('right','infinite');
        title({['AAL MNI-Colin27 atlas : [ ', ROIname,' ]'];...
            [Sview.(fview{v}).title,' view']},'fontsize',13, 'color', [1 1 1],...
            'interpreter','none')
        export_fig([savepath, filesep,'atlasROI_', ROIname,'_',fview{v},'.jpg'],'-m1.5')
        delete(hlig)
    end
    
function draw_4views(phdl, Aview, ROIname, fvis)
    fv = fieldnames(Aview);
    
    hSu = zeros(4,1);
    
    figure, 
    set(gcf,'visible', fvis, 'color', [0 0 0])
    set(gcf,'units','centimeters','position', [7 4 18 14])

    %- Subplot positions
    W = 0.45;
    H = 0.375; 
    ma = 0.042; 

    pos = zeros(4,4);
    pos(1,:) = [ ma     3*ma+H   W H ];
    pos(2,:) = [ ma+W   pos(1,2) W H ];
    pos(3,:) = [ ma         ma*2   W H ];
    pos(4,:) = [ pos(2,1)   ma*2   W H ];

    for s = 1:4
        hSu(s) = subplot(2,2,s);
        copyobj(phdl, hSu(s))

        set(hSu(s), 'color', [0 0 0], 'view', Aview.(fv{s}).vect)
        camlight('right','infinite')

        axis tight equal;
        title(Aview.(fv{s}).title,'fontsize',12,'color',[1 1 1]) 
        set(hSu(s), 'position', pos(s, :))
    end
    %- Add the famous general title
    annotation(gcf,'textbox','String', ['MNI-Colin27 atlas : [ ',ROIname,' ]'],...
        'interpreter','none','FontSize',14,'fontname','AvantGarde','color',[1 1 1],...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 0.9116 0.9 0.0859]);
    
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
tview = {'Lateral Left','Lateral Right','Frontal', 'Superior',...
    'Fronto-temporal Left', 'Fronto-temporal Right', 'Inferior', 'Back'};
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
    
