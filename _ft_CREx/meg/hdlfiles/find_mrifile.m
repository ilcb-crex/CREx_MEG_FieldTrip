function [pmri,nmri] = find_mrifile(path)

formimg = {'mri','nii'};
pmri = [];
nmri = [];
for ni = 1:length(formimg)
    isfile = dir([path,filesep,'*.',formimg{ni}]);
    if ~isempty(isfile)
        pmri = [path,filesep,isfile(1).name];
        nmri = isfile(1).name;
        break
    end
end
if isempty(pmri)
    disp('MRI file not found in directory')
    disp(path)
    disp(' ')
    disp('Check for file format testing in this code :')
    disp('find_mri.m')
end