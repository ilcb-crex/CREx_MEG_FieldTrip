function meg_clusterstat_grpfig(Sgaroi, clusterROI, figopt)

%---- General variable
% Groupe names
cat = fieldnames(Sgaroi);
% Condition names
cond = fieldnames(Sgaroi.(cat{1}));

iroi = figopt.iROI;
p0 = figopt.savpath;

% For each ROI, we need to determine the ylim to apply for all conditions
% and for the set of groupes of participant
Ng = length(cat);
Nc = length(cond);
Na = length(Sgaroi.(cat{1}).(cond{1}).label);
YL = zeros(Na,2);

if isfield(Sgaroi.(cat{1}).(cond{1}), 'confintROI')
    isCI = true;
else
    isCI = false;
end
    
Da = 0.2;
for n = iroi
    yc = zeros(Nc, 2);
    for ic = 1 : Nc
        yg = zeros(Ng, 2);
        for ig = 1 : Ng
            if ~isCI
                yg(ig, 1) = min(Sgaroi.(cat{ig}).(cond{ic}).avgROI{n});
                yg(ig, 2) = max(Sgaroi.(cat{ig}).(cond{ic}).avgROI{n});
            else
                % Consider confidence interval values
                ec = Sgaroi.(cat{ig}).(cond{ic}).confintROI{n};
                yg(ig, 1) = min(Sgaroi.(cat{ig}).(cond{ic}).avgROI{n}-ec);
                yg(ig, 2) = max(Sgaroi.(cat{ig}).(cond{ic}).avgROI{n}+ec);
            end
        end
        yc(ic, 1) = min(yg(:,1));
        yc(ic, 2) = max(yg(:,2));
    end
    YL(n,1) = min(yc(:,1))-Da;
    YL(n,2) = max(yc(:,2))+Da;
end

%--- Figure options
fopt = figopt;
fopt.ylim = YL;

for i = 1 : length(cat)

    SavgROI = Sgaroi.(cat{i});
    
    clustROI = clusterROI.(cat{i});  

    
    p1 = make_dir([p0, filesep, cat{i}],0);

    fopt.savepath = p1;
    fopt.grpname = cat{i};

    meg_clusterstat_fig(SavgROI, clustROI, fopt)
end

