function [P] = Periodogramme_Bartlett(x, M)
    
    %%% Taille des segments %%%
    L = floor(length(x) / M);               % Nombre de segments
    spectre_puissance = zeros(L, M); 

    %%% Calcul de la FFT pour chaque segment du signal %%%
    for k = 1:L
        segment = x((k - 1) * M + 1 : k * M);               % Extraction du segment
        segment_fft = fft(segment);    
        spectre_puissance(k, :) = abs(segment_fft).^2 / M;  % Calcul de la puissance
    end

    %%% Moyenne de la puissance sur tous les segments %%%
    P = mean(spectre_puissance, 1);
end
