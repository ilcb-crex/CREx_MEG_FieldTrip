function meg_filt_fig(filtData, rawData, filtopt, datapath, chan)
% Figures of subplots showing filtered data vs raw data 
% - filtData : fiedtrip data structure of filtered data
% - rawData : fieldtrip data structure of raw data
% - filtopt : initial parameters structure for filtering
% - datapath : path of the data directory
% - chan : label of the channel to plot (one figure per channel)
%____
%-CREx 20140520 
%-CREx-BLRI-AMU project: https://github.com/blri/CREx_MEG/fieldtrip_process

dirsav = make_dir(fullfile(datapath, '_preproc'), 0);

%-- Define labels specifying kind of filter
[figstr, savstr] = filt_str(filtopt);

%-- Make figure for each channel
for nc = 1 : length(chan)
    % Get time and amplitude vectors 
    [tfilt, xfilt] = extract_data(filtData, chan{nc});    
    [traw, xraw] = extract_data(rawData, chan{nc});
    
    % Title string
    stit = {['Exemple of filtering result : ', chan{nc}]; datapath};
    
    figure
    set(gcf,'units','centimeter','position',[1 1 27 17])
    
    %-- Filtered data subplot
    subplot(211)
    plot(tfilt, xfilt)
    xlim([tfilt(1) tfilt(end)])
    % Add labels
    filt_labels
    
    % Add title
    title(stit, 'fontsize',14,'interpreter','none')
    
    %-- Raw data subplot
    subplot(212)
    plot(traw, xraw)
    xlim([traw(1) traw(end)])
    filt_labels
    % Format labels if needed (add x10^n indication in label string)
    format_label
    % Add indication on the figure
    put_figtext('B) Original data','nw',12,[1 1 1],[0 0 0]);
    % Move the subplot down
    pos = get(gca,'position');
    set(gca,'position',[pos(1) pos(2)+0.05 pos(3:4)])
    
    % Add the indocation on the first subplot
    subplot(211)
    put_figtext(['A) Filtered by ',figstr],'nw',12,[1 1 1],[0 0 0]);
    format_label    
    
    % Save the figure
    % Name is based on the frequency cut-off parameters and the channel
    matnam = name_save(['filtData_',savstr,'_',chan{nc}]);    
    export_fig([dirsav, filesep, matnam, '.jpeg'], '-m1.5')
    close
end

% Get filtering indications as string to add to the figure (figsav) as well
% as suffix to add to the jpeg file that is saved (savstr)
function [figstr, savstr] = filt_str(opt)
% Filter characteristics according to options structure
% filter type ('bp','lp' or 'hp')
ftyp = opt.type;
% Frequency cut-off in Hz
fcut = opt.fc;
% 
fstri = ['fc',upper(ftyp),'_'];
if numel(fcut) == 1
    savstr = [fstri,num2str(fcut),'Hz'];
    if strcmpi(ftyp,'hp')
        figstr = ['High-Pass : ',num2str(fcut),' Hz'];
    else
        figstr = ['Low-Pass : ',num2str(fcut),' Hz'];
    end
else
    savstr = [fstri,num2str(fcut(1)),'_',num2str(fcut(2)),'Hz'];
    figstr = ['Band-Pass : [',num2str(fcut(1)),' - ',num2str(fcut(2)),' ] Hz'];
end

% Add axes label and change fontsize
function filt_labels
xlabel('Time (s)','fontsize',14)
ylabel('Magnetic field (T)','fontsize',14)
set(gca,'fontsize',14)

% Extract time and amplitude vector of the request channel (chanstr)
function [tdat, xdat] = extract_data(ftdat, chanstr)
tdat = ftdat.time{1};
xdat = ftdat.trial{1}(strcmp(ftdat.label, chanstr)==1, :);

