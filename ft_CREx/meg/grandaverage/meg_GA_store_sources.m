function storedSources = meg_GA_store_sources(sopaths, template_grid)

if nargin < 2 || isempty(template_grid)
    addpos = false;
else
    addpos = true;
end

ini=1;
Ns = length(sopaths);
for s = 1 : Ns
    fprintf('\nStore all source data\n--> %s\n', sopaths{s})
    sourceCond = loadvar(sopaths{s},'sourceCond*'); 
    if ini == 1
        fcond = fieldnames(sourceCond);  
        storedSources =  cell2struct(cell(length(fcond),1), fcond);
    end
    for n = 1:length(fcond)
        if addpos
            sourceCond.(fcond{n}).pos = template_grid.pos;
        end
        
        % Make data lighter
        frm = {'z2', 'filter', 'ori'}; % , 'mom'
        for j = 1 : length(frm)
            if isfield(sourceCond.(fcond{n}).avg, frm{j});
                sourceCond.(fcond{n}).avg = rmfield(sourceCond.(fcond{n}).avg, frm{j});
            end
        end
  
        if ini==1
           storedSources.(fcond{n}) = cell(1, Ns);
           if n==length(fcond)
               ini = 0;
           end
        end
        storedSources.(fcond{n}){s} =  sourceCond.(fcond{n});
    end
end