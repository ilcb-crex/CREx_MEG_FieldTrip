function [allFFTstack,freqst,spsparam] = meg_fftstack_calc(ftData,spsparam)
% Calcul d'un spectre moyen pour chaque capteur 
%
% Un spectre moyen ("stacked spectrum") corresponda la somme de plusieurs 
% spectres calcules sur des portions de donnees consecutives de longueur fixe, 
% divisee par le nombre de portion. 
%
%____ INPUT
%
% ftData : structure des donnees MEG telle que retournee par les fonctions 
%   FieldTrip. Les calculs de spectre sont effectues sur les donnees stockees
%   dans le champ rawData.trial{1}, et plus particulierement pour chaque ligne
%   de la matrice de donnees correspondante (soit, pour chaque canal).
%
% spsparam : une structure contenant les parametres de calcul des spectres
%   moyens. Ceux-ci se limitent a deux variables :
%   spsparam.dur : duree de signal pour le calcul de chaque spectre
%      elementaire, en secondes
%   spsparam.n   : nombre de spectres elementaires a calculer sur les portions 
%      consecutives du signal de duree spsparam.dur
%
%____ OUTPUT
%
% allFFTstack : les spectres moyens pour tous les capteurs (un spectre par
%   ligne = pour un capteur)
% freqst : le vecteur des frequences associe aux valeurs d'amplitude des
%   spectres contenus dans allFFTstack
%
% Trace des spectres moyens de tous les capteurs :
% >> plot(freqst,allFFTstack)
% Trace du spectre moyen calcule sur les donnees du capteur
% FTData.label{10} :
% >> plot(freqst,allFFTstack(10,:))
% 
% Un spectre moyen represente le contenu frequentiel moyen d'une partie
% des donnees de duree spsparam.n x spsparam.dur secondes. 
%
% Valeurs par defaut si spsparam n'est pas entre en argument de la fonction :
% spsparam.dur = 20 et spsparam.n = 30
% => Un spectre stacke est obtenu par le moyennage de 30 spectres calcules 
% sur chaque portion consecutive des donnees temporelles de 20 secondes. 
% 
% Pour exclure les possibles artefacts au niveau de la bordure inferieur des
% donnees, le calcul des fft ne debute qu'apres les 2 premieres portions de
% spsparam.dur secondes.
% => avec les parametres par defaut par exemple, les calculs de spectres 
% est effectue entre 40 s et 340 s.
%
% Si les parametres spsparam entres par l'utilisateur ne conviennent pas,
% les parametres par defaut sont testes. S'il ne conviennent pas a leur
% tour, le programme retourne des valeurs vides de feqst et allFFTstack.
% (ex. : duree des donnees trop courte pour calculer spsparam.n spectres
% sur des portions de spsparam.dur s)
% 
%
% Les spectres sont calcules par l'algorithme FFT (Fast Fourier Transform), 
% implemente dans la fonction fft de Matlab (Signal Processing Toolbox). 
%
%----------
% CREx 20131129

default.dur=20;
default.n=30;

fsamp=ftData.fsample;
xall=ftData.trial{1};

% Apply default parameter if spsparam is not specified
if nargin<2 
    spsparam.dur = default.dur; % Elementary duration in second
    spsparam.n = default.n;   % Number of elementary spectum to average
else
    % Check for the spsparam structure
    if ~isfield(spsparam,'n')  || ~isfield(spsparam,'dur') ...
            || length(spsparam.n)~=1 || length(spsparam.dur)~=1 ...
            || ~isnumeric(spsparam.n)|| ~isnumeric(spsparam.dur)
        % Default parameters
        spsparam.dur = default.dur; % Elementary duration in second
        spsparam.n = default.n;   % Number of elementary spectum to average
    end
end   
[spsparam,stcalc]=check_stackparam(xall(1,:),fsamp,spsparam,default);

if stcalc
    lgsp=floor(spsparam.dur*fsamp+1);  % Number of sample per elementary spectrum
    lgspm=lgsp*spsparam.n;             % Total length of used data to make the stack
    ixi=floor(spsparam.dur*2*fsamp+1); % The first 2*sps_dur s are excluded 
    ixf=ixi+lgspm-1;
    nsampst=2^nextpow2(lgsp);			
    freqst=(fsamp/nsampst)*(0:(nsampst/2)-1);
    allFFTstack=zeros(length(xall(:,1)),length(freqst));
    for c=1:length(xall(:,1)) % Per channel
        xd=xall(c,:);
        % Stack
        xdp=xd(ixi:ixf);
        fxall=zeros(spsparam.n,length(freqst));
        for s=1:spsparam.n
            vind=(1:lgsp)+(s-1)*lgsp;
            fxd=fft(xdp(vind),nsampst);
            fxall(s,:)=abs(fxd(1:nsampst/2))*2./nsampst;
        end
        allFFTstack(c,:)=mean(fxall);
    end
else
    allFFTstack=[];
    freqst=[];
end


function [spsparam,stcalc] = check_stackparam(xdata,fsamp,spsparam,default)

td = 0:1/fsamp:(length(xdata)-1)/fsamp;
lgsp = floor(spsparam.dur*fsamp+1);  % Number of sample per elementary spectrum
lgspm = lgsp*spsparam.n;             % Total length of used data to make the stack
ixi = floor(spsparam.dur*2*fsamp+1); % The first sps_dur*2 s are excluded 
ixf = ixi+lgspm-1;
if spsparam.dur==default.dur && spsparam.n==default.n
    def=1;
else
    def=0;
end
% Duration of data too short
if ixf>length(xdata)
    % Reduction of the number of consecutive spectrum to be stacked
    spsparam.n = floor((td(end)-td(ixi))./spsparam.dur);
    if spsparam.n<2
        disp(' '), disp('-------!!!!!---------')
        disp('Stacked spectrum calculation impossible')
        disp('with calculation parameters')
        disp('-------!!!!!---------'), disp(' ')
        if ~def   
            % Try with default parameters
            spsparam.dur = default.dur; % Elementary duration in second
            spsparam.n = default.n;   % Number of elementary spectum to average
            lgsp = floor(spsparam.dur*fsamp+1);  % Number of sample per elementary spectrum
            lgspm = lgsp*spsparam.n;             % Total length of used data to make the stack
            ixi = floor(spsparam.dur*2*fsamp+1); % The first sps_dur*2 s are excluded 
            ixf = ixi+lgspm-1;
            if ixf > length(xdata)
                % Reduction of the number of consecutive spectrum to be stacked
                spsparam.n = floor((td(end)-td(ixi))./spsparam.dur);
                if spsparam.n<2
                    stcalc = 0;
                else
                    stcalc = 1;
                end
            else
                stcalc = 1;
            end
            if stcalc
                disp(' '),disp('Default parameters will be used')
            end
        else
            stcalc = 0;
        end
    else
        stcalc = 1;
    end
else
    stcalc = 1;
end
if stcalc
    disp(' '),disp('- - - - - - -')
    disp([' => ',num2str(spsparam.n),' spectra calculated on each'])
    disp(['    ',num2str(spsparam.dur),'s-duration consecutive portions'])
    disp('    of data will be stacked')
    disp('- - - - - - -'), disp(' ')
end
