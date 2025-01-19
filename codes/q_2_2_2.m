clear ; 
close all ; 
clc ; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
N_points = 10000;                        % Nombre de points du signal                                 %
variance_bruit = 1;                      % Variance du bruit blanc                                    %
ordre_Daniell = 4;                       % Ordre de la moyenne pondérée dans la méthode de Daniell    %
                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Génération du Bruit Blanc Gaussien %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
bruit_blanc = randn(1, N_points) * sqrt(variance_bruit);                                              %
                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fonctions d'autocorrélation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
taux = floor((N_points-1) / 2);           % Décalage pour l'autocorrélation                           %
                                                                                                      %
autocorrelation_theorique = variance_bruit * [zeros(1, taux), 1, zeros(1, taux)];                     %
autocorrelation_estimee = xcorr(bruit_blanc, 'coeff');                                                %
                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Spectres de puissance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
spectre_puissance_theorique = ones(1, N_points) * variance_bruit;     % Spectre théorique             %
spectre_puissance_estime = abs(fft(bruit_blanc)).^2 / N_points;       % Spectre estimé                %
                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Application des méthodes de calcul du spectre %%%%%%%%%%%%%%%%%%%%%%%%%%%
[DSP_welch] = Periodogramme_Welch(bruit_blanc, N_points);
[DSP_bartlett] = Periodogramme_Bartlett(bruit_blanc, N_points);
[DSP_daniell] = Periodogramme_Daniell(bruit_blanc, N_points, ordre_Daniell);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracés %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Calcul de l'intervalle pour centrer le spectre théorique %%%
valeur_max = max([max(DSP_welch), max(DSP_bartlett), max(DSP_daniell)]); % Recherche de v_max parmi les estimations
plage = max(abs([min(DSP_welch), min(DSP_bartlett), min(DSP_daniell), valeur_max]));

%%% Tracé du Périodogramme de Daniell %%%
figure;
subplot(3, 1, 1);
plot(DSP_daniell, 'm');
hold on;
plot(spectre_puissance_theorique(1:min(length(DSP_daniell), length(spectre_puissance_theorique))) + valeur_max - plage, '-g');
title('Comparaison : Périodogramme de Daniell et DSP Théorique');
legend('DSP de Daniell', 'DSP Théorique');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');

%%% Tracé du Périodogramme de Bartlett %%%
subplot(3, 1, 2);
plot(DSP_bartlett, 'y');
hold on;
plot(spectre_puissance_theorique(1:min(length(DSP_bartlett), length(spectre_puissance_theorique))) + valeur_max - plage, '-g');
title('Comparaison : Périodogramme de Bartlett et DSP Théorique');
legend('DSP de Bartlett', 'DSP Théorique');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');

%%% Tracé du Périodogramme de Welch %%%
subplot(3, 1, 3);
plot(DSP_welch, 'b');
hold on;
plot(spectre_puissance_theorique(1:min(length(DSP_welch), length(spectre_puissance_theorique))) + valeur_max - plage, '-g');
title('Comparaison : Périodogramme de Welch et DSP Théorique');
legend('DSP de Welch', 'DSP Théorique');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');
