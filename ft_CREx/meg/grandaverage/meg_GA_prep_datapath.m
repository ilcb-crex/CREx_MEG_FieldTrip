function  [datpaths, subjlist] = meg_GA_prep_datapath(subjpaths, datarch, datname)
% Search for data name datname inside each subject's directory (subjpaths),
% and according to the searching architecture directory datarch.

datpaths = cell(1,1);
subjlist = cell(1,1);
j = 1;
for ns = 1 : length(subjpaths)
    
    psm0 = subjpaths{ns};
    fprintf('\n\n--> %s\nSearch of mat-file\n', psm0);
    if ~isempty(datarch)
        pdat = cell(1+length(datarch(:,1)),2);
        pdat(1,:)= {{psm0} , 0};
        pdat(2:end,:)= datarch; 
        dpaths = make_pathlist(pdat);
    else
        dpaths = {psm0};
    end
    
    % Subject's name
    [T, subjnam] = fileparts(subjpaths{ns}); %#ok compat M7.5
    
    for np = 1 : length(dpaths)     
        
        fprintf('\nSearch of : %s\nInside : %s\n\n', datname, dpaths{np});
        
        [pmat, nmat] = dirlate(dpaths{np}, datname);
      
        if ~isempty(pmat)
            disp(['Find : ',nmat]) 
            datpaths{j,1} = pmat ;
            subjlist{j,1} = subjnam ;
            j = j+1;
        end
    end
end