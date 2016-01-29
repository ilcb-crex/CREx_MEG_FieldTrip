function dispname(object, eventdata)

% First click ?
if isempty(get(get(gca,'title'),'string'))
    first = true;
else
    first = false;
end
% Background color
if all(get(gcf,'color'))
    titcol = [0 0 0];
else
    titcol = [1 1 1];
end
if strcmp(get(gco,'type'), 'line')

    title(get(gco,'displayname'),'fontsize',24, 'color', titcol,'interpreter','none');

    prev_size = get(gco,'markersize');
    prev_gco = gco;
    
    set(gco, 'markersize',prev_size+2)

    set(gcf, 'WindowButtonDownFcn', {@after_line, prev_gco, prev_size});
    if first
        set(prev_gco, 'markersize',prev_size)
    end
    set(gcf, 'WindowButtonUpFcn', @dispname);

elseif strcmp(get(gco,'type'), 'patch')

    title(get(gco,'displayname'),'fontsize',24, 'color', titcol,'interpreter','none');

    prev_alpha = get(gco,'facealpha');
    prev_gco = gco;
    
    set(gco, 'facealpha',prev_alpha+.5)

    set(gcf, 'WindowButtonDownFcn', {@after_patch, prev_gco, prev_alpha});
    if first
        set(prev_gco, 'facealpha',prev_alpha)
    end
    set(gcf, 'WindowButtonUpFcn', @dispname);
end

function after_line(obj, ev, prev_gco, prev_size)

set(prev_gco, 'markersize',prev_size)

function after_patch(obj, ev, prev_gco, prev_alpha)

set(prev_gco, 'facealpha',prev_alpha)
