clear ; 
close all ; 
clc ; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Paramètres %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                      %
N_points = 10000;                        % Nombre de points du signal                                 %
variance_bruit = 1;                      % Variance du bruit blanc                                    %
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracés %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Fonction d'autocorrélation estimée %%%
figure;
subplot(2, 1, 1);
stem(-N_points+1:N_points-1, autocorrelation_estimee, 'r','LineWidth', 1);
title("Fonction d'autocorrélation estimée du Bruit Blanc");
xlabel('Décalage temporel (\tau)', 'Interpreter', 'tex');
ylabel('Amplitude');
grid on;

%%% Fonction d'autocorrélation théorique %%%
subplot(2, 1, 2);
stem(-taux:taux, autocorrelation_theorique, 'LineWidth', 1);
title("Fonction d'autocorrélation théorique du Bruit Blanc");
xlabel('Décalage temporel (\tau)', 'Interpreter', 'tex');
ylabel('Amplitude');
grid on;

%%% Tracé des spectres de puissance %%%
figure;

subplot(2, 1, 1);
plot(spectre_puissance_estime, 'r', 'LineWidth', 1);
title('Spectre de puissance estimé du Bruit Blanc');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');
grid on;

subplot(2, 1, 2);
plot(spectre_puissance_theorique, 'b', 'LineWidth', 1);
title('Spectre de puissance théorique du Bruit Blanc');
xlabel('Fréquence (Hz)');
ylabel('Puissance (W)');
grid on;
