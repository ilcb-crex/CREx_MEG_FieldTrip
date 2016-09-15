function meg_trials_fig(trials, pathmat, namevent, fdos)
% TODO : histogramme basé sur les rapports des valeurs moyennes des
% enveloppes de Hb
% SEPARER en sous fonction la creation de figure
% Change to an option structure as input argument
if nargin<3
    namevent='Event';
end
if nargin<4
    sav = 0;
    fvis = 'on';
else
    sav = 1;
    fvis = 'off';
end

warning off MATLAB:tex % M7.5 Disable unjustified warning messages

namevt = ['[ ',namevent,' ]'];
namevt(namevt=='_') = '-';

t_trials = trials.time;
x_trials = trials.trial;
chanlabel = trials.label;
if isfield(trials,'trialinfo')
	trigval = trials.trialinfo;
else
    trigval = [];
end

% Check data type
% MEG 4D
if strcmp(chanlabel{1}(1), 'A')
    uamp = 'T';
else
    % Suppose to be SEEG or EEG
    uamp = 'uV';   
end
    

cpmap = colormap('jet'); % Will open a new figure
close;

for nt = 1 : length(x_trials)
    nums = num2str(nt);
    if length(nums)==1
        trialnum = ['0',nums];
    else
        trialnum = nums;
    end
    t = t_trials{nt};
    x = x_trials{nt};
    
    plot_trial_allchan(t, x, chanlabel, cpmap, fvis)
    
    maxabs = max(abs(x'))';
    mina = min(maxabs);
    maxa = max(maxabs);

    % inc = (maxa-mina)/(length(cpmap(:,1))-1);
    % dec = mina : inc : maxa;

    h = colorbar('south');
    % Default colorbar ticks : 0 to 1 with 0.1 space
    % Reduce to 3 values : mina, maxa and between
    set(h, 'Ticks', 0:0.5:1) % M2015 : set(h, 'Ticks', 0:0.5:1)
    inc = (maxa - mina) / (length(h.Ticks)-1);
    dec = mina : inc : maxa;
    stick = num2str(dec, 2);
    stick = strsplit(stick, ' ');
    set(h,'position',[0.7284 0.0257 0.1735 0.0151],...   
        'xaxisLocation','bottom','xticklabel',stick)
    set(get(h,'title'),'String',...
        ['Max. abs. value of trial (', uamp,')'],'fontsize',12)
    if ~isempty(trigval)
    	trigs = [' - Trigger value [ ',num2str(trigval(nt)),' ] - ']; 
    else
        trigs = ' - ';
    end
    titfig = {[namevt,trigs,'Trial [ ',trialnum,...
         ' ] - Extracted from dataset : '];pathmat};
    idt = title(titfig,'interpreter','none','fontsize',12);
    post = get(idt,'position');
    set(idt,'position',[post(1) 32.5 post(3)])

    namfig = ['TrialPlot_',namevent,'_',trialnum];
    
    if sav==1
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
        close
    end
    
    
    % Check maximum amplitudes by histogramm with 20 bars between min and
    % max
    da = (maxa - mina)/20;
    v = mina-da : da : maxa+da;
    count = histc(maxabs, v);
        
    % Figure de l'histogramme des valeurs absolues maximum par
    % canal et de la superposition des donnees des canaux
    figure, set(gcf,'visible', fvis,'units','centimeters','position',[2 10 21 10.5])

    % -- Histogramm of maximum absolute amplitude per channel
    subplot(121)
    set(gca,'units','centimeters','position',[2.7 1.2 7 6.8]);
    h = bar(v,count); 
    set(h,'barwidth',1,'facecolor',[0 .5 .4]);
    title({'Histogram of maximum absolute','amplitude values per channel'})
    xlabel(['Maximum absolute value (', uamp,')'])
    ylabel('Number of channels')
    verif_label

    % -- Superimposition of trials toward all channels
    subplot(122)
    set(gca,'units','centimeters','position',[12 1.2 7 6.8]);
    plot(t, x) 
    hold on, 
    plot([0 0],ylim,'r:')
    xlim([t(1) t(end)])
    xlabel('Time (s)   [ t = 0s  : TRIGGER ]')
    ylabel(['Amplitude (',uamp,')'])
    
    title({'Superimposition of trial per channel';' '})
    annotation(gcf,'textbox','String',titfig,'interpreter','none',...
        'FontSize',11,'fontname','AvantGarde',...
        'LineStyle','none','HorizontalAlignment','center',...
        'FitBoxToText','off','Position',[0.05 .88 0.9 0.12]);
    verif_label
    
    namfig = ['HistSupPlot_',namevent,'_',trialnum];
    if sav==1
        export_fig([fdos,filesep,namfig,'.jpeg'],'-m1.5')
        close
    end
end
warning on MATLAB:tex

function plot_trial_allchan(ttrial, xtrial, chanlabel, colmap, fvis)

nchan = length(chanlabel);
nlig = ceil(sqrt(nchan));
Mtranst = repmat((0:nlig-1)', 1, nlig);
Mtransx = repmat((nlig*2-1 : -2 : 1), nlig, 1);

t = ttrial;
x = xtrial;

tt = t-t(1);
tt = tt.*0.8./(tt(end));

maxabs = max(abs(x'))';
mina = min(maxabs);
maxa = max(maxabs);

inc = (maxa-mina)/(length(colmap(:,1))-1);
dec = mina : inc : maxa;

% Figure des donnees par channel pour chaque trial
figure
set(gcf,'visible', fvis,'units','centimeters','position',[8 1 30 24])
set(gca,'position',[.05 .05 .88 .88])
xlim([0 nlig]), ylim([0 nlig*2])
axis off
hold on
for sub = 1 : nchan
    ts = tt + Mtranst(sub);
    xs = x(sub,:).*0.6./maxabs(sub) + Mtransx(sub);
    col = colmap(find(dec >= maxabs(sub),1,'first'),:);
    plot(ts, xs, 'color', col)
    text(Mtranst(sub), Mtransx(sub)+0.9, chanlabel{sub})
end
colormap('jet'); % Will open a new figure