load('atlas_Colin27_BS')

%---- Define atlas coordinates as a N*3 matrix (N = prod(dim) = 902629) 
dim = atlas.dim;
[X, Y, Z]  = ndgrid(1:dim(1), 1:dim(2), 1:dim(3));
Apos   = [X(:) Y(:) Z(:)];

Sroi = extract_atlas_ROIsurf(atlas, Apos);

% pos must only contain integer values to avoid Out of memory errors when 
% defining the grid by ndgrid
% So we can't extract surfaces from head coordinates (pos2), but we will 
% express it in head coordinates now :

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

%---- Associate tissue identification number
id_tis = atlas.tissue(:); %  902629x1 

%---- Figure

Alab = atlas.tissuelabel;

Ntis = length(Alab);
colc = color_group(Ntis);


figure, 
set(gcf,'units','centimeters', 'position', [10 7 28 20],'color',[0 0 0])
set(gca,'position',[0.005 0.00 .99 .92],'color',[0 0 0]) 
hold on

patch(Vol_bs,'edgecolor','none','facecolor',[0 .9 .9],'facealpha',.1,...
    'facelighting','gouraud','hittest','off');
patch(Ctx_bs,'edgecolor','none','facecolor',[1 .8 0],'facealpha',.15,...
    'facelighting','gouraud','hittest','off');
for n = 1 : Ntis
    ig = find(id_tis == n);
    proi = patch(Sroi2{n},'edgecolor', 'none', 'facecolor', colc(n,:),...
        'facealpha', .1, 'facelighting','gouraud','displayname',Alab{n});
end
view(130, 30) 
axis tight equal off;
set(gcf, 'WindowButtonDownFcn', @dispname);

atlas.ROIpatch = Sroi2;

save('atlas_Colin27_BS','atlas')

