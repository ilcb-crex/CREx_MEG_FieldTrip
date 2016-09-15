function Sevent = meg_read_events(dirdat, dirlist)

if nargin < 2 || isempty(dirlist)
    savtxt = 0;
    savpath = [];
else
    savtxt = 1;
end

fprintf('\nProcessing of data in :\n%s\n\n', dirdat);
datapath = filepath4d(dirdat);
if ~isempty(datapath)
    if savtxt == 1
        [p1,d1] = fileparts(dirdat);
        [p2,d2] = fileparts(p1);
        [T,d3] = fileparts(p2); %#ok Compat M7.5
        savpath = fullfile(dirlist,['All_events_list_',d3,'_',d2,'_',d1,'.txt']); 
    end
    cfg_rawData = meg_disp_event(datapath, savpath);
    save([dirdat , filesep, 'cfg_rawData'],'cfg_rawData')
    cfg_event = cfg_rawData.event;
    save([dirdat, filesep, 'cfg_event'],'cfg_event')
    Sevent = cfg_event;
else
    disp('MEG 4D dataset not found in directory :')
    disp(dirdat)
end