% ________
% Parameters to adjust
%p0='G:\Catsem';
p0 = 'F:\BaPa';
p1 = cell(1,2);
p1(1,:)= {{p0} , 0};
p1(2,:)= {{'CAC','DYS'}, 0}; 
p1(3,:)= {{'S'}, 1}; 

% Vecteur des indices des donnees a traiter
% vdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vdo = 1:10; => sur les 10 premieres donnees
% vdo=17; : sur la 17eme donnee
vdo = []; 

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp = make_pathlist(p1);


if isempty(vdo)
    vdo = 1:length(alldp);
end

for np = vdo
    dpath = alldp{np};
    [pmat,nmat] = dirlate(dpath,'cleanTrials*.mat');
    if isempty(pmat)
        [pmat, nmat] = dirlate(dpath,'allTrials*.mat');
        ct = 0;
    else
        ct = 1;
    end
    if ~isempty(pmat)
        Strial = loadvar(pmat,'*Trial*');
        disp(' '), disp('Input data :')
        disp(pmat), disp(' ')

        ftrial = fieldnames(Strial);
        rmTrials = struct;
        
        for i = 1 : length(ftrial)
            cond = ftrial{i};
            rmTrials.(cond) = [];
            if ct == 1

                Scond = Strial.(cond);
                trl = get_field(Scond, 'trl', 'double');
                Nt = length(trl(:,1));
                if Nt > length(Scond.trial)
                    vtrials = get_field(Scond.cfg, 'trials','double');
                    rmTrials.(cond) = setxor(1:Nt, vtrials);
                end
                
            end
        end
        save([dpath, filesep, 'rmTrials'], 'rmTrials')
    end
end