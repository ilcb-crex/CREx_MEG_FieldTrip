function sourceGA_aROI = meg_aROIsubj_calc(sourceGA, opt)
% Compute the mean signal of source signals per ROI and subjects
%
% sourceGA is the data structure that hold all of the sources signals of 
% the study. The calculation are done on each (param) field found in the
% sub-structures of results.
% This sub-structure comes from FieldTrip source computation by 
% ft_sourceanalysis, post-processed in order to extract source signal per
% dipole and subjects. It contains the fields, among others :
%       pos [Ndip_all x 3]
%       inside [Ndip_all x 1]
%       (param) [ Nsubj x Ndip_inside x Ntime ] : the source signals      
%       subj : cell with subjects names (optional)
%
% Possible general architecture of sourceGA :
% - a single structure of result with the fields specified above
% - an embedded structure of results with several fields : 
%       - sourceGA.(condition_name)
%       - or sourceGA.(group_name).(condition_name)
% 
% opt is the structure of parameters : 
% opt.atlas : atlas containing ROI location (FieldTrip format) 
% opt.dipid : ROI indices for each dipoles 
% opt.cond : conditions (as indicated as sourceGA.(cat) fieldnames)

%--- Check options
defopt = struct('atlas','atlas_Colin27_BS', 'dipid', [],...
                'cond', [], 'param' , 'z',...
                'method', 'each');
if nargin < 2 || isempty(opt)
    opt = defopt;
else
    opt = check_opt(opt, defopt);
end

%--- Check general structure of sourceGA
sourceGA = check_Sdat(sourceGA, opt.param);
               
cat = fieldnames(sourceGA);
allcond = fieldnames(sourceGA.(cat{1}));

if isempty(opt.cond)
    opt.cond = allcond;
end

cond = opt.cond;

if ischar(opt.atlas) % Try loading default atlas 
    load(opt.atlas, 'atlas');  
else
    atlas = opt.atlas;
end

%--- Coregistration of dipole positions with atlas
if isempty(opt.dipid) % Make it even if it's long    
    source = sourceGA.(cat{1}).(cond{1});
    dipos = source.pos(source.inside,:);
	opt.dipid = meg_atlas_coregdip(dipos, atlas); 
end

if strcmp(opt.method, 'diff') && length(cond(1,:)) > 1
    fdif = true;
    diffcond = cond;
    cond = diffcond(:,1);
else
    fdif = false;
end

dipid = opt.dipid;

sparam = opt.param;

Alab = atlas.tissuelabel;
Ntis = length(Alab);

time = sourceGA.(cat{1}).(cond{1}).time;

sourceGA_aROI = struct;
for i = 1 : length(cat)
    sourceROI = struct;
    for c = 1 : length(cond)
        if fdif
            co = [ diffcond{c, 1},'_', diffcond{c, 2}];
            avg1 = sourceGA.(cat{i}).(diffcond{c,1}).(sparam);
            avg2 = sourceGA.(cat{i}).(diffcond{c,2}).(sparam);
        else
            co = cond{c};
            % Source signal over subjects
            avg = sourceGA.(cat{i}).(cond{c}).(sparam);
        end

        sourceROI.(co).avgROIsubj = cell(Ntis, 1);
        sourceROI.(co).numdip = zeros(Ntis, 1);
        sourceROI.(co).label = Alab;
        sourceROI.(co).time = time;
        if isfield(sourceGA.(cat{i}).(cond{c}), 'subj')
            sourceROI.(co).subj = sourceGA.(cat{i}).(cond{c}).subj;
        end
        
        for n = 1 : Ntis
            idip = find(dipid == n);
            % Average over dipoles found inside ROI
            if ~isempty(idip)
                if fdif
                    davg = avg1(:,idip,:) - avg2(:,idip,:);
                else
                    davg = avg(:,idip,:);
                end
                if length(idip)>1
                    sourceROI.(co).avgROIsubj{n} = squeeze(mean(davg,2));
                else
                    sourceROI.(co).avgROIsubj{n} = squeeze(davg);
                end
                sourceROI.(co).numdip(n) = length(idip);
            end
        end
    end  
    sourceGA_aROI.(cat{i}) = sourceROI; 
end

%--- Check opt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end

%--- Check source data structure
function Sdat = check_Sdat(Sdat, param)

%- Single data
okdat = 0;
if isfield(Sdat, param)
    Sdat = struct('single_grp', struct('single_cond', Sdat));
    okdat = 1;
else
    fnames_1 = fieldnames(Sdat);
    %- Maybe conditions - adding group field
    if ~isempty(fnames_1)
        if isfield(Sdat.(fnames_1{1}), param)
            Sdat = struct('single_grp', Sdat);
            okdat = 1;
        else
            fnames_2 = fieldnames(Sdat.(fnames_1{1}));
            if ~isempty(fnames_2) && isfield(Sdat.(fnames_1{1}).(fnames_2{2}), param)
                okdat = 1;
            end
        end
    end
end
if okdat==0
    Sdat = [];
    disp('Source data signal cannot be found inside data structure (sourceGA)')
    return;
end