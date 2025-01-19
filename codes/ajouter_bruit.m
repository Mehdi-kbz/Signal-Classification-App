function signal_avec_bruit = ajouter_bruit(RSB, signal)


    %%% Génération du bruit blanc %%%
    bruit = randn(size(signal));  
    longueur_bruit = length(bruit);        

    %%% Calcul des puissances %%%
    puissance_signal = sum(signal.^2) / length(signal);                            % Puissance du signal 
    puissance_bruit = puissance_signal / (10^(RSB / 10));                          % Puissance du bruit selon le RSB

    %%% Normalisation du bruit (multiplication élément par élément) %%%
    bruit = sqrt(puissance_bruit) .* bruit / sqrt(sum(bruit.^2) / longueur_bruit);

    %%% Ajout du bruit au signal original %%%
    signal_avec_bruit = signal + bruit;

end
