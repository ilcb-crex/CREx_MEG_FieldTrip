function strproc = preproc_suffix(preproc)

strproc='';
%---- FILTER
if isfield(preproc,'LPfc') && preproc.LPfc>0
    fcs=num2str(preproc.LPfc);
    fcs(fcs=='.')='p';
    strproc=[strproc,'_LP',fcs,'Hz'];
end
%---- RESAMPLE
if isfield(preproc,'resfs') && preproc.resfs>0
    fss=num2str(preproc.resfs);
    fss(fss=='.')='p';
    strproc=[strproc,'_Res',fss,'Hz'];
end
%---- CROP WINDOW
if isfield(preproc,'crop') && length(preproc.crop)==2 && preproc.crop(1)~=0
    win=preproc.crop;
    winst=cell(1,2);
    winst{1}=['m',num2str(abs(win(1)))];
    winst{1}(winst{1}=='.')='p';
    winst{2}=num2str(win(2));
    winst{2}(winst{2}=='.')='p';
    strproc=[strproc,'_Crop',winst{1},'to',winst{2},'s'];
end       