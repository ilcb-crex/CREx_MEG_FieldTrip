function sdat=sepcond_catsem_visuaudio(datori)

modal={'Audio';'Visu'};
fnam=fieldnames(datori);

if isfield(datori,'fnam')
    C=char(datori.fnam);
else
    C=[];
end

sdat=cell(length(modal),1);
j=1;
if ~isempty(C)
    for i=1:length(modal)
        Cp=cellstr(C(:,1:length(modal{i})));
        fc=strcmpi(modal{i},Cp);
        if sum(fc)>0
            dat=struct;
            for nf=1:length(fnam)
                dato=datori.(fnam{nf});
                sz=size(dato);
                if sz(1)~=length(datori.fnam) && sz(2)~=length(datori.fnam)
                    dat.(fnam{nf})=dato;
                else
                    if iscell(dato)
                        dat.(fnam{nf})=dato(fc);
                    end
                    if isnumeric(dato)
                        if sz(1)>1 && sz(2)>1  % Un tableau (a priori lignes a ajoutees)
                            dat.(fnam{nf})=dato(fc,:);
                        else
                            dat.(fnam{nf})=dato(fc);
                        end
                    end  
                end
            end
            dat.modal=modal{i};
            sdat{j}=dat;
            j=j+1;
        end
    end
end
if j-1>0
    sdat=sdat(1:j-1);
else
    sdat=[];
end

        
    
    
    
