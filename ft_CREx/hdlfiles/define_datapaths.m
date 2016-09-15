function [allpath, subj, grp, proj] = define_datapaths(pcell, isubj, igrp, iproj)
% In addition to return all the data paths found using pcell directories
% architecture (see make_pathlist), the subject and group names are
% associated to each data path 
% Works only if the subject and group names appear as directory name in
% directories architecture.
% 
% p0 = 'F:\BaPa';
% pcell = {{p0} , 0
%           {'CAC', 'DYS'}, 0 
%           {'S'}, 1
%          }; 
% isubj = 3;
% igrp = 2;

Nsubc = length(pcell(:,1));

% Define all path list
allpath = make_pathlist(pcell);
Np = length(allpath);

if nargin>=2 && ~isempty(isubj)
    fsubj = 1;
    if isubj < Nsubc
        allsubj = make_pathlist(pcell(1:isubj,:));
    else
        allsubj = allpath;
    end
    Ns = length(allsubj);
else
    fsubj = 0;
end

if nargin>=3 && ~isempty(igrp)
    fgrp = 1;
    if igrp < Nsubc
        allgrp = make_pathlist(pcell(1:igrp,:));
    else
        allgrp = allpath;
    end 
    Ng = length(allgrp);
else
    fgrp = 0;
end

if nargin==4 && ~isempty(iproj)
    fproj = 1;
    if iproj < Nsubc
        allproj = make_pathlist(pcell(1:iproj,:));
    else
        allproj = allpath;
    end 
    Npj = length(allproj);
else
    fproj = 0;
end

subj = cell(Np, 1);
grp = cell(Np, 1);
proj = cell(Np, 1);

for i = 1 : Np
    dpath = allpath{i};
    if fsubj
        for j = 1 : Ns
            ssubj = allsubj{j};
            if strfind(dpath, ssubj)
                [~, subj{i}] = fileparts(ssubj);
            end
        end
    end
    
    if fgrp
        for k = 1 : Ng
            sgrp = allgrp{k};
            if strfind(dpath, sgrp)
                [~, grp{i}] = fileparts(sgrp);
            end
        end
    end
    
    if fproj
        for g = 1 : Npj
            sproj = allproj{g};
            if strfind(dpath, sproj)
                [~, proj{i}] = fileparts(sproj);
            end
        end
    end    
end
                
            
    



