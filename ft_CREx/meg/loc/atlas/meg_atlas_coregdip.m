function dip_id = meg_atlas_coregdip(dip_pos, atlas)
% Return the vector of ROI indices associated with the beamforming dipoles
% dip_pos : dipole position (should be the "inside" one)

% Atlas positions
apos = atlas.pos;

% Anatomical ROI identification number for each atlas point
id_tis = atlas.tissue(:);

% Determination of dipole identification number of tissue
dip_id = zeros(length(dip_pos(:,1)),1);
for n = 1 : length(dip_pos(:,1))
    rpos = repmat(dip_pos(n,:), length(apos(:,1)), 1);
    %--- Distances between dipole position and each atlas position
    dist = sqrt( sum( (apos - rpos).^2, 2));
    % Minimal distance
    imin = find(dist == min(dist));
        
    % If not corresponding to a tissue (outside the brain), search the 
    % closest one (< 10 mm from the dipole)
    % Without this search : 659 dipoles were associated with an outside
    % tissue (id_tis = 0)
    % With this more flexible search : 40 dipoles fall still outside the atlas  
    % Most of these dipoles are located in front from the cerebellum 
    if ~id_tis(imin)
        iclose = find(dist < 10 & id_tis ~=0);  %<= 4 ?
        if ~isempty(iclose)
            imin = iclose(dist(iclose)==min(dist(iclose)));
        end
    end
        
    dip_id(n) = id_tis(imin);
end