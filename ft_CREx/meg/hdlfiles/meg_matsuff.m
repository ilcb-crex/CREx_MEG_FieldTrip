function newsuff = meg_matsuff(namat,suff)

if ~isempty(namat)
    if length(namat)>4 && strcmp(namat(end-3:end),'.mat')
        namat=namat(1:end-4);
    end
    itb = strfind(namat,'_');
    if isempty(itb)
        prevsuff='';
    else
        prevsuff = namat(itb(1)+1:end);  
    end

    if nargin==2 && ~isempty(suff) && ischar(suff)
        if strcmp(suff(1),'_')
            suff=suff(2:end);
        end
        if strcmp(suff(end),'_')
            suff=suff(1:end-1);
        end
        suff(suff=='-')='_';
        suff(suff=='.')='p';
        if ~isempty(prevsuff)
            newsuff = [suff,'_',prevsuff];
        else
            newsuff = suff;
        end
    else
        newsuff = prevsuff;
    end    
else
    if nargin==2 && ~isempty(suff)
        newsuff = suff;
    else
        newsuff = '';
    end
end
