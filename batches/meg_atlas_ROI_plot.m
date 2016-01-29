function meg_atlas_ROI_plot(ROIlist, opt)
% Generate figures of anatomical ROIs whose label names match with ROIlist 
% search string expressions. Atlas labels of all ROIs are stored in 
% atlas.tissuelabel.
%
% Ex.: 
% (1) ROIlist = 'tempo*r' : each Temporal_*_R ROI will be drawing
% including : 'Temporal_Sup_R', 'Temporal_Pole_Sup_R', 'Temporal_Mid_R'
% 'Temporal_Pole_Mid_R' and 'Temporal_Inf_R'
% (2) ROIlist = {'frontal*L', 'tempo*L'} : all ROIs whose name match with
% Frontal*L and Temporal*L in atlas.tissuelabel labels
%
% ---
% Available options :
%       opt.atlas   : atlas containing ROIs (structure previously return
%                   by ft_read_atlas)
%                   [default : atlas is loaded from atlas_Colin27_BS.mat 
%                   (CREx\meg\loc\atlas)]
%
%       opt.savepath : path of directory used to save the jpg figure files
%                   [default : pwd]
%                   Figures will be saved in opt.savepath / AtlasROI_fig
%                   directory.
%       opt.views   :   - a cell of strings indicating views to display the 3D
%                           volume ('left', 'right', 'superior', 'frontal', 
%                           'frontempoleft', 'frontemporight', or 'all')
%                       - a single string to display only one view 
%                       - or 'all' 
%                       [default : 'all']
%       opt.closefig : flag to indicate if the figures are saved then
%                   automatically closed or let open to do some post-processing
%                   [default : true]
%
% Note that the values of azimuths and elevations to display the 3D volume
% according to the different views, are predefined for atlas stored in 
% atlas_Colin27_BS.mat.
% You could change these definitions inside the subfunction set_allviews
% of the present script.
%

%--- Check for inputs
if nargin == 0
    disp('First argument ROIlist is missing.')
    disp('See you soon...')
    return;
end

defopt = struct('atlas', [],...
                'apath', [],...
                'savepath', pwd,...
                'views', 'all',...
                'closefig', true );
opt = check_opt(opt, defopt);

% If atlas path set in opt structure apath field, and atlas field is
% empty, load the atlas apath
apath = opt.apath;
if ~isempty(apath) && isempty(opt.atlas) && ~isempty(dir(apath))
    opt.atlas = loadvar(apath, 'atlas');
end

% Load the default atlas if empty path and atlas
if isempty(opt.atlas)
    disp('Load default atlas : atlas_Colin27_BS.mat')
    disp('from ft_CREx toolbox')
    opt.apath = 'atlas_Colin27_BS.mat';
    atlas = loadvar(opt.apath, 'atlas*');
else
    atlas = opt.atlas;   
end

% Add atlas name to the directory name
[~, aname] = dir(apath);
aname = ['_', aname];

% Check for view options
opt.Sviews = set_allviews;

opt.savepath = make_dir([opt.savepath, filesep, 'AtlasROI_fig',aname], 1);

%--- Find ROI to plot according to searchname list
label = atlas.tissuelabel;
[idROI, labROI] = find_ROI(label, ROIlist);

%--- Make the figures

%- One figure per ROI
meg_atlas_ROI_single_fig(atlas, labROI, opt)

%- Superimposition of all ROIs on the same figure
if length(idROI) > 1
    meg_atlas_ROI_multi_fig(atlas, labROI, opt)
end

%- Paper style figures
meg_atlas_ROI_clean_fig(atlas, labROI, opt)


%--- Check figopt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end

%--- Define all views 
function Sall = set_allviews
allv = {'left','right','frontal', 'frontempo', 'superior'};
tview = {'Lateral Left','Lateral Right','Frontal', 'Fronto-temporal', 'Superior'};
vview = [-90 0 ; 90 0 ; -180 0 ; -122 -2; 0 90]; 

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
    