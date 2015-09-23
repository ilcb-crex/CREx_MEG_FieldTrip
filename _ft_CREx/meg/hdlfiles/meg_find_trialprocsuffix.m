function suffprep = meg_find_trialprocsuffix(namat)

if length(namat)>4 && strcmp(namat(end-3:end),'.mat')
    namat=namat(1:end-4);
end
S=strsplit(namat,'_')';
C=char(S);
suffprep=cell(3,1);
i=1;
% LP
vok=strcmp(cellstr(C(:,1:2)),'LP');
if sum(vok)==1
    suffprep{i}=S{vok};
    i=i+1;
end
% Res
vok=strcmp(cellstr(C(:,1:3)),'Res');
if sum(vok)==1
    suffprep{i}=S{vok};
    i=i+1;
end
% Crop
if length(C(1,:))>4
    vok=strcmp(cellstr(C(:,1:4)),'Crop');
    if sum(vok)==1
        suffprep{i}=S{vok}; 
        i=i+1;
    end    
end
if i-1>0
    suffprep=strjoint(suffprep(1:i-1)','_');
else
    suffprep='';
end
