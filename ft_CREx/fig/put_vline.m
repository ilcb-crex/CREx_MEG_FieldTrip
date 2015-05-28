function put_vline(xcoord,linstyl,vcolor)

if nargin<3
    vcolor=[0 0 0];
end
if nargin<2
    linstyl='-';
end
if sum(xcoord)~=0
    hold on
    yl=get(gca,'ylim');
    for i=1:length(xcoord)
        line([xcoord(i) xcoord(i)],[yl(1) yl(2)],'linestyle',linstyl,'color',vcolor)
    end
end




