function Sbad = meg_rmtrials_input(pmat, fnames)

fprintf('\n------\nSelection of bad trials indices to remove\n-----\n\n');

  
%-- Return bad trials indices structure and trials dataset structure
    
fprintf('\nInput trials data :\n%s\n\n------\n', pmat);
disp('Remove trial(s) -> 1')
disp('Keep all trials -> 2')

rep = input('                -> ');

Nc = length(fnames);
Sbad = struct; 


% Enter bad trials indices for each condition    
for j = 1 : Nc
    cond = fnames{j};

    if rep==1
        % Bad trial indices
        % A priori, there will never have more than 1000 indices of bad
        % trials input
        ibadt = input_badtrial(cond, 1e3); 
    else
        ibadt = [];
    end

    Sbad.(cond) = ibadt;
end


%-- Enter bad trials and confirm selection
function ibadtrials = input_badtrial(fcond, ntrials)

doagain = 0;
while doagain==0
    fprintf('\n\n-------\n');
    disp(['Trials for condition : ', fcond])
    disp(' ')
    disp(' Reject one or more trials (1)')
    goon = input('       or keep all of them (0) : ');
    
    % Initialisation
    % Bad trial indices 
    ibadtrials = zeros(1, ntrials);
    k = 1;
    while goon
        disp(' ')
        btr = input(['Enter bad trial n°',num2str(k),' : ']);
        if ~isempty(btr) && btr~=0            
            ibadtrials(k) = btr;
            k = k + 1;     
        end
        disp(' ')
        disp('Enter a new bad trial (1)')
        goon = input('          or stop now (0) : ');
    end
    
    ibadtrials = unique(ibadtrials(1 : k-1));
    % Return empty matrix if no trials selected
    
    fprintf('\nBad trials summary for condition : %s\n', fcond);
    if isempty(ibadtrials)
        disp('No one selected')
    else
        disp(ibadtrials)
    end
    fprintf('\nConfirm this selection (1)\n');
    doagain = input('     Or enter a new one (0): ');
end
fprintf('-------\n\n');