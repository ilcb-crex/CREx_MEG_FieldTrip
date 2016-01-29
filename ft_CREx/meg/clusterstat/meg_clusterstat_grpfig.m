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


if isfield(Sgaroi.(cat{1}).(cond{1}), 'confintROI')
    isCI = true;
else
    isCI = false;
end
    
Da = 0.2;

ylimall = zeros(Ng, Na, 2);

for ig = 1 : Ng
    for n = 1 : length(iroi)
        ir = iroi(n);
        ycond = zeros(Nc, 2);
        for ic = 1 : Nc
            avg = Sgaroi.(cat{ig}).(cond{ic}).avgROI{ir};
            if ~isCI
                ycond(ic, 1) = min(avg);
                ycond(ic, 2) = max(avg);
            else
                % Consider confidence interval values
                ec = Sgaroi.(cat{ig}).(cond{ic}).confintROI{ir};
                ycond(ic, 1) = min(avg - ec );
                ycond(ic, 2) = max(avg + ec );
            end
        end       
        ylimall(ig, ir, 1) = min(ycond(:,1)) - Da;
        ylimall(ig, ir, 2) = max(ycond(:,2)) + Da;   
    end

end


%--- Figure options
fopt = figopt;


for i = 1 : length(cat)

    SavgROI = Sgaroi.(cat{i});
    
    clustROI = clusterROI.(cat{i});  

    
    p1 = make_dir([p0, filesep, cat{i}],0);

    fopt.savepath = p1;
    fopt.grpname = cat{i};
    ymi = min(ylimall(:,:,1));
    yma = max(ylimall(:,:,2));
    
    fopt.ylim = [ymi' yma'];

    meg_clusterstat_fig(SavgROI, clustROI, fopt)
end

