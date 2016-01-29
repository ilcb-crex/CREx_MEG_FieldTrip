function atlas = meg_atlas_ROIpatch(atlas, dofig, savpath)
% Add ROIpatch field to the atlas structure
% ROIpatch field contain a cellule with the ROI patches (vertices and face
% structure) for each ROI identified by atlas.tissuelabel
% atlas provide form the coregistration of the template_Colin27_BS used for
% source modelling with the atlas_aal_ROI_MNI_V4_FT.nii by the function
% meg_atlas_coreg (which use SPM matching surface coregistration)
% sms function from fieldtrip/external/iso2mesh toolbox is used to smooth
% the patch sufaces of the ROI
% i2mpath is a ft_CREx toolbox that is used to add the iso2mesh directory
% to the matlab path

% load('atlas_Colin27_BS')
%- Figure options
if nargin < 3
    savpath = pwd;
end
if nargin < 2
    dofig = 0;
end


%---- Define atlas coordinates as a N*3 matrix (N = prod(dim) = 902629) 
dim = atlas.dim;
[X, Y, Z]  = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
Apos   = [X(:) Y(:) Z(:)];

Sroi = extract_atlas_ROIsurf(atlas, Apos);

% pos must only contain integer values to avoid Out of memory errors when 
% defining the grid by ndgrid
% So we can't extract surfaces from head coordinates (pos2), but we will 
% express it in head coordinates now, using M1 transform matrix :

M1 = atlas.transform;
Sroi2 = Sroi;

i2mpath('add')
for n = 1 : length(Sroi2)  
    % Transform to head space coordinates
    % Vertices tranform only
    vert = Sroi2{n}.vertices;
    vert(:,4) = 1;
    vert = vert * M1'; 
    vert = vert(:, 1:3);
    % Smooth patch
    vert = sms(vert, Sroi2{n}.faces, 20, 0.8, 'lowpass' );  
    Sroi2{n}.vertices = vert;
end

atlas.ROIpatch = Sroi2;

% save('atlas_Colin27_BS','atlas')

%---- Figure
if dofig    
    meg_atlas_ROIpatch_disp(atlas, savpath)
end


