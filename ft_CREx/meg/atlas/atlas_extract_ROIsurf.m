function Sroi = atlas_extract_ROIsurf(atlas, pos)
% Extract patch surface of the atlas volume (defining as atlas.tissue > 0) 
% To extract surface, we need the original 3D volumes containing tissues
% identification numbers (atlas.tissue, Nx x Ny x Nz matrix) and the 
% positions of all voxels as a M x 3 matrix (pos : M x 3, M = Nx*Ny*Nz).
% To use isosurface function from Matlab to extract surface, we need to 
% fill the holes being inside the volume.

id_tis = atlas.tissue(:); 

utis = unique(id_tis);
utis = utis(utis>0);

Ntis = length(utis);
    
Sroi = cell(Ntis, 1);

% Define all coordinates (full size)
zuf = sort(unique(pos(:,3)));
yuf = sort(unique(pos(:,2)));
xuf = sort(unique(pos(:,1)));
[Xn, Yn, Zn] = ndgrid(xuf, yuf, zuf);  

% Refined grid
% In order to reduce the distance between the surfaces
zr = min(zuf) : 0.5 : max(zuf);
yr = min(yuf) : 0.5 : max(yuf);
xr = min(xuf) : 0.5 : max(xuf);
[Xrn, Yrn, Zrn] = ndgrid(xr, yr, zr);  

for nt = 1 : Ntis
    
    idbin = id_tis;
    idbin(idbin ~= utis(nt)) = 0;
    idbin(idbin == utis(nt)) = 1;

    V = atlas.tissue;
    V(:) = idbin;
       
    Vrn = interpn(Xn, Yn, Zn, V, Xrn, Yrn, Zrn);

    Sroi{nt} = isosurface(Xrn,Yrn,Zrn,Vrn, 0.5); %0.99);
    % Sroi{nt} = isosurface(Xn,Yn,Zn,V, 0.99);
end
