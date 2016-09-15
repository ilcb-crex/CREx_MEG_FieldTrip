function cleanpadData = meg_padding_artefact(ftData, windef)
% Removing of energetic artefacts inside continuous data
% - artefact that are visible on the major part of the channels
% For data at each channels, the artefact portions are substituted by a
% miror image of the preceding data. All the events falling inside the 
% artefact portions are removal from the cfg_event structure (that will be
% use to do data epoching by meg_ft_preproc_extractrial)
% -- ftData : Fieldtrip data structure of continuous data set
% -- windef : temporal windows that define all data portions containing artefacts 
%         -> matrix [Nart x 2] col.1 : artefact window begining ; col.2 : ending
%            as many lines as artefacts to delete (Nart)
%
% If data protion is to long to be replaced by the miror image of 
% subsequent data, artefact portion values are replace by zeros.

td = ftData.time{1};
xall = ftData.trial{1};
artpad = zeros(size(windef));
for nw = 1:length(windef(:,1))
    disp(' ')
    disp(['Padding data part : [ ',num2str(windef(nw,1)),' - ',num2str(windef(nw,2)),' ] s'])
    badidx = find(td>=windef(nw,1) & td<=windef(nw,2));
    lgwin = length(badidx);
    if badidx(1)-lgwin > 0
        xall(:,badidx) = xall(:,badidx(1)-1:-1:badidx(1)-lgwin);
    else
        if badidx(end)+lgwin < length(xall(1,:))
            xall(:,badidx) = xall(:,badidx(end)+1:badidx(end)+lgwin);
        else
            
            disp(' ')
            disp('----!!!!----')
            disp('Padding artefact window by ZEROS')
            disp(['windef : ',num2str(windef(nw,1)),' to ',num2str(windef(nw,2)),' s'])
            disp('----!!!!----')
            xall(:,badidx) = 0;
        end
    end
    artpad(nw,:) = [badidx(1) badidx(end)];
end

cleanpadData = ftData;
cleanpadData.trial{1} = xall;
cleanpadData.artpad = artpad;

        