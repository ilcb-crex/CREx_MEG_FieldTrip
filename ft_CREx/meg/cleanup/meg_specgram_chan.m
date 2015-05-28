function meg_specgram_chan(ftData, spcopt) %strchan, Dt, pourcovl, vxlim, vylim)
% Calculate spectrogram of one channel stored inside FieldTrip structure 
% data : ftData
%
% spcopt can contain these arguments :
%
%   spcopt.Dt : temporal resolution (length of the time-frequency bin)
%               [default : 2 s]
%   spcopt.pourcovl : percent of overlap for the sliding window (from 0 to 100)
%               [default : 0%]
%   spcopt.strchan : name of the channel to consider (string, ex. : 'A122')
%               [default : the 1st channel ftData.trial{1}(1,:)]
%   spcopt.vxlim : X-limits (time) for the detail figure version 
%               [default : no zoom ]
%   spcopt.vylim : Y-limits (frequency) for detail figure version
%               [default : no zoom ]
%   spcopt.savpath : path where figure and results will be saved 
%               [default : pwd]
%   spcopt.datapath : data file path that will appear in the title 
%               [default : '']
%   spcopt.subjnam : name of the subject added to figure's title & filename 
%               [default : nothing added]
%
% The amplitudes of the spectrogram bins are expressed in dB, after 
% normalisation. The mean absolute value of amplitude calculated on the 
% whole dataset (all channels) have been use as the reference amplitude 
% for the normalisation.
%   Tref = mean(mean(abs(ftData.trial{1}))); 
%   Isp_dB = 20*log10(abs(Isp_T)./Tref);  
% 
%________
% Check for input parameters
%

% Temporal resolution : Dt
if ~isfield(spcopt,'Dt') || isempty(spcopt.Dt) || spcopt.Dt==0
    Dt = 2; % Default length of temporal bin unity (resolution)
else
    Dt = spcopt.Dt;
end

% Percent of overlap for the sliding windows
if ~isfield(spcopt,'pourcovl') || isempty(spcopt.pourcovl)
    pourcovl = 0;  % Default : no overlap
else
    if spcopt.pourcovl >0 && spcopt.pourcovl < 1 % Probably not in percent
        pourcovl = spcopt.pourcovl*100;
    else
        pourcovl = spcopt.pourcovl; 
    end
end

% Channel to consider
if ~isfield(spcopt,'strchan') || isempty(spcopt.strchan) 
    idchan = 1;
else
    idchan = check_chan(ftData, spcopt.strchan);
end   


% Data file path to add to title of the figure
if ~isfield(spcopt,'datapath') || isempty(spcopt.datapath) 
    tit=cell(1,1);
    datnam = '';
else
    tit = cell(2,1);
    tit{2}=['Data path : ',spcopt.datapath];
    [T,nmat] = fileparts(spcopt.datapath); %#ok
    datnam = ['_',nmat];
end  

% Subject name to add to title of the figure and figure file name
if ~isfield(spcopt,'subjnam') || isempty(spcopt.subjnam) 
    subjnamtit = '';
    subjnamsav = '';
else
    subjnamtit = ['[ ',spcopt.subjnam,' ] - '];
    subjnamsav = [spcopt.subjnam,'_'];
end  

% Directory path where to save results
if ~isfield(spcopt,'savpath') || isempty(spcopt.savpath) 
    savpath = pwd;
else
    if exist(spcopt.savpath,'dir')==0 
        if exist(fileparts(spcopt.savpath),'dir')==7
            savpath = make_dir(spcopt.savpath);
        else
            savpath = pwd;
        end
    else
        savpath = spcopt.savpath;
    end
end 

% X-limits (time)
if isfield(spcopt,'vxlim')
    [vxlim, zoomx] = check_vzoom(spcopt.vxlim);
else
    zoomx = false;
end

% Y-limits (frequency)
if isfield(spcopt,'vylim')
    [vylim, zoomy] = check_vzoom(spcopt.vylim);
else
    zoomy = false;
end     


%________
% Go !
%
xd = ftData.trial{1}(idchan,:);
td = ftData.time{1};
if isfield(ftData,'fsample')
    fe = ftData.fsample;
else
    fe = (length(td)-1)/(max(td)-min(td));
end

% Frequency resolution (height of one bin)
Df = 1/Dt;

% Overlap 
pov = pourcovl/100;
    
nwind = floor(fe/Df);

% Sliding window definition : Hanning 
wsp = hanning(nwind);
noverlap = floor(nwind*pov);

% Spectrogram computation using specgram Matlab function
[Isp, fsp, tsp] = specgram(xd,nwind,fe,wsp,noverlap); 

% Conversion in Tesla
npoint = 2^nextpow2(length(xd));         		
IspT = abs(Isp)*2/min(npoint,length(xd));
% In dB
Tref = mean(mean(abs(ftData.trial{1})));
IspdB = 20*log10(abs(IspT)./Tref);  


tit{1}=[subjnamtit,'Spectrogram - Channel ',ftData.label{idchan},...
    ' - [ Dt = ',num2str(Dt),' s ; Overlap = ',num2str(pourcovl),'% ]'];

% Figure of subplot
specgram_subplot_fig(td,xd,tsp,fsp,IspdB,tit)    

savnam = name_save(['specg_',subjnamsav,ftData.label{idchan},datnam,'_',...
    num2str(Dt),'s_ovl', num2str(pourcovl)]);
export_fig(fullfile(savpath,[savnam,'.jpg']),'-m1.5','-zbuffer') % painters ou opengl
close
if zoomx || zoomy
    zz='zoom';
    
    if zoomx
        xd = xd(td>=vxlim(1) & td<=vxlim(2));
        IspdB = IspdB(:,tsp>=vxlim(1) & tsp<=vxlim(2));
        tsp = tsp(tsp>=vxlim(1) & tsp<=vxlim(2));
        td = td(td>=vxlim(1) & td<=vxlim(2));
        zz=[zz,'_',num2str(vxlim(1)),'to',num2str(vxlim(2)),'s']; 
    end
    if zoomy
        IspdB = IspdB(fsp>=vylim(1) & fsp<=vylim(2),:);
        fsp = fsp(fsp>=vylim(1) & fsp<=vylim(2),:);
        zz=[zz,'_',num2str(vylim(1)),'to',num2str(vylim(2)),'Hz'];
    end
    
    % Figure of subplot
    specgram_subplot_fig(td,xd,tsp,fsp,IspdB,tit)  
    
    savnam = name_save([savnam,'_',zz]);
    export_fig(fullfile(savpath,[savnam,'.jpg']),'-m1.5','-zbuffer') 
    close 
end


disp(' '), disp('-----')
disp('Figures specg_*.jpg saved here :')
disp(savpath)
disp('-----'), disp(' ')

function specgram_subplot_fig(td,xd,tsp,fsp,IspdB,tit)
    % Subplot Signal + Spcg 
    figure
    set(gcf,'units','centimeters','position',[2 10 25 15])

    subplot(211), plot(td, xd)
    axis tight
    xlabel('Time (s)','fontsize',13)
    ylabel('Amplitude (T)','fontsize',13)
    set(gca,'fontsize',13)
    put_figtext('a) Time domain','nw',11,[1 1 1],[0 0 0]);

    subplot(212), imagesc(tsp,fsp,IspdB);
    set(gca,'ydir','normal')
    axis tight;
    colormap(jet);
    pos = get(gca,'position');
    
    hc = colorbar('location','eastoutside');
    set(hc,'position',[pos(1)+pos(3)+.015 pos(2) .015 pos(4)])
    
    xlabel('Time (s)','fontsize',13)
    ylabel('Frequency (Hz)','fontsize',13)
    set(gca,'fontsize',13)
    put_figtext('b) Spectrogram','nw',11,[1 1 1],[0 0 0]);

    set(get(hc,'ylabel'),'string','Normalized value (dB)','fontsize',12)
    set(hc,'fontsize',10)
    
    subplot(211)
    pos = get(gca,'position');
    set(gca,'position',[pos(1) pos(2)-.04 pos(3:4)])
    verif_label

    annotation(gcf,'textbox','String',tit,'interpreter','none',...
        'FontSize',12,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','Center',...
        'FitBoxToText','off','Position',[0.0033 0.9030 0.9935 0.0922]);

function [vzoom, zok] = check_vzoom(vzoom)

if isempty(vzoom) || length(vzoom)~=2 || sum(vzoom)==0 ...
        || diff(vzoom)==0
    zok = false;
else
    if vzoom(2)< vzoom(1)
        vzoom = [vzoom(2) vzoom(1)];
    end
    zok = true;
end

function idchan = check_chan(ftData, strchan)

if sum(strcmp(ftData.label,strchan))==0 % Pas de correspondance trouvee
    if ~isempty(strfind('1234567890',strchan(1)))
        strchan = ['A',strchan];
        if sum(strcmp(ftData.label,strchan))==1
            idchan = find(strcmp(ftData.label,strchan) == 1);
        else
            idchan = 1;
        end
    else
        idchan = 1;
    end
else
    idchan = find(strcmp(ftData.label,strchan) == 1);
end
