function format_label(ax)
% Format figure's labels: if data point values are representing with a "x 10^n"
% at the x or y axis extremity, this indication is removed and added inside
% the label string of the axis.
% Example: if x-axis is ranging for 0 to 10^4 with label "Time (s)",
% label is changing by "Time (x 10^4 s)", and the "x 10^4" indication that was 
% automatically put by Matlab at the axe end is removing.
% Units are assumed to be indicating inside parenthesis. If no units are
% found, the puissance of 10 is added inside parenthesis (ex. "Amplitude"
% label becomes "Amplitude (x10^4)"
%____
%-CREx 20131030 
%-CREx-BLRI-AMU project: https://github.com/blri/CREx_MEG/fieldtrip_process
% Adapted from acvolc toolbox - (C. Zielinski phD, 2012)

if nargin==0
    ax = 'xy';
end
if length(ax) == 2 || ax=='x'
    change_label('x')
end
if length(ax) == 2 || ax=='y'
    change_label('y')
end

function exp = get_expo(sax)
% Get tick labels
strticks = get(gca,[sax, 'ticklabel']);
% Get ticks values
ticks = get(gca, [sax, 'tick']);
% Initialize
exp = [];
if ~isempty(strticks) && ~isempty(ticks)
    % Check if data are corresponding to date string
    isdat = 0;
    if (sax=='x')
        stt = strticks{1};
        % Special case where x-label are years    
        if (length(stt)==4 && sum(strcmp(stt(1:2), {'19','20'})==1))
            isdat = 1;
        end
    end

    if ~isdat
        maxval = max(ticks);
        mlab = str2double(strticks(ticks==maxval,:));
        ratio = str2double(num2str(maxval, 10))/mlab;
        if ratio~=1
            exp = num2str(real(log10(ratio)));
        end
    end
end
            
function change_label(sax)
    % No need to change axe label if no label are set
    isax = ~isempty(get(get(gca, [sax, 'label']), 'string'));
    if isax
        % Exponent value
        exp = get_expo(sax);
        if ~isempty(exp)
            
            % Get label of the axes
            hlab = get(gca, [sax,'label']);
            axlab = get(hlab, 'string');
            if ~isempty(axlab)
                isc = 0;
                if iscell(axlab)==1
                    isc = 1;
                    % Units indication are assumed to be at the end of the
                    % cell
                    tempcel = axlab(1:end-1);
                    axlab = axlab{end};
                end
                
                % Get the physical units if specified inside parenthesis
                units = regexp(axlab, '(?<=\()\S+(?=\))', 'match', 'once');
                sexp = ['x 10^{', exp,'}'];
                if isempty(units)
                    newlab = [axlab, ' (', sexp,')'];
                else
                    newlab = strrep(axlab, units, [sexp,' ', units]);
                end
                if isc==1
                    newlab = [tempcel ; newlab];
                end
                set(hlab, 'string', newlab)
                % Remove the x10^n from the end of the axe
                set(gca, [sax,'ticklabel'], get(gca,[sax, 'ticklabel']));
            end
        end
    end
