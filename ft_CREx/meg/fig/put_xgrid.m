function [sunit, xpos] = put_xgrid(xlimits, ylimits, dtsec, fontsz)
% Add vertical time grid to the figure
% A vertical dotted line is drawing each dtsec secondes with the
% associated label, in secondes or in miliseconds (depending on the 
% xlimits range)

if nargin < 4
    fontsz = 12;
end

if nargin < 3 || isempty(dtsec)
    dtsec = 0.100;% 100 ms (default supposing MEG data !)
    % A proper way should be to adapt the time ticks to the data
    % cf. dtsec to have 10 time markers on the figure 
end

if nargin < 2 || isempty(ylimits)
    ylimits = ylim;
end

if nargin < 1 || isempty(xlimits)
    xlimits = xlim;
end

cola = get(gca, 'color');
if sum(cola)==0
    col = [0.85 0.85 0.85];
else
    col = [0 0 0];
end

xlim(xlimits)

XL = zeros(1,2);
XL(1) = floor(xlimits(1));
XL(2) = ceil(xlimits(2));

yl = ylimits;

% Define shorter ylim for vertical lines in order they don't cross the axis
% depending on the vertical tick length
deltay = yl(2)-yl(1);

tckl = get(gca,'ticklength');

pos = get(gca,'position');
l = pos(3); 
h = pos(4);
if l>=h
    vtck = (tckl(1)*l*deltay)/h;
else
    vtck = deltay*tckl(1);
end

yi = yl(1)+0.5*vtck;
yf = yl(2)-0.5*vtck;

ylin = [yi yf];

%--- Time markers (vertical dotted lines), y and x-axis

% Time grid
vgini = XL(1) : dtsec : XL(2) + 2*dtsec; 
% Suppose no signal with pre- and post- stimulation duration < 10 s
igi = find(vgini > xlimits(1), 1, 'first');
igf = find(vgini < xlimits(2), 1, 'last');
vgrid = vgini(igi:igf);
vgrid = repmat(vgrid, 2, 1);
line(vgrid, repmat(ylin, length(vgrid),1)', 'color',[.45 .45 .45],'linestyle',':','linewidth', 0.8)

plab = xlabel(' ');
xpos = get(plab, 'position');

set(gca, 'xtick',[])
ylim(yl) 
if diff(xlimits) < 2
    msec = true;
    sunit = 'ms';
else
    msec = false;
    sunit = 's';
end
% Time labels in ms
for v = 1:length(vgrid(1,:))
    if msec
        text(vgrid(1,v), yl(1)-diff(yl)./25, num2str(vgrid(1,v)*1e3,'%3.0f'),...
            'fontsize', fontsz, 'horizontalalignment','center', 'color', col)
    else
        text(vgrid(1,v), yl(1)-diff(yl)./25, num2str(vgrid(1,v)),...
            'fontsize', fontsz, 'horizontalalignment','center', 'color', col)     
    end
end

