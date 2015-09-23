% ________
% Parameters to adjust

% Paths for MEG datasets
p0 = 'F:\BaPa';
p1 = cell(1,2);
p1(1,:)= {{p0} , 0};
p1(2,:)= {{'CAC'}, 0}; 
p1(3,:)= {{'S'}, 1}; 

vdo = 1:6;  
% Vecteur des indices des donnees a traiter
% vsdo=[]; => sur toutes les donnees trouvees selon l'architecture p1
% vsdo = 1:10; => sur les 10 premieres donnees
% vsdo=17; : sur la 17eme donnees

% Choice of calculus to perform
doTopoERfig = 1;
doChanGroup = 0;
doClusterStat = 0;


%--- Type de donnees recherchees en fonction du pretraitement effectue
% Data preprocessing suffix
preproc = struct;
preproc.LPfc    = 40;   % Low-pass frequency
preproc.resfs   = 240;   % New sample frequency
preproc.crop    = [0 0]; % [t_prestim t_postim](stim : t=0s, t_prestim is negative)

framopt = struct;
framopt.slidwin = -0.08 : 0.01 : 0.8;
framopt.lgwin = 0.02;

% ________

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

alldp = make_pathlist(p1);

if isempty(vdo)
    vdo = 1:length(alldp);
end

strproc = preproc_suffix(preproc);

matname = ['avgTrials*',strproc,'*.mat'];

if doTopoERfig == 1
    for np = vdo 
        disp_progress(np, vdo);
        
        dpath = alldp{np};
        
        disp(' '), disp(['--> ', alldp{np}])
        fprintf('\n\n\t-------\nERF analysis : topographic plots\n\t-------\n')
       
        fprintf('\nSearch of : %s\nInside : %s\n\n', matname, dpath);
        
        [pavg, navg] = dirlate(dpath, matname);
         
        if ~isempty(pavg)                                
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
        else
            fprintf('\n\n--- Data not found ---\n\n')
        end
    end   
end    


if doChanGroup==1
    for ns = vdo 
        disp(' '), disp(['--> ',allsubjp{ns}])
        fprintf('\n\n\t-------\nERF analysis : ERF plots for groups of channels\n\t-------\n')
        fres = make_dir([allsubjp{ns},filesep,dosres]);
        [T,subj]=fileparts(allsubjp{ns});
        pmeg{1,1}=allsubjp{ns};
        megpth = make_pathlist(pmeg);
        
        ini=1;
        for nrun=1:length(megpth)            
            fprintf('\n\nProcess in :\n%s\n\n',megpth{nrun})
            disp(['Search of : avgTrials*',strproc,'*.mat'])
            [pavg,navgmat]=find_thismat(megpth{nrun},'avgTrials',strproc);
            if ~isempty(pavg)
                disp(['Find : ',navgmat])               
                avgCond = loadvar(pavg,'avgTrialsCond*');      
                avgmat=['avgTrials',strproc,'.mat'];
                fcond=fieldnames(avgCond);    
                % Figures of ERF per groups of channels (mean ERF and each
                % ERF per channels)
                fdos=make_dir([fres,filesep,'ChanGroupERFPlots',strproc],1);
                Sgrad=avgCond.(fcond{1}).grad;
                lab=avgCond.(fcond{1}).label;
                [Gindex,Gnam] = meg_chansplit(Sgrad,lab,fdos);
%                 for n=1:length(fcond)
%                     fdir=make_dir([fdos,filesep,fcond{n}]);
%                     specnam=[fcond{n},filesep,subj,filesep,avgmat];
%                     meg_chansplit_fig(avgCond.(fcond{n}),Gindex,Gnam,fdir,specnam)
%                 end
                
                % Figures of superposition of ERF per groups of channels 
                % (mean ERF and each ERF per channels) 
                % いい CatSem special いい
                % Three effects : (1) HF / LF and (2) Reg_HF / Irreg_HF (Audio) 
                % (3) Reg_LF / Irreg_LF (Visu)
                
                %effects={{'RegHF','RegLF'};{'RegHF','IrregHF'};{'RegLF','IrregLF'}};
               % effects={{'Morpho','Ortho','Seman','NonR'}}; %;{'Ortho','Pseudo'};{'Seman','Pseudo'};...
                    %{'NonR','Pseudo'}};
                effects={{'Ba2','Pa4'}};
                for e=1:length(effects)
                    tosup=effects{e};
                    data=cell(length(tosup),1);
                    namcond=cell(length(tosup),1);
                    okall=ones(length(tosup),1);
                    for s=1:length(tosup)
                        icond=strfind(fcond,tosup{s});
                        if isempty(cell2mat(icond))
                            okall(s)=0;
                        else
                            for n=1:length(fcond)
                                if ~isempty(icond{n})
                                    ia=n;
                                end
                            end
                            data{s}=avgCond.(fcond{ia});
                            namcond{s}=fcond{ia};
                        end
                    end
                    if all(okall)
                        fdir=make_dir([fdos,filesep,'Sup_',strjoin(namcond','_')]);
                        meg_chansplitsupcond_fig(data,namcond,Gindex,Gnam,fdir,[subj,filesep,avgmat])
                    end
                end
            else
                fprintf('\n\n--- Data not found ---\n\n')
            end
        end
    end   
end


