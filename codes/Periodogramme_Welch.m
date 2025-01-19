function [DSP] = Periodogramme_Welch(signal, N_fft)
    
    %%% Paramètres pour la méthode de Welch %%%
    taille_fenetre = 1000;                  % Taille de la fenêtre
    nb_segments = N_fft / taille_fenetre;   % Nombre de segments

    spectres = [];                  % Initialisation de la matrice pour stocker les spectres
    K = taille_fenetre / 2;         % Recouvrement de la fenêtre

    for i = 1:2 * nb_segments - 1
        %%% Calcul de la FFT pour chaque segment %%%
        segment_fft = fft(signal(K * (i - 1) + 1 : K * (i - 1) + taille_fenetre));
        spectres = [spectres; abs(segment_fft).^2 / taille_fenetre];                % Spectre normalisé
    end

    %%% Calcul de la moyenne des spectres %%%
    DSP = mean(spectres); 
end
