function Ssource = compute_z(Ssource, opt)
% Compute Z-normalisation of the source signal (from "mom" field), and add 
% the "z" field with the new normalized signals at the same level than 
% "mom" values.
% Ssource can hold several substructures containing "mom" matrices with
% the required "time" field as well.
% Each time a "mom" field is found in a substructure, the corresponding 
% z-normalised values are computed and added to the substructure.
% It is possible to add the subsequent "absz" field (absolute values) 
% or "z2" field (square values) to the substructure by setting opt.paramstr 
% to "absz" or "z2" respectively.
% The Z-normalisation is calculated considering the mom source signal
% portion indicated in opt.tnormz boundaries vector.

defopt = struct('tnormz', [], 'tbslcor', [], 'paramstr', 'z');

if nargin < 2 || isempty(opt)
    opt = defopt;
else
    opt = check_opt(opt, defopt);
end

% Find substructure of Ssource containing "mom" field and add z values
time = get_field(Ssource, 'time');
Ssource = add_z_substruct(Ssource, time, 'mom', opt);


function S = add_z_substruct(S, time, fname, zopt)

if isstruct(S)
    Snames = fieldnames(S);
    vstr = strcmp(Snames, fname);
    % fname field find in S fieldnames
    if sum(vstr)==1
        S.time = time;
        S = add_z(S, zopt.tnormz, zopt.tbslcor);
        if strcmp(zopt.paramstr, 'absz')
            S.absz = abs(S.z);
        elseif strcmp(zopt.paramstr, 'z2')
            S.z2 = S.z.^2;
        end
    end
    % We search also in each substructure
    for n = 1:length(Snames)
        % disp(['Check inside : ',Snames{n}]) 
        S.(Snames{n}) = add_z_substruct(S.(Snames{n}), time, fname, zopt);
    end 
end

function Smom = add_z(Smom, tnormz, tbslcor)

time = Smom.time;
mom = Smom.mom;

%- Convert mom cell to mat (with only the inside dipoles)
if iscell(mom)
    mom = cell2mat(mom);
end

% Two possible dimensions for mom : 
% Ndip x Ntimes (comes from individual source analysis)
% Nsubj x Ndip x Ntimes (comes from grand average processing)


%- Compute new baseline correction

% [ 1 ] - Z-normalization considering activity before priming
if isempty(tnormz)
    tnormz = [time(1) 0];
end
inorm = find(time >= tnormz(1) & time<= tnormz(2));
nd = ndims(mom);
if nd==2
    mean_norm = mean(mom(:, inorm) ,2);
    rmean_norm = repmat(mean_norm, [1 length(time)]);
    std_norm = std(mom(:,inorm), 0, 2);
    rstd_norm = repmat(std_norm, [1 length(time)]);
else
    mean_norm = mean(mom(:,:, inorm) ,3);
    rmean_norm = repmat(mean_norm, [1 1 length(time)]);
    std_norm = std(mom(:,:,inorm), 0, 3);
    rstd_norm = repmat(std_norm, [1 1 length(time)]);
end
z = ( mom - rmean_norm )./ rstd_norm;

% [ 2 ] - Remove baseline considering priming signal
if ~isempty(tbslcor)
    ibslc = find(time >= tbslcor(1) & time <=tbslcor(2));
    if nd == 2
        mean_bsl = mean(z(:, ibslc) ,2); 
        rmean_bsl = repmat(mean_bsl, [1 length(time)]);
    else
        mean_bsl = mean(z(:,:, ibslc) ,3); 
        rmean_bsl = repmat(mean_bsl, [1 1 length(time)]);
    end
    z = ( z - rmean_bsl ); 
end

Smom.z = z;

%--- Check opt options
function opt = check_opt(opt, defopt)
fn = fieldnames(defopt);
for n = 1:length(fn)
    if ~isfield(opt, fn{n}) || isempty(opt.(fn{n}))
        opt.(fn{n}) = defopt.(fn{n});
    end
end