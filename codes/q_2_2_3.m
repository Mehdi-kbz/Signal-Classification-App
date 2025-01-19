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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Spectres de puissance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
spectre_puissance_theorique = ones(1, N_points) * variance_bruit;     % Spectre théorique             %
spectre_puissance_estime = abs(fft(bruit_blanc)).^2 / N_points;       % Spectre estimé                %
                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Calcul du corrélogramme %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
[DSP] = Correlogramme(bruit_blanc);                                                                   %
                                                                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracés comparatifs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;

%%% Tracé du corrélogramme %%%
subplot(3, 1, 1); 
plot(abs(DSP), 'k', 'LineWidth', 1.5);
title('Corrélogramme');
xlabel('Décalage temporel (\tau)', 'Interpreter', 'tex');
ylabel('Corrélation');
grid on;

%%% Tracé du spectre de puissance estimé %%%
subplot(3, 1, 2);
plot(spectre_puissance_estime, 'm', 'LineWidth', 1.5);
title('Spectre de Puissance Estimé du Bruit Blanc');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');
grid on;

%%% Tracé du spectre de puissance théorique %%%
subplot(3, 1, 3);
plot(spectre_puissance_theorique, 'b', 'LineWidth', 1.5);
title('Spectre de Puissance Théorique du Bruit Blanc');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');
grid on;

% Ajustement de la figure
sgtitle('Comparaison du Corrélogramme avec le Spectre de Puissance et la DSP');
