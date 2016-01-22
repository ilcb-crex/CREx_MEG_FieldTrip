function sourceGA_aROI = meg_aROI_calc(sourceGA, opt)
% Compute the mean signal of source signals per ROI over subjects
% Confidence intervals values are added if opt.method = 'each'.
%
% sourceGA is the data structure that hold of the sources signals of the 
% study
% Possible general architecture :
% - a single structure of data with at least the fields :
%       pos [Ndip_all x 3]
%       inside [Ndip_all x 1]
%       (param) [ Nsubj x Ndip_inside x Ntime ] : the source signals
%       
%       subj : cell with subjects names (optional)

% at 1 level : sourceGA.(group_name).(condition_name)
% at 2 levels : sourceGA.(group_name).(condition_name)
% opt is the structure of parameters : 
% opt.atlas : atlas containing ROI location (FieldTrip format) 
% opt.dipid : ROI indices for each dipoles 
% opt.cond : conditions (as indicated as sourceGA.(cat) fieldnames)


cat = fieldnames(sourceGA);
allcond = fieldnames(sourceGA.(cat{1}));

defopt = struct('atlas','atlas_Colin27_BS', 'dipid', [],...
                'cond', allcond, 'param' , 'z',...
                'method', 'each');
if nargin < 2 || isempty(opt)
    opt = defopt;
else
    opt = check_opt(opt, defopt);
end

% Confidence interval parameters
pci = 0.95;
alpha = 1 - pci;

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
for i = 1:length(cat)
    sourceROI = struct;
    for c = 1 : length(cond)
        if fdif
            co = [ diffcond{c, 1},'_', diffcond{c, 2}];
            avg1 = squeeze(mean(sourceGA.(cat{i}).(diffcond{c,1}).(sparam)));
            avg2 = squeeze(mean(sourceGA.(cat{i}).(diffcond{c,2}).(sparam)));
        else
            co = cond{c};
            % Average over subjects
            avg = squeeze(mean(sourceGA.(cat{i}).(cond{c}).(sparam)));
            % For CI calculation - keep subject values
            ssu = sourceGA.(cat{i}).(cond{c}).(sparam);
        end

        sourceROI.(co).avgROI = cell(Ntis, 1);
        sourceROI.(co).numdip = zeros(Ntis, 1);
        sourceROI.(co).label = Alab;
        sourceROI.(co).time = time;
        sourceROI.(co).subj = sourceGA.(cat{i}).(cond{c}).subj; % Keep subject info
        for n = 1 : Ntis
            idip = find(dipid == n);
            % Average over dipoles found inside ROI
            if ~isempty(idip)
                if fdif
                    davg = avg1(idip,:) - avg2(idip,:);
                else
                    davg = avg(idip,:);
                    ssuroi = ssu(:,idip,:);
                end

                if length(idip)>1
                    %- Average over the dipoles
                    sourceROI.(co).avgROI{n} = squeeze(mean(davg));
                    %- By keeping subjects mean values
                    ssuavg = squeeze(mean(ssuroi, 2));
                    
                else
                    sourceROI.(co).avgROI{n} = davg;
                    ssuavg = squeeze(ssuroi);
                end
                % Confidence intervals (at each time, relative to the
                % subjects)
                % xbar = mean(ssuavg);
                if n == 1
                    ns = length(ssuavg(:,1));
                    % t_ci = 1.96; % CI at confidence level of 95% 
                    t_ci = tinv(1-alpha/2, ns -1);
                end
                sigma = std(ssuavg);
                ec = t_ci * sigma./sqrt(ns);
               % CI = [xbar - ec ;
               %     xbar + ec];
               % To be use with boundedline, so ec only needed
                sourceROI.(co).confintROI{n} = ec;               
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