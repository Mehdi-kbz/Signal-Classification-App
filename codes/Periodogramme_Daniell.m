function [DSP] = Periodogramme_Daniell(signal, N_fft, taille_daniell)
    
    %%% Calcul de la FFT du signal et du spectre de puissance %%%
    signal_fft = fft(signal, N_fft);
    spectre_puissance = (abs(signal_fft).^2) / N_fft;
    
    %%% Division du spectre en segments de taille spécifiée et calcul de la moyenne %%%
    nb_segments = length(spectre_puissance) / taille_daniell;
    puissance_daniell = zeros(1, nb_segments);

    for k = 1:nb_segments
        segment = spectre_puissance((k - 1) * taille_daniell + 1 : k * taille_daniell);
        puissance_daniell(k) = mean(segment);
    end

    %%% Retourne le spectre de puissance lissé avec le filtre Daniell %%%
    DSP = puissance_daniell;
end
