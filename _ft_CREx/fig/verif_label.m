function verif_label(ax)
if nargin==0
    ax='xy';
end

if sum(strfind(ax,'x'))>0
    xtval=get(gca,'xtick');
    xtlab=get(gca,'xticklabel');
    maxx=max(xtval);
    isc=0;
    dat=0;
    if length(xtlab(1,:))==4 && (strcmp(xtlab(1,1:2),'19')==1 || strcmp(xtlab(1,1:2),'20')==1)
        dat=1;
    end
    if ~isnan(str2double(xtlab(1,:))) && dat==0
        vlab=str2double(xtlab(xtval==maxx,:));
        rapx=str2num(num2str(maxx,10))/vlab;
        if rapx~=1
            valx=num2str(real(log10(rapx)));
            id=get(gca,'xlabel');
            xstr=get(id,'string');
            if isempty(xstr)==0
                if iscell(xstr)==1
                    isc=1;
                    ligav=cell(length(xstr),1);
                    ligav(1:length(xstr)-1)=xstr(1:length(xstr)-1);
                    xstr=xstr{length(xstr)};
                end
                set(gca,'xticklabel',xtlab)
                fsize=get(id,'fontsize');
                fpi=findstr(xstr,'(');
                fpf=findstr(xstr,')');
                if ~isempty(fpi) && ~isempty(fpf)
                    unit=xstr(fpi(end)+1:fpf(end)-1);
                    newlab=[xstr(1:fpi(end)),'x 10^{',valx,'} ',unit,')'];
                else
                    newlab=[xstr,' (x 10^{',valx,'})'];
                end
                if isc==1
                    ligav{end}=newlab;
                    newlab=ligav;
                end
                xlabel(newlab,'fontsize',fsize)
            end
        end
    end
end

if sum(strfind(ax,'y'))>0
    ytval=get(gca,'ytick');
    ytlab=get(gca,'yticklabel');
    maxy=max(ytval);
    isc=0;
    if ~isnan(str2double(ytlab(1,:)))
        vlab=str2double(ytlab(ytval==maxy,:));
        rapy=str2num(num2str(maxy,10))/vlab;
        if rapy~=1
            valy=num2str(real(log10(rapy)));
            id=get(gca,'ylabel');
            ystr=get(id,'string');
            if isempty(ystr)==0
                if iscell(ystr)==1
                    isc=1;
                    ligav=cell(length(ystr),1);
                    ligav(1:length(ystr)-1)=ystr(1:length(ystr)-1);
                    ystr=ystr{length(ystr)};
                end
                set(gca,'yticklabel',ytlab)
                fsize=get(id,'fontsize');
                fpi=findstr(ystr,'(');
                fpf=findstr(ystr,')');
                if ~isempty(fpi) && ~isempty(fpf)
                    unit=ystr(fpi(end)+1:fpf(end)-1);
                    newlab=[ystr(1:fpi(end)),'x 10^{',valy,'} ',unit,')'];
                else
                    newlab=[ystr,' (x 10^{',valy,'})'];
                end
                if isc==1
                    ligav{end}=newlab;
                    newlab=ligav;
                end
                ylabel(newlab,'fontsize',fsize)
            end
        end
    end
end


