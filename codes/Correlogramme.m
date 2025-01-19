function [DSP] = Correlogramme(signal)
    % Calcul de l'autocorrélation biaisée du signal
    autocorr_signal = xcorr(signal, 'biased');
    
    % Calcul du spectre de puissance en appliquant la FFT sur l'autocorrélation
    DSP = fft(autocorr_signal);
end
