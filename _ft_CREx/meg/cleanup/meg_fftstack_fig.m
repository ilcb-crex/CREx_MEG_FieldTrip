function meg_fftstack_fig(ftData,freqst,allFFTstack,spsparam,datapath,pathsavfig,datatyp)
% Mise en forme tres specifique d'une figure represantant les spectres stackes ...
% La FFT stackee associee a chaque canal est tracee, et ce pour tous les
% canaux. Les noms des canaux dont les valeurs d'amplitude de leur spectre
% sont les plus extremes comparees aux autres spectres sont indiques sur le
% graphe : soit les 5 canaux avec les valeurs d'amplitude maximale de 
% l'amplitude du spectre dans la bande de frequence d'interet (0.1 à 100
% Hz). Il en est de meme pour les 5 canaux dont l'amplitude est minimale.

if nargin<7
    datatyp='raw';
    typtit='raw';
else
    switch datatyp
        case 'raw'
            typtit='raw';
        case 'filt'
            typtit='filtered';
        otherwise
            typtit=['preprocessed (',datatyp,')'];
    end
end
if nargin<6 || isempty(dir(pathsavfig))
    pathsavfig=pwd;
end
if nargin<5
    datapath=pwd;
end
if nargin<4
    stktit=[];
else
    stktit=['- [ nsp = ',num2str(spsparam.n),' ; lgsp = ',num2str(spsparam.dur),' s ; ti = ',...
    num2str(spsparam.dur*2),' s ]'];
end
if nargin<3 || isempty(allFFTstack) || sum(sum(allFFTstack))==0 
    dofig = 0;
else
    dofig = 1;
end

if dofig
    % Find extremum values (maybe bad channel - artifact) 
    % 2 versions of figures : one with stack spectrums obtained from
    % previous calculation, one with a smoothed version of stacked spectrum
    % (5-span points smoothing)

    fz = find(allFFTstack(:,1)==0);
    if ~isempty(fz)
        disp('!! No FFT values for channel(s) :')
        disp(ftData.label(fz))
        indz=ones(length(allFFTstack(:,1)),1);
        indz(fz)=0;
        ftData.label=ftData.label(indz==1);
        allFFTstack = allFFTstack(indz==1,:);
        disp(' ')    
    end
    smo=zeros(size(allFFTstack));
    for nc=1:length(allFFTstack(:,1))
        smo(nc,:)=smooth(allFFTstack(nc,:), 5);
    end

    toplot={allFFTstack,smo};
    gtit = {['Stacked spectrum of MEG ',typtit,' data - ',num2str(length(ftData.label)),' channels ',stktit];...
        ['datapath : ',datapath]};
    adtit = ' (channels with extremum amplitude are labelled)';
    
    tit=cell(2,1);
    tit{1}={gtit{1}; [gtit{2},adtit]};      
    tit{2}={['[Smooth span=5] ',gtit{1}]; [gtit{2},adtit]};
    
    savt={'','smo5'};
    
    % Options for labelling spectrum with extremum values of amplitude 
    nmax=3; % Number of maximum (and minimum) values of amplitude from different channel to find on the spectrum
    fdet={1 35 120};            % Frequencies to detect extrema (low and high)
    intwin={[.8 4] [5 40] [120 200]};  % Frequency windows to labelled extrema   
   
    for nfig=1:2   
        figure 
        set(gcf,'Visible','off','units','centimeters','position',[2 2 24 18])
        loglog(freqst,toplot{nfig})
        xlabel('Frequency (Hz)','fontsize',14)
        ylabel('Amplitude (T)','fontsize',14)
        set(gca,'fontsize',14)
        title(tit{nfig},'interpreter','none','fontsize',12,'fontname','AvantGarde');
        put_labarrow(freqst,toplot{nfig},ftData.label,nmax,fdet,intwin)
        export_fig([pathsavfig,filesep,'FFTstack_',savt{nfig},datatyp,'Data_allchan','.jpeg'],'-m1.5','-nocrop')
        close
    end
    
    % Make a .fig figure with display name for each curve to retrieve name
    % of specific channel if not labelled by our procedure using arrow
    % annotations
    % Smooth version only
    nfig=2;
    
    makefftstack_fig(freqst, smo, ftData.label)
    tit = {['[Smooth span=5] ',gtit{1}]; gtit{2}};
    title(tit,'interpreter','none','fontsize',12,'fontname','AvantGarde');
    saveas(gcf,[pathsavfig,filesep,'FFTstack_dispnam_',savt{nfig},datatyp,'Data_allchan.fig'])
    close


    % Make a lighter .fig to "easily navigate inside" (- in frenchglish)
    deltaf = .5; % One sample every 0.5 Hz
    if freqst(2)-freqst(1) < deltaf/4 % Check if downsampling is necessary
        [freqrs, allFFTrs] = downsampl_allFFT(freqst,smo,deltaf);
        
        makefftstack_fig(freqrs, allFFTrs, ftData.label)
        tit = {['[Smooth span=5 & Downsampling] ',gtit{1}]; gtit{2}};        
        title(tit,'interpreter','none','fontsize',12,'fontname','AvantGarde');
        saveas(gcf,[pathsavfig,filesep,'FFTstack_dispnam_DOWNsamp_',savt{2},datatyp,'Data_allchan.fig'])
        close
    end
    disp(' ')
    disp('Figure of stacked spectrum saved in ---')
    disp(['----> ',pathsavfig])
    disp(' ')
end
function put_labarrow(freqst,allFFTst,labc,nmax,fdet,intwin)   
    col=get(gca,'colororder');
    allcol=repmat(col,36,1);
    for g=1:length(intwin) % for the different groups of frequency windows

        allfft=allFFTst(:,find(freqst>=fdet{g},1,'first'));


        ibad=zeros(nmax.*2,1); 
        % ibad : Index of the nmax channels with maximum values 
        % of fftint and the nmin ones with minimum values

        % Find channels with maximum values of amplitude of FFT
        % spectrum
        [~,indsort]=sort(allfft);
        % The top-5 of index of channel with maximum value of amplitude
        % spectrum
        ibad(1:nmax)=indsort(end-(nmax-1):end);
        % Find channels with the lowest values of amplitude
        % The top-5
        ibad(nmax+1:nmax*2)=indsort(1:nmax); 
        intf=intwin{g};

        xsp=logspace(log10(intf(1)),log10(intf(2)),nmax)';
        xspace=[xsp;xsp];

        xarrow=zeros(length(xspace),1);
        yarrow=zeros(length(xspace),1);
        for isp=1:length(xspace)
            extfft=allFFTst(ibad(isp),:);
            ind=find(freqst>=xspace(isp),1,'first');
            yarrow(isp)=extfft(ind);
            xarrow(isp)=freqst(ind);
        end

        xaxlim = xlim;
        yaxlim = ylim;
        Dxl = abs(log10(xaxlim(2))-log10(xaxlim(1)));
        Dyl = abs(log10(yaxlim(2))-log10(yaxlim(1)));
        posa = get(gca,'position');
        normxar = posa(3).*(abs(log10(xarrow)-log10(xaxlim(1))))./Dxl+posa(1);  
        normyar = posa(4).*(abs(log10(yarrow)-log10(yaxlim(1))))./Dyl+posa(2);  
        lab = labc(ibad);
        thecol = allcol(ibad,:);
        [vxdecal,vydecal] = deal(zeros(nmax.*2,1));
        vxdecal(1:nmax) = .01;
        vxdecal(nmax+1:end) = -.01;
        vydecal(1:nmax) = .08;
        vydecal(nmax+1:end) = -.08;

        for a=1:nmax*2
            if g==1 || ( g>1 && sum(strcmp(labdone,lab{a}))==0 )
                annotation('textarrow',[normxar(a)+vxdecal(a) normxar(a)],...
                    [normyar(a)+vydecal(a) normyar(a)],'string',lab{a},...
                    'fontsize',10,'FontWeight','bold','TextBackgroundColor','none',...
                    'TextColor',thecol(a,:),'textedgecolor','none',...
                    'headstyle','vback1','headwidth',6,'headlength',6,'color',thecol(a,:))
            end
        end
        if g==1
            labdone=lab;
        else
            labdone=[labdone;lab]; %#ok
        end
    end

function makefftstack_fig(x,y,labels)
        
 	figure
    set(gcf,'visible','off','units','centimeters','position',[2 2 24 18])
    hold on
    col=get(gca,'colororder');
    allcol=repmat(col,36,1);
    for c=1:length(y(:,1))
        p=plot(x,y(c,:),'color',allcol(c,:));
        set(p,'displayname',labels{c})
    end
    set(gca,'yscale','log','xscale','log')
    xlabel('Frequency (Hz)','fontsize',14)
    ylabel('Amplitude (T)','fontsize',14)
    set(gca,'fontsize',14)
    
function [freqrs, allFFTrs] = downsampl_allFFT(freq, allFFT, deltaf)

    % Calculate sampling rate of original data
    dfi = (freq(end) - freq(1)) /(length(freq)-1);

    % Check if downsampling
    if deltaf < dfi  % Upsampling and not downsampling - empty data are returned
        disp(' ')
        disp('Downsampling impossible with the new smpling rate : ')
        disp([num2str(deltaf),' Hz'])
        freqrs = [];
        allFFTrs = [];
    else
        fact = round(deltaf / dfi);
        allFFTrsi = resample(allFFT(1,:),1,fact);
        allFFTrs = zeros(length(allFFT(:,1)),length(allFFTrsi));
        allFFTrs(1,:) = allFFTrsi;
        for i = 2:length(allFFT(:,1))
            allFFTrs(i,:) = resample(allFFT(i,:),1,fact);
        end
        freqrs = linspace(freq(1),freq(end),length(allFFTrsi));
    end
