function badcomp = meg_rmcomp_input(path)
fprintf('\n\t-------\nInput bad ICA component(s)\n\t-------\n')
if nargin == 1
    fprintf('\nProcessing of data in :\n%s\n\n',path);
end

rm = 0;
while rm~=1 && rm~=2
    disp('   ----------'), disp(' ')
    disp('Remove component(s) from dataset -> 1')
    disp('          or keep all components -> 2')
    rm = input('                                 -> ');
end
if rm==1
    rec = 2;
    while rec==2
        disp(' ')
        disp('Enter bad component(s) to remove from dataset : ')
        disp(' ')
        goon =1;
        ndel=1;
        badcomp=zeros(1,500);
        while goon
            badcomp(ndel)=input(['Bad component n°',num2str(ndel),' : ']);
            ndel=ndel+1;
            disp(' ')
            disp('Enter a new bad component (1)')
            goon = input('           or stop me now (0) : ');
            disp(' ')
            if goon~=1 && goon ~=0
                while goon~=1 && goon~=0
                    disp('!!! Not correct answer')
                    disp(' ')
                    disp('Enter a new bad component (1)')
                    goon = input('           or stop me now (0) : ');
                    disp(' ')      
                end
            end
        end
        badcomp=badcomp(1:ndel-1);
        fprintf('\n\t-------\nSelection of ICA components to remove :\n\t-------\n')
        disp(['     ',num2str(badcomp)]), disp(' ')
        disp('Confirm it           -> 1')
        disp('Ooops made a new one -> 2')
        rec = input('                     -> ');
    end
else
    badcomp=[];
end