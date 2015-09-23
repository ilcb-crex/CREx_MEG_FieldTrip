function Sroi = extract_atlas_ROIsurf(atlas, pos)
% Suppose no hole to fill

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
