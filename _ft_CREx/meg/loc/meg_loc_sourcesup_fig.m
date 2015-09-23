function meg_loc_sourcesup_fig(sourC, tBSL, fnam, fdos, trialmatpath)
% sourC : le resultat de ft_sourceanalysis
% fnam : nom de la condition (defaut : 'Cond')
% fdos : nom du dossier ou sauver les figures (defaut : pwd)
% nSallt : nom de la matrice contenant les essais, utilisee a l'origine
% (defaut : 'unkwnTrialData')

if nargin < 2
    tBSL = [sourC.time(1) 0];
end

if nargin<3
    fnam = 'Cond';
end

if nargin<4
    fdos = pwd;
end

if nargin<5
    pSallt = fdos;
else
    pSallt = trialmatpath;
end

fnamt = fnam;
fnamt(fnamt=='_') = '-';
fnamf = fnam;
fnamf(fnam=='-') = '_';
fnamf(fnam=='.') = 'p';
                            
mom = sourC.avg.mom;
time = sourC.time;
iBSL = find(time > tBSL(1) & time < tBSL(2));
% Construction du tableau de valeur (plus rapide a tracer en une fois que
% de tracer la cellule dans une boucle)
momt = cell2mat(mom);
meanmomt = repmat(mean(momt(:,iBSL),2),1,length(time));
stdmomt = repmat(std(momt(:,iBSL),1,2),1,length(time));
momz = (momt - meanmomt )./stdmomt;  

%______
% Mom en fonction du temps
figure
set(gcf,'visible','off','units','centimeters','position',[13 6 20 10])
hold on; box on;
plot(time,momt,'b')
xlabel('Time (s)','fontsize',14), ylabel('Magnetic moment','fontsize',14)
set(gca,'fontsize',12)
xlim([time(1) time(end)])
title({['[ ',fnamt,' ] - Source signals - Not normalized - from trials in :'];...
    pSallt},'interpreter','none','fontsize',10)
verif_label

namfig=['SourceSup_Mom_',fnamf]; 
export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')                    
close

%______
% Mom normalise = Z en fonction du temps
figure
set(gcf,'visible','off','units','centimeters','position',[13 6 20 10])
hold on; box on; 
plot(time,momz,'b')
xlabel('Time (s)','fontsize',14), ylabel('Z-normalized moment','fontsize',14)
set(gca,'fontsize',12)
xlim([time(1) time(end)])
title({['[ ',fnamt,' ] - Source signals - Z-normalized - from trials in :'];...
    pSallt},'interpreter','none','fontsize',10)

namfig=['SourceSup_NormZ_',fnamf];
export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
% saveas(gcf,[fdos,filesep,namfig,'.fig'])
close

%______
% Z au carre en fonction du temps
figure
set(gcf,'visible','off','units','centimeters','position',[13 6 20 10])
hold on; box on; 
plot(time,momz.^2,'b')
xlabel('Time (s)','fontsize',14), ylabel('Z^2-normalized moment','fontsize',14)
set(gca,'fontsize',12)
xlim([time(1) time(end)])
title({['[ ',fnamt,' ] - Source signals - Z-square normalized - from trials in :'];...
    pSallt},'interpreter','none','fontsize',10)

namfig=['SourceSup_NormZ2_',fnamf];
export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5') 
% saveas(gcf,[fdos,filesep,namfig,'.fig'])
close
