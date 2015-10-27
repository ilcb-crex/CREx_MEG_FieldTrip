function newsuff = meg_matsuff(namat, suff)
% Define new matrice name suffix (adding suff to the previous mat name
% namat suffix)
% This allowed to add processing information to the matrice data name 
% Exemple :
% Origine data name : namat = 'avgTrial_3rmC_2rmS.mat'
% Adding the string suff = '5rmT' to save the new data matrix after the
% removing of 5 bad trials :
% newsuff = meg_matsuff('avgTrial_3rmC_2rmS.mat', '5rmT')
% Give : >> newsuff = '5rmT_3rmC_2rmS'
% >> save(['avgTrials_', newsuff], 'data')


if ~isempty(namat)
    if length(namat)>4 && strcmp(namat(end-3:end),'.mat')
        namat = namat(1:end-4);
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
