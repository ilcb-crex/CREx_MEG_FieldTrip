atlas = loadvar('atlas_Colin27_BS', 'atlas');

% Sub-ROI : cut ROI in 3 parts 
Rcut = {'Temporal_Inf'; 'Temporal_Mid'; 'Fusiform'; 'Temporal_Sup'};
ncut = [3 ; 3 ; 3 ; 2];

% Define new tissuelabel field relative to the new subROI
opt = [];
opt.ROInames = Rcut;
opt.ncut = ncut;
atlas_subROI = meg_atlas_vertcut(atlas, opt);

% Extract surface and add the new ROIpatch field to the atlas structure
atlas = meg_atlas_ROIpatch(atlas_subROI);

% Save the new atlas
Nroi = num2str(length(atlas.ROIpatch));
save(['atlas_Colin27_BS_', Nroi, '_subROI'],'atlas')

% load('F:\ADys\GA_Source_LP25Hz_Res200Hz\sourceGA_CAC_LP25Hz_Res200Hz.mat');
% dip_pos = sourceGA.Morpho.pos(sourceGA.Morpho.inside, :);
% dipid = meg_atlas_coregdip(dip_pos, atlas);
% save(['dipid_coreg_ADys_atlas_Colin27_BS_', Nroi, '_subROI'], 'dipid')