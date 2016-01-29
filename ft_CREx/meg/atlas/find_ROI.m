function [idROI, labROI] = find_ROI(label, list)
% Find ROI labels names and indices matching with each searching list names
% in the atlas ROI names label
% label = cellule containing all ROI names 
% list : list of searched ROIs 
% Ex. : 
% label = atlas.tissuelabel; % atlas structure return by ft_read_atlas 
% list = {'Frontal_*L', 'Lingual'};
% =>> Will return this display :
% -------------
% --ROI matching names--
% 
% -- Frontal_Sup_L         3
% -- Frontal_Sup_Orb_L     5
% -- Frontal_Mid_L         7
% -- Frontal_Mid_Orb_L     9
% -- Frontal_Inf_Oper_L    11
% -- Frontal_Inf_Tri_L     13
% -- Frontal_Inf_Orb_L     15
% -- Frontal_Sup_Medial_L  23
% -- Frontal_Med_Orb_L     25
% -- Lingual_L             47
% -- Lingual_R             48
% 
% -------------
% with indices stores in idROI vector and associated label names in labROI
% cellule
%
%--- CREx 151020
fprintf('\n\n-------------\n--ROI matching names--\n\n');

if ischar(list)
    list = {list};
end

Nr = length(label);

idROI = zeros(Nr, 1);
k = 1;

for n = 1 : length(list)
    sname = list{n};
    % Perfect matching
    ishere = strcmpi(label, sname);
    if any(ishere)
        idROI(k) = find(ishere==1);
        k = k + 1;
    else
%         snamei = sname;
        es = sname(end);
        ijok = strfind(sname, '*');
        % Search all matchings with regexpi
        if ~isempty(ijok)   
            rname = strrep(sname, '*', '\w*');
            if strcmp(es, 'R') || strcmp(es, 'L')
                % Must be Right or Left label name 
                sname = [rname, '$'];
            else
                % Regardless the end
                sname = [rname,'\w*'];
            end
        end
        ima = regexpi(label, sname);
        cm = cell2mat(ima);
        if ~isempty(cm)
            % Some matching are found
            for i = 1 : Nr
                if ~isempty(ima{i})
                    idROI(k) = i;
                    k = k + 1;
                end
            end
        else            
            fprintf('\n---\n!!!\n')
%             fprintf('%s : no matching found with atlas labels...\n', sname)
%             fprintf('Check for the given ROI name...')
            % Last chance
            % Only if the number of given characters is sufficient (>=6)
            
%             % If joker inside search string, split in 2 part
%             if ~isempty(ijok)
%                 if ijok(end) == length(sname)
%                     
%                 end
%             end
%             sname = strrep(snamei, '*', '');
%             
            ki = k;
%             
%             % Supposition 1 : only an inversion between 2 letters and/or
%             % ROIname containing no upper letter like in label names
%             % Substract the two strings and find the less differences
%             clab = lower(char(label));
%             rnam = lower(sname);
%             croi = repmat(rnam, length(label), 1);
%             dmat = clab(:, 1:length(sname)) - croi;
%             comp_1 = sum(dmat==0, 2);
%             im = find(comp_1==max(comp_1));
%             if length(im)==1 && ( length(clab(1,:)) - max(comp_1) ) < 4
%                 fprintf('\nMaximum of similarity found with :\n%s\n\n',label{im})
%                 idROI(k) = im;
%                 k = k + 1;
%             else
%                 % We still search names that are contain the most common letters
%                 % (but not in the same order and not the same number / repetitions)
%                 comp_2 = zeros(length(label), length(sname));
%                 for c = 1 : length(label)
%                     comp_2(c,:) = ismember(sname, label{c});
%                 end
%                 compsum = sum(comp_2, 2);
%                 im = find(compsum == max(compsum));
%                 if length(im)>1
%                     % Combine with first analysis
%                     imm = find( comp_1(im) == max(comp_1(im)) );
%                     if length(imm)==1
%                          fprintf('\nMaximum of similarity found with :\n%s\n\n',label{im(imm)})
%                         idROI(k) = im(imm);
%                         k = k + 1;
%                     end
%                 end       
%             end
            if k == ki
                fprintf('\nNo matching link found between input ROI name :\n')
                fprintf('%s\nand atlas labels\n', sname)
            end
        end
    end           
end
if k > 1
    idROI = unique(idROI(idROI > 0));
    labROI = label(idROI);
    clab = char(labROI);
    for j = 1 : length(idROI)
        fprintf('-- %s  %d\n', clab(j, :), idROI(j));
    end
else
    idROI = [];
    labROI = [];
end
fprintf('\n-------------\n\n\n');