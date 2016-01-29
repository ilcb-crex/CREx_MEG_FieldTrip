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
%       opt.views   :   angle of views to display (string or cellule of
%                   strings to display several kind of views)
%                    Available views are : 
%                       - 'left' : view of the lateral left side
%                       - 'right' : lateral right
%                       - 'frontal' : frontal view
%                       - 'top' : from the top (superior)
%                       - 'frontempoleft' : left fronto-temporal 
%                       - 'frontemporight' : right fronto-temporal
%                       - 'bottom' : from the bottom (inferior)
%                       - 'back' : from the back 
%                   To display all the views, set views option to 'all' 
%                   Ex. : figopt.views = {'left', 'top'};
%                   [ default : 'all' ]
%                   To define customed views, set the figopt.structviews 
%                   structure.
%
%       opt.custviews : structure of customized views to display
%                   Contain sub-structures of views parameters. The 1st 
%                   level field NAME attached to structviews represents the 
%                   name of the view (ex. 'frontotempright'), as defined by 
%                   the user. Each substructure of view with the NAME of 
%                   the view hold two fields to define the view :
%           opt.custviews.NAME.vect : angle vector [ azimuth, elevation ] 
%       	opt.custviews.NAME.title : view title to add on the figure
%           Ex. :   opt.custviews.frontotempright.vect = [-200 0];
%                   opt.custviews.frontotempright.title = 'Fronto-temporal Right';
%           If opt.views is defined too, the customized views are added to
%           those predefined views.
%           [ default : [] ]
%
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

% If subatlas field, merge the ROIpatchs and labels
if isfield(atlas, 'subatlas') && ~strcmp(atlas.tissuelabel{end}, atlas.sublabel{end})
    nsub = length(atlas.sublabel);
    for is = 1 : nsub
        
        atlas.ROIpatch = [atlas.ROIpatch ; atlas.subatlas(is).ROIpatch];
    end
    atlas.tissuelabel = [atlas.tissuelabel, atlas.sublabel'];
end

% Add atlas name to the directory name
if ~isempty(apath)
    [~, aname] = dir(apath);
    aname = ['_', aname];
else
    aname = [];
end

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
    