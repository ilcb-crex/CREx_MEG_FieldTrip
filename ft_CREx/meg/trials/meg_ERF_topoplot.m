function meg_ERF_topoplot(dpath, datopt, framopt)

disp(' '), disp(['--> ', dpath])
fprintf('\n\n\t-------\nERF analysis : topographic plots\n\t-------\n')

[pavg, navg] = find_datamat(dpath, datopt);

if isempty(pavg)   
    return;
end

strproc = preproc_suffix(datopt.preproc);
disp(['Using : ', navg]) 
avgCond = loadvar(pavg,'avgTrialsCond*'); 

pavgp = [fileparts(pavg), filesep, 'avgTrials', strproc,'.mat'];

fcond = fieldnames(avgCond); 

fdos = make_dir([dpath,filesep,'TopoERF', strproc],1);
for n = 1 : length(fcond) 

    figopt = struct;
    figopt.fname = fcond{n};
    figopt.matpath = pavgp;

    % Make topographic plots (only topo) first
    topodos = make_dir([fdos,filesep,'TopoAvg'],0);
    figopt.savpath = topodos;
    % Kepp default sliding windows parameter (-0.100 : 0.050 :
    % 0.900 s) - ensure good proportion of the subplots)
    meg_topoER_fig(avgCond.(fcond{n}), figopt)

    % Make frame plots (topo + signal)
    framdos = make_dir([fdos,filesep,'Frames_', fcond{n}],0);
    figopt.savpath = framdos;
    figopt.slidwin = framopt.slidwin;
    figopt.lgwin = framopt.lgwin;
    meg_topoER_frame(avgCond.(fcond{n}), figopt)
end 

            % Differences
% %                 for i=1:length(fcond)-1
% %                     condnam1=fcond{i};
% %                     for j=i+1:length(fcond)
% %                         condnam2=fcond{j};
% %                         combnam=[condnam1,' - ',condnam2];
% %                         % Diff avg
% %                         dos=make_dir([fdos,filesep,'ParamAvgDiff'],0);
% %                         Savgdiff=avgCond.(condnam1);
% %                         Savgdiff.avg=avgCond.(condnam1).avg-avgCond.(condnam2).avg;
% %                         meg_topoER_fig(Savgdiff,['Diff ',combnam],dos,pavg)
% %                     end
% %                 end 
    