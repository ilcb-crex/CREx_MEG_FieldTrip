function meg_fft_fig(FTData,freq,allFFT,rawdatapath,pathsavfig,datatyp)
% Genere les figures representant les donnees MEG brutes et les spectres en
% frequence associes.
% Mise en forme tres specifique

if nargin<6
    datatyp='raw';
    typtit='Raw';
else
    switch datatyp
        case 'raw'
            typtit='Raw';
        case 'filt'
            typtit='Filtered';
        otherwise
            typtit=['Preprocessed (',datatyp,')'];
    end
end
if nargin<5 || isempty(dir(pathsavfig))
    pathsavfig=make_dir([pwd,filesep,'FFTplots'],1);
end
if nargin<4
    rawdatapath=pwd;
end

td = FTData.time{1};
xall = FTData.trial{1};

lgc = length(xall(:,1));
nbp = 6; % Une figure par 6 canaux
vfig = 1:nbp:lgc;

% Vecteur utilise pour decaler vers le bas chaque subplot
vputbottom = .008:.005:.008+5*.005;

for nf = 1:length(vfig)
    nfs=num2str(nf);
    if length(nfs)==1
        nfss=['0',nfs];
    else
        nfss=nfs;
    end
    figure 
    set(gcf,'Visible','off','units','centimeters','position',[2 2 22.4 26])
    for ns=1:nbp
        numchan = vfig(nf)+ns-1;
        if numchan < lgc
            
            %------
            % Subplot des donnees MEG par canal
            subplot(nbp,4,(ns-1)*4+1:(ns-1)*4+3)
            plot(td,xall(numchan,:))
            xlim([td(1) td(end)])
            ylabel('Magnetic field (T)')
            xlabel('Time (s)')
            pos=get(gca,'position');
            set(gca,'position',[pos(1)-.05 pos(2)-vputbottom(ns) pos(3)+.05 pos(4)]);
            % Fonction put_figtext de la CREx_Toolbox permettant d'apposer
            % du texte sur la figure (coin superieur gauche ici, avec un
            % texte en blanc sur fond noir) - pour indiquer le canal MEG
            put_figtext(FTData.label{numchan},'nw',12,[1 1 1],[0 0 0]);
            % Titre si premiere ligne de subplot de la figure
            if ns==1
                title([typtit,' MEG data per channel'],'fontweight','bold')
            end
            
            %------
            % Subplot FFT totale en loglog
            subplot(nbp,4,(ns-1)*4+4)
            loglog(freq,allFFT(numchan,:));
            if sum(allFFT(numchan,:))>0
                axis tight; grid on;
            end
            xlabel('Frequency (Hz) [log]')
            ylabel('Amplitude (T) [log]')            
            pos=get(gca,'position');
            set(gca,'position',[pos(1)+.025 pos(2)-vputbottom(ns) pos(3:4)])
            if ns==1
                title('FFT spectrum','fontweight','bold')
            end
            % Remonter legerement le label de l'abscisse
            xlab=get(get(gca,'xlabel'),'position');
            set(get(gca,'xlabel'),'position',[xlab(1) xlab(2)+xlab(2)./2 xlab(3)])
        end
    end
    if numchan>lgc
        iend=lgc;
    else
        iend=numchan;
    end
    %------
    % Titre general de la figure contenant le chemin d'acces aux donnees 
    tit={[typtit,' data and associated FFT spectrum -  [',num2str(nf),']']
        ['datapath = ',rawdatapath]};
    annotation(gcf,'textbox','String',tit,'interpreter','none',...
        'FontSize',13,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.1 0.88 0.9 0.12]);

    namfig=['FFT_',datatyp,'Data_',nfss,'_chan_',num2str(vfig(nf)),'_to_',num2str(iend)];
    export_fig([pathsavfig,filesep,namfig,'.jpeg'],'-m1.5','-nocrop')
    close
end
disp(' ')
disp('Look at figures in ---')
disp(['----> ',pathsavfig])
disp(' ')
