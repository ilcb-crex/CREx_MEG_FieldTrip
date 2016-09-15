function meg_chancheck_fig(ftData, dirpath, datnam)
% Display the layout of MEG channels with an indication about the mean
% value of the Hilbert envelop of the data at each channel
% The value is normalized by the minimum enveloppe value found across all 
% the channels. 
% A value of 4 for channel A42 indicate that the mean amplitude of Hilbert
% envelop of the data recording by this channel is 4 order higher than the
% minimum mean value found in the whole data set.


if nargin<3
    datnam = 'MEGdata';
end
if nargin<2
    dirpath = pwd;
end

datalabel = ftData.label;

x = ftData.trial{1};
x = x - repmat(mean(x,2),1,length(x(1,:)));

ncapt = length(x(:,1));
xmh = zeros(ncapt,1);

for ic = 1:ncapt
    th_1 = hilbert(x(ic,:));               % Transformee de Hilbert
    th_2 = sqrt(x(ic,:).^2 + th_1.*conj(th_1));   % Enveloppe du signal
    xmh(ic) = mean(th_2);
end

col = colormap_blue2red;
val = linspace(min(xmh), max(xmh), length(col(:,1)));

cfg = [];
cfg.grad = ftData.grad;
cfg.layout ='4D248.lay';
lay = ft_prepare_layout(cfg);
lay.label = lay.label(1:end-2);
lay.pos = lay.pos(1:end-2,:);

x = lay.pos(:,1);
y = lay.pos(:,2);

% Channels that have been removed from analysis because of important noise...
if length(datalabel) < length(lay.label)
    igood=zeros(length(lay.label),1);
    for i=1:length(lay.label)
        if any(strcmp(datalabel,lay.label{i}))
            igood(i)=1;
        end
    end
    x = x(igood==1);
    y = y(igood==1);
    labok = lay.label(igood==1);
else
    labok = lay.label;
end
indsort = zeros(length(labok),1);
for ic = 1:length(labok)
    indsort(ic) = find(strcmp(datalabel,labok{ic})==1);
end
xmh = xmh(indsort);

figure
set(gcf,'units','centimeters','position',[3 1 24 24])    
set(gca,'position',[0 0 1 1])
ft_plot_lay(lay, 'point', true, 'pointsymbol','.','pointsize',1,'pointcolor',[1 1 1],...
    'box', false, 'label', true, 'labelsize',8,'mask', false, 'outline', true);

hold on

for ic = 1 : ncapt
    icol = find(val <= xmh(ic),1,'last');
    tx = text(x(ic), y(ic), labok{ic});
    if mean(col(icol,:)) > 0.85
        txcol = [0 0 0];
    else
        txcol = [1 1 1];
    end
    set(tx,'fontsize',9,'fontweight','bold','backgroundcolor',col(icol,:),'color',txcol)    
end
colormap(col);
cb = colorbar;

%pos = get(cb,'position');
set(cb,'position',[0.91 0.024 0.029 0.186])
yl = get(cb,'ylim');
set(cb,'ytick',[yl(1) (yl(2)-yl(1))/2 yl(2)])
set(cb,'yticklabel',{'1',num2str((max(xmh)-min(xmh))./(2*min(xmh)),'%3.1f'),...
    num2str(max(xmh)./min(xmh),'%3.1f')})  
set(get(cb,'ylabel'),'string','Normalized value')
tit={[dirpath,filesep,datnam];'Mean value of signal envelop (from hilbert transform)'};

annotation(gcf,'textbox','String',tit,'interpreter','none',...
    'FontSize',11,'fontname','AvantGarde',...
    'LineStyle','none','HorizontalAlignment','Left',...
    'FitBoxToText','off','Position',[0.0033 0.9427 0.9489 0.0525],...
    'backgroundcolor',[1 1 1]);

ppdir = make_dir(fullfile(dirpath, '_preproc'), 0);
figpath = [ppdir, filesep, 'ChanCheck_',datnam,'.jpg'];
export_fig(figpath,'-m1.5')
close

fprintf('\nFigure showing mean values saved as :\n, %s\n', figpath)

