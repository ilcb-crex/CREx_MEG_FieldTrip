function fopt = meg_filtopt(filtopt)
% Check the input parameters structure for the meg_cleanup_filt function
% If filtopt.type is set to 'ask', type and cut-off frequencies are asking
% to the user on the matlab command window.
%
fopt = struct('type', '', 'fc', [], 'figflag', 1);
if nargin==0 || isempty(filtopt) || ~isfield(filtopt,'type')...
         || (isfield(filtopt,'type') && isempty(filtopt.type))
    filtopt.type = 'none';
end
if isfield(filtopt,'fc')
    fcin = filtopt.fc;
else
    fcin = [];
end
if isfield(filtopt,'figflag')...
        && (filtopt.figflag==1 || filtopt.figflag==0)
    fopt.figflag = filtopt.figflag;
end

if nargin==1 
    switch lower(filtopt.type)
        case 'none'
            fopt.type = 'none';
            fprintf('None filter selected \n\n');
            return
        case 'hp'
            F = 1;
        case 'lp'
            F = 2;
        case 'bp'
            F = 3;
        otherwise
            filtopt.type = 'ask';
    end
end

% Ask mode : frequency are enter by the user on the command prompt
if strcmp(filtopt.type,'ask')
    fprintf('\n\t\t--------\n\tFiltering options\n\t\t--------\n\n');
    disp('Kind of filter to apply :')
    disp('   None       -> 0')
    disp('   High-pass  -> 1')
    disp('   Low-pass   -> 2')
    disp('   Band-pass  -> 3')
    F = input('              -> ');
    fcz = zeros(1,2);
    disp(' ')
    if F==1 || F==3
        fcz(1) = input('High-pass cut-off frequency (Hz) : ');
    end
    if F==2 || F==3
        fcz(2) = input('Low-pass  cut-off frequency (Hz) : ');
    end
    disp(' ')
    fcin = fcz(fcz>0);
    if F==0
        fopt.type = 'none';
        return
    end
end

if ~isempty(fcin)
    fcin = fcin(fcin>0);
end

% Check for the fc values depending on the filter type
switch F
    case 1
        disp('High-pass filter : ')
        if isempty(fcin) || numel(fcin)>2
            fc = input('Enter cut-off frequency (Hz) : ');                
        elseif numel(fcin)==2
            fc = fcin(1);
        else
            fc = fcin;
        end
        disp(['Cut-off frequency = ',num2str(fc),' Hz'])
        fopt.type='hp';      
        fopt.fc=fc;
    case 2
        disp('Low-pass filter : ')
        if isempty(fcin) ||numel(fcin)>2
            fc = input('Enter cut-off frequency (Hz) : ');
        elseif numel(fcin)==2
            fc = fcin(2);
        else
            fc = fcin;
        end
        disp(['Cut-off frequency = ',num2str(fc),' Hz'])
        fopt.type = 'lp';
        fopt.fc = fc;
    case 3
        disp('Band-pass filter : ')
        if numel(fcin)==2
            fc=fcin;
        end
        if isempty(fcin) || numel(fcin)>2 || numel(fcin)==1
            fc = zeros(1,2);
            fc(1) = input('Enter High-pass cut-off frequency (Hz) : ');
            fc(2) = input('Enter  Low-pass cut-off frequency (Hz) : ');
        end
        disp(['Cut-off frequency = [',num2str(fc(1)),' - ',num2str(fc(2)),'] Hz'])
        fopt.type='bp';
        fopt.fc = fc;     
end


            

            