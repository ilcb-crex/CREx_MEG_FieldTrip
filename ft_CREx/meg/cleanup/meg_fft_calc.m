function [allFFT, freq] = meg_fft_calc(FTData)

fsamp = FTData.fsample;
xall = FTData.trial{1};
% The length of data is assumed to be constant for all channel
% Number of point used for FFT calculation
nsamp = 2^nextpow2(length(xall(1,:)));
freq = (fsamp/nsamp)*(0:(nsamp/2)-1); 

% Initialization
allFFT = zeros(length(xall(:,1)),length(freq));

for c = 1:length(xall(:,1)) % Per channel
    xd = xall(c,:);
    % FFT calculus
    fxd = fft(xd,nsamp);
    % Normalized the spectrum in order than one unity of
    % sinusoid in temporal domain egal one amplitud unity in
    % frequency domain
    allFFT(c,:) = 2*abs(fxd(1:nsamp/2))./nsamp; % Per row = per channel
end
 
  