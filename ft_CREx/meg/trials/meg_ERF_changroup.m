function meg_ERF_changroup(dpath, matpref, strproc)

disp(' '), disp(['--> ', dpath])
fprintf('\n\n\t-------\nERF analysis : ERF plots for groups of channels\n\t-------\n')

matname = [matpref, '*', strproc,'*.mat'];

fprintf('\nSearch of : %s\nInside : %s\n\n', matname, dpath);

[pavg, navg] = dirlate(dpath, matname);

if isempty(pavg)   
    return;
end

disp(['Using : ', navg]) 
avgCond = loadvar(pavg,'avgTrialsCond*'); 

pavgp = [fileparts(pavg), filesep, 'avgTrials', strproc,'.mat'];

fcond = fieldnames(avgCond); 


fdos = make_dir([dpath,filesep,'ChanGroupERFPlots', strproc],1);
      
Sgrad = avgCond.(fcond{1}).grad;
lab = avgCond.(fcond{1}).label;
[Gindex,Gnam] = meg_chansplit(Sgrad,lab,fdos);

% Figures of ERF per groups of channels (mean ERF and each
% ERF per channels)  
for n = 1:length(fcond)
    fdirc = make_dir([fdos,filesep,fcond{n}]);
    meg_chansplit_fig(avgCond.(fcond{n}), Gindex, Gnam, fdirc, pavgp)
end

% Figures of superposition of ERF per groups of channels 
% (mean ERF and each ERF per channels) 
effects = combine_cond(fcond);

for e = 1:length(effects)
    tosup = effects{e};
    data = cell(length(tosup),1);
    namcond = cell(length(tosup),1);
    okall = ones(length(tosup),1);
    for s = 1:length(tosup)
        icond = strfind(fcond,tosup{s});
        if isempty(cell2mat(icond))
            okall(s)=0;
        else
            for n = 1:length(fcond)
                if ~isempty(icond{n})
                    ia = n;
                end
            end
            data{s} = avgCond.(fcond{ia});
            namcond{s} = fcond{ia};
        end
    end
    if all(okall)
        fdirc = make_dir([fdos,filesep,'Sup_',strjoin(namcond','_')]);
        meg_chansplitsupcond_fig(data, namcond, Gindex, Gnam, fdirc, pavgp)
    end
end

function effects = combine_cond(fcond)
% Nombre de combinaisons possibles pour representer les ERF superposes par
% paire de conditions
n_ele = length(fcond);
k = 2;
nbcomb = factorial(n_ele)./(factorial(k) .* factorial(n_ele-k) ); 
co = 1;

effects = cell(nbcomb,1);
for i = 1 : length(fcond)-1
    cond1 = fcond{i};
    for j = i+1 : length(fcond)
        cond2 = fcond{j};
        effects{co} = {cond1, cond2}; 
        co = co + 1;
    end
end
% Add all effects superimposition if the number of conditions is > 2
if length(fcond) > 2
    effects = [effects ; {fcond}];
end
        