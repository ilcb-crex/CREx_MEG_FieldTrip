function disp_progress(curind, allind)
% Return string of current progression 
% Exemple : calculation '2/20'
% curind : current index of data being processed
% allind : vector of indices to be process or total number of steps

if length(allind)==1
    ntot = allind;
    pstr = [num2str(curind),'/', num2str(ntot)];
else
    ntot = length(allind);
    icur = find(allind==curind, 1 , 'first');
    if ~isempty(icur)
        pstr = [num2str(icur),'/', num2str(ntot)];
    else
        pstr = [num2str(curind),'/', num2str(ntot)];
    end
end

fprintf('\n-------------------------[%s]-------------------------\n', pstr);
