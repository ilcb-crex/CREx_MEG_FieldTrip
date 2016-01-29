function strclust = str_clusterparam(statopt)

defopt = struct('strproc', [], 'Nrand', [], 'alphaTHR', [], 'durTHR', [],...
    'WOI', []);

statopt = check_opt(statopt, defopt);

if isempty(statopt.Nrand)
    nrd = 'unkwn';
else
    nrd = num2str(statopt.Nrand);
end

if isempty(statopt.alphaTHR)
    athr = 'unknw';
else
    athr = num2str(statopt.alphaTHR);
    athr(athr=='.') = 'p';
end

if isempty(statopt.durTHR)
    dthr = 'unkwn';
else
    dthr = num2str(statopt.durTHR.*1e3,'%4d');
end

sparam = ['N', nrd, '_A', athr, '_D', dthr, 'ms'];

if isempty(statopt.WOI)
    swoi = 'unkwnWOI';
else
    WOIms = statopt.WOI.*1e3;
    swoi = [num2str(WOIms(1),'%4d'), '_', num2str(WOIms(2),'%4d'), 'ms'];
end


% For each group, one figure per anatomical ROI and per condition
strclust = [statopt.strproc,'_', sparam, '_', swoi];

%--- Check opt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end