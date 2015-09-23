function [M1, Sdat] = spm_eeg_inv_datareg_hdmYH(S)
% Co-registration of two setse of fiducials according to sets of
% corresponding points and (optionally) headshapes.
% rigid co-registration
%           1: fiducials based (3 landmarks: nasion, left ear, right ear)
%           2: surface matching between sensor mesh and headshape
%           (starts with a type 1 registration)
%
% FORMAT M1 = spm_eeg_inv_datareg(S)
%
% Input:
%
% S  - input struct
% fields of S:
%
% S.sourcefid  - EEG fiducials (struct)
% S.targetfid = MRI fiducials
% S.template  - 1 - input is a template (for EEG)
%               0 - input is an individual head model
%               2 - input is a template (for MEG) - enforce uniform scaling
%
% S.useheadshape - 1 use headshape matching 0 - don't
%
%
% Output:
% M1 = homogenous transformation matrix
%
% If a template is used, the senor locations are transformed using an
% affine (rigid body) mapping.  If headshape locations are supplied
% this is generalized to a full twelve parameter affine mapping (n.b.
% this might not be appropriate for MEG data).
%__________________________________________________________________________
% Copyright (C) 2008 Wellcome Trust Centre for Neuroimaging
% Jeremie Mattout
% $Id: spm_eeg_inv_datareg.m 3833 2010-04-22 14:49:48Z vladimir $
%
%
% _____ CREx 2014 modifications :
% % Sdat :
% Structure that will contained the sourcefid transformations from the
% calculations step : 
% [1] Initial data (MEG headshape + fid) and (MRI mesh + fid)
% [2] First Estimate-apply rigid body transform to sensor space
% [3] If input is a template : Affine (rigid body) mapping - Scale and Move
% [4] If a headshape is supplied : Surface matching between the scalp 
% vertices in MRI space and the headshape positions in data space - Nearest 
% point registration by spm_eeg_inv_icp
%
% spm_eeg_inv_icp_hdmYH is used instead of spm_eeg_inv_icp
%
% Yuval Harpaz modifications for spm_eeg_inv_icp parameters are included
% here (icp_aff and icp_nRot)


if nargin == 0 || ~isstruct(S)
    error('Input struct is required');
end
if S.template == 2  % Cas d'un template pour la MEG : on limite la transformation
    icp_aff = 1;
    icp_nRot = 5;
else
    icp_aff = 0;
    icp_nRot = 64;
end

if ~isfield(S, 'targetfid')
    error('Target fiducials are missing');
else
    targetfid = ft_convert_units(S.targetfid, 'mm');
end

if ~isfield(S, 'sourcefid')
    error('Source are missing');
else
    sourcefid = ft_convert_units(S.sourcefid, 'mm');
    [sel1, sel2] = spm_match_str(targetfid.fid.label, sourcefid.fid.label);
    sourcefid.fid.pnt = sourcefid.fid.pnt(sel2, :);
    sourcefid.fid.label = sourcefid.fid.label(sel2);

    targetfid.fid.pnt = targetfid.fid.pnt(sel1, :);
    targetfid.fid.label = targetfid.fid.label(sel1);
end

if ~isfield(S, 'template')
    S.template = 0;
end



Sdat = struct; 
Sdat.target = targetfid;
Sdat.sources{1} = sourcefid;
Sdat.names = {'Initial'};

% Estimate-apply rigid body transform to sensor space
%--------------------------------------------------------------------------
M1 = spm_eeg_inv_rigidreg(targetfid.fid.pnt', sourcefid.fid.pnt');

sourcefid = ft_transform_headshape(M1, sourcefid);
Sdat.sources{2} = sourcefid;
Sdat.names{2} = 'Step 1';
g = 3;

if S.template
    
    % constrained affine transform
    %--------------------------------------------------------------------------
    
    for i = 1:64

        % scale
        %----------------------------------------------------------------------
        M       = pinv(sourcefid.fid.pnt(:))*targetfid.fid.pnt(:);
        M       = sparse(1:4,1:4,[M M M 1]);

        sourcefid = ft_transform_headshape(M, sourcefid);

        M1      = M*M1;

        % and move
        %----------------------------------------------------------------------
        M       = spm_eeg_inv_rigidreg(targetfid.fid.pnt', sourcefid.fid.pnt');

        sourcefid = ft_transform_headshape(M, sourcefid);

        M1      = M*M1;
  
        if (norm(M)-1)< eps
            disp('-- spm_eeg_inv_datareg_hdmYH')
            disp(['Number of iteration = ',num2str(i)])
            break;
        end
    end
    Sdat.sources{g} = sourcefid;
    Sdat.names{g} = ['Step ',num2str(g-1)];
    g = g+1;
end


% Surface matching between the scalp vertices in MRI space and
% the headshape positions in data space
%--------------------------------------------------------------------------
if  S.useheadshape && isfield(sourcefid, 'pnt') && ~isempty(sourcefid.pnt) 

    headshape = sourcefid.pnt; % M(x,y,z) coordinates => Should be M x 3 matrix
    scalpvert = targetfid.pnt;

    if size(headshape,2) > size(headshape,1) % ex [ 3 x 8196 ]
        headshape = headshape';              % =>  [ 8196 x 3 ]
    end
    if size(scalpvert,2) > size(scalpvert,1)
        scalpvert = scalpvert';
    end

    % nearest point registration. Need [3 x M] data pnt
    %----------------------------------------------------------------------
    M  = spm_eeg_inv_icp_hdmYH(scalpvert',headshape',targetfid.fid.pnt',sourcefid.fid.pnt', icp_aff, icp_nRot);

    % transform headshape and eeg fiducials
    %----------------------------------------------------------------------
    sourcefid = ft_transform_headshape(M, sourcefid);
    M1        = M*M1;
    
    Sdat.sources{g} = sourcefid;
    Sdat.names{g} = ['Step ',num2str(g-1)];
end
