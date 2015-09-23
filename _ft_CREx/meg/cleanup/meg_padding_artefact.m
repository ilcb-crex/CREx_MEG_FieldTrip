function cleanpadData = meg_padding_artefact(ftData,windef)
% Les portions des donnees contenues dans les fenetres temporelles windef
% sont remplacees par l'image miroire des donnees qui precedent ou qui
% succedent cette fenetre.
% Si la portion a supprimer est trop longue et donc pas possible de
% remplacer par l'image miroire, la portion est remplacer par des zeros.

td = ftData.time{1};
xall = ftData.trial{1};
artpad = zeros(size(windef));
for nw=1:length(windef(:,1))
    disp(' ')
    disp(['Padding data part : [ ',num2str(windef(nw,1)),' - ',num2str(windef(nw,2)),' ] s'])
    badidx = find(td>=windef(nw,1) & td<=windef(nw,2));
    lgwin = length(badidx);
    if badidx(1)-lgwin > 0
        xall(:,badidx)=xall(:,badidx(1)-1:-1:badidx(1)-lgwin);
    else
        if badidx(end)+lgwin < length(xall(1,:))
            xall(:,badidx)=xall(:,badidx(end)+1:badidx(end)+lgwin);
        else
            
            disp(' ')
            disp('----!!!!----')
            disp('Padding artefact window by ZEROS')
            disp(['windef : ',num2str(windef(nw,1)),' to ',num2str(windef(nw,2)),' s'])
            disp('----!!!!----')
            xall(:,badidx) = 0;
        end
    end
    artpad(nw,:)=[badidx(1) badidx(end)];
end

cleanpadData=ftData;
cleanpadData.trial{1}=xall;
cleanpadData.artpad=artpad;

        