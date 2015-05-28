p0='C:\Users\zielinski\Desktop\Catsem_Figures';
p1=cell(1,2);
p1{1,1}= {p0};    p1{1,2}= 0;
p1{2,1}= {'S0','S1'};   p1{2,2}= 1; 
p1{3,1}= {'BeamfLocMapZ_'};   p1{3,2}= 1; 
p1{4,1}= {'Frames_Audio'};   p1{4,2}= 1; 

load_CREx_pref
ft_defaults % Add FieldTrip subdirectory

typ={'FixColMap_','RelColMap_'};
dos={'Absolute_Scale','Relative_Scale'};

alldir=make_pathlist(p1);

for i=1:length(alldir)
    for j=1:length(typ)
        isjpg=dir([alldir{i},filesep,typ{j},'*.jpg']);
        if ~isempty(isjpg)
            djpg=make_dir([alldir{i},filesep,dos{j}],0);
            movefile([alldir{i},filesep,typ{j},'*.jpg'],djpg)
        end
    end
    dtopo=dir([alldir{i},filesep,'Topo*.jpg']);
    if ~isempty(dtopo)
        delete([alldir{i},filesep,'Topo*.jpg'])
    end
end
        