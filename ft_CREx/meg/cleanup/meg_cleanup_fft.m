function meg_cleanup_fft(dirpath, fftopt)
% Data viTrois types de figures generees pour controler les donnees au niveau de
% chaque canal :
% (1) Donnees continues et 2 zooms (10 premieres secondes et autour du
% maximum d'amplitude)
% (2) Spectres stackes superposes
% (3) Donnees continues et spectres associes


if nargin==1 || isempty(fftopt.datatyp)==1
    fftopt.datatyp = '4D';
end

fprintf('\nProcessing of data in :\n%s\n\n', dirpath);
       
if strcmpi(fftopt.datatyp,'4D')==0
    disp(['Check for preprocessed data: ',fftopt.datatyp,'Data*.mat'])
    [pmat,nmat] = dirlate(dirpath,[fftopt.datatyp,'Data*.mat']);
    if ~isempty(pmat)
        disp(['Find : ',nmat])
        fprintf('\n\t-------\nLoading of dataset...\n\t-------\n')
        ftData = loadvar(pmat,'*Data*');
        datapath=pmat;
        ok=1;
        fprintf('\n\t-------\nFFT calculations on preprocessed dataset\n\t-------\n')
    else
        disp(' ')
        disp('Preprocessed data not found...')
        ok=0;
    end
else
    ftData = meg_exctract4d(dirpath);
    if ~isempty(ftData)
        ok=1;
        nmat=[];
        fprintf('\n\t-------\nFFT calculations on raw dataset\n\t-------\n')
    else
        ok=0;
    end
end
if ok
    datatyp = fftopt.datatyp;
    pdir = make_dir([dirpath, filesep, '_preproc'], 0);
    spdir = make_dir([pdir,filesep,'fftplots_',datatyp],1);    
    % Launch fft calculations
     [allFFT, freq] = meg_fft_calc(ftData);
    
    % Figures with the dedicated subfunction
    meg_fft_fig(ftData, freq, allFFT, datapath, fdossp, datatyp)
    label = ftData.label; %#ok
    if ~isempty(nmat)
        suff=['_',meg_matsuff(nmat)];
    else
        suff='';
    end
% %     save([fdossp,filesep,'FFT_',datatyp,'Data',suff],'freq','allFFT','label')
    
    % Stacked spectrum with default paramaters (spsparam.n=30 and
    % spsparam.dur=20 s) :
    [allFFTstack, freqst, spsparam] = meg_fftstack_calc(ftData);    
        
    % Pour le stack - figures
    if ~isempty(allFFTstack)
        meg_fftstack_fig(ftData, freqst, allFFTstack, spsparam, datapath, spdir, datatyp) 
        namstk = ['FFTstack_',datatyp,'Data',suff,'_N',num2str(spsparam.n),'DUR',num2str(round(spsparam.dur)),'s'];
        save([spdir,filesep,namstk],'freqst','allFFTstack','spsparam','label')
    end
    
    if strcmpi(datatyp,'filt')==1
        % Figure avec des zooms dans les donnees pour mieux voir si probleme
        fdosz = make_dir([pdir,filesep,'datadisp_',datatyp],1);    
        meg_zoomdata(ftData, datapath, fdosz, datatyp)
    end    
    disp(' '),disp('Matrix of fft results saved in ----')
    disp(['----> ',spdir]),disp(' ')
end
