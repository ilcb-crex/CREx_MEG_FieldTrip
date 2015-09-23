function storedERF = meg_GA_store_ERF(avgpaths)

ini=1;
Ns = length(avgpaths);
cfg = struct('removemean','no');
for s = 1 : Ns
    fprintf('\nStore all ERF data\n--> %s\n', avgpaths{s})
    avgCond = loadvar(avgpaths{s},'avg*'); 
    if ini == 1
        fcond = fieldnames(avgCond);  
        storedERF =  cell2struct(cell(length(fcond),1), fcond);
    end
    for n = 1 : length(fcond)        
        % Make data lighter
        avgCond.(fcond{n}).cfg.previous = [];
  
        if ini==1
           storedERF.(fcond{n}) = cell(1, Ns);
           if n==length(fcond)
               ini = 0;
           end
        end
        storedERF.(fcond{n}){s} =  ft_timelockanalysis(cfg, avgCond.(fcond{n}));
    end

end