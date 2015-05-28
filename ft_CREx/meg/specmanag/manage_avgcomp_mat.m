p0='F:\MEG_Project_Catsem\Catsem_Data';
p1=cell(1,2);
p1{1,1}= {p0};    p1{1,2}= 0;
p1{2,1}= {'S'};   p1{2,2}= 1; 
p1{3,1}= {'MEG'}; p1{3,2}= 0; 
p1{4,1}= {'Run*Visu'};     p1{4,2}= 1;
p1{5,1}= {'ICACompAvgT'};  p1{5,2}= 1; 
p1{6,1}= {'Visu_IrregLF'}; p1{6,2}= 1; 

alldir=make_pathlist(p1);

for i=1:length(alldir)
    dmat=dir([alldir{i},filesep,'avgComp*fcHP*.mat']);
    if ~isempty(dmat)
        movefile([alldir{i},filesep,dmat(1).name],fileparts(alldir{i}))
    end
end
        