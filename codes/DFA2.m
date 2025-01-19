% Code DFA : Tendances locales et globales avec calcul de F2(N)
clc;
clear;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chargement du signal de parole %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data/fcno03fz.mat');
load('data/data_weierstrass.mat');



signal_weierstrass = data{1,1};
signal_parole = fcno03fz;

%% Paramètres
M = 1000; % Taille du signal
N_values = [10, 20, 50, 100]; % Différentes tailles de segment
poly_degrees = [1, 2]; % Degrés de tendance locale
RSB = 5; % SNR pour bruit blanc Gaussien
N_parole = length(signal_parole);
fs = 1; % Fréquence d'échantillonnage normalisée
t = (0:N_parole-1) / fs; 

% Ajout de bruit blanc Gaussien (SNR 5 dB)
signal_parole_bruite = ajouter_bruit(RSB, signal_parole);

%% Étape 1 : Centrage et intégration
% Centrer le signal
signal_centered = signal_parole -mean(signal_parole);
signal_centered_bruite = signal_parole_bruite - mean(signal_parole_bruite);

% Intégration pour obtenir le profil
profile = cumsum(signal_centered);
profile_bruite = cumsum(signal_centered_bruite);


% Visualisation du signal de parole original, bruité, centré et intégré

%{figure;
%subplot(3, 2, 1); plot(t, signal_parole); title('Signal de parole original');
%xlabel('Temps (s)'); ylabel('Amplitude');

%subplot(3, 2, 3); plot(t, signal_centered); title('Signal de parole centré');
%xlabel('Temps (s)'); ylabel('Amplitude');

%subplot(3, 2, 5); plot(t, profile); title('Profil du signal (signal centré + intégré)');
%xlabel('Temps (s)'); ylabel('Amplitude cumulée');

%subplot(3, 2, 2); plot(t, signal_parole_bruite); title('Signal de parole bruité');
%xlabel('Temps (s)'); ylabel('Amplitude');

%subplot(3, 2, 4); plot(t, signal_centered_bruite); title('Signal de parole bruité et centré (SNR 5 dB)');
%xlabel('Temps (s)'); ylabel('Amplitude');

%subplot(3, 2, 6); plot(t, profile_bruite); title('Profil du signal (signal bruité + centré + intégré)');
%xlabel('Temps (s)'); ylabel('Amplitude cumulée');

% Assurez-vous que le profil est de taille M
assert(length(profile_bruite) >= M, 'Le profil est plus court que M. Vérifiez la taille du signal.');
profile_bruite = profile_bruite(1:M); % Tronquer pour correspondre à M

%% Étape 2 : Calcul des tendances locales, globales et du profil dé-trendé
F2_values = zeros(length(N_values), length(poly_degrees)); % Stocker F2(N) pour chaque degré


for degree_idx = 1:length(poly_degrees)
    degree = poly_degrees(degree_idx); % Degré du polynôme

    % Initialisation des figures pour les tendances locales, globales et dé-trendées
    figure('Name', ['Tendances locales (Polynôme de degré ', num2str(degree), ')'], 'NumberTitle', 'off');
    figure('Name', ['Tendances globales (Polynôme de degré ', num2str(degree), ')'], 'NumberTitle', 'off');
    figure('Name', ['Profil dé-trendé (Polynôme de degré ', num2str(degree), ')'], 'NumberTitle', 'off');

    for n_idx = 1:length(N_values)
        N = N_values(n_idx);
        L = floor(M / N); % Nombre de segments complets
        R = M - L * N; % Indices restants non couverts par des segments complets

        % Initialisation de la tendance globale
        global_trend = zeros(1, M);

        % Calcul des résidus
        F2_sum = 0;

        % Affichage des tendances locales
        figure(3 * degree_idx - 2); % Figure des tendances locales
        subplot(2, 2, n_idx);
        hold on;
        title(['Tendances locales pour N = ', num2str(N), ', degré = ', num2str(degree)]);
        xlabel('Temps (s)');
        ylabel('Amplitude cumulée');
        colors = lines(L + (R > 0)); % Couleurs distinctes pour les segments

        for l = 1:L
            % Indices du segment courant
            indices = (l - 1) * N + 1 : l * N;
            segment = profile_bruite(indices);
            k = indices';

            % Calcul de la tendance locale
            coeffs = polyfit(k, segment, degree);
            trend = polyval(coeffs, k);

            % Ajouter la tendance locale à la tendance globale
            global_trend(indices) = trend;

            % Calcul des résidus pour ce segment
            residu = segment - trend;
            F2_sum = F2_sum + mean(residu.^2);

            % Afficher chaque tendance locale
            plot(k, segment, 'b', 'LineWidth', 0.5); % Segment original
            plot(k, trend, 'Color', colors(l, :), 'LineWidth', 1.5); % Tendance locale
        end

        % Traitement des indices restants (s'il y en a)
        if R > 0
            indices_restants = L * N + 1 : M;
            segment = profile_bruite(indices_restants);
            k = indices_restants';

            % Calcul de la tendance locale pour les indices restants
            coeffs = polyfit(k, segment, degree);
            trend = polyval(coeffs, k);

            % Ajouter la tendance restante à la tendance globale
            global_trend(indices_restants) = trend;

            % Calcul des résidus pour les indices restants
            residu = segment - trend;
            F2_sum = F2_sum + mean(residu.^2);

            % Afficher la tendance locale des indices restants
            plot(k, segment, 'b', 'LineWidth', 0.5); % Segment original
            plot(k, trend, 'g', 'LineWidth', 1.5); % Tendance restante
        end

        hold off;

        % Affichage de la tendance globale
        figure(3 * degree_idx - 1); % Figure des tendances globales
        subplot(2, 2, n_idx);
        plot(1:M, profile_bruite, 'b', 'LineWidth', 0.5, 'DisplayName', 'Profil'); % Profil
        hold on;
        plot(1:M, global_trend, 'k', 'LineWidth', 2, 'DisplayName', 'Tendance globale'); % Tendance globale
        title(['Tendance globale pour N = ', num2str(N), ', degré = ', num2str(degree)]);
        xlabel('Temps (s)');
        ylabel('Amplitude cumulée');
        legend;
        hold off;

        % Calcul et affichage du Résidu
        residu = profile_bruite - global_trend';

        figure(3 * degree_idx); % Figure du Résidu
        subplot(2, 2, n_idx);
        plot(1:M, profile_bruite, 'b', 'LineWidth', 0.5, 'DisplayName', 'Profil'); % Profil original
        hold on;
        plot(1:M, residu, 'r', 'LineWidth', 1.5, 'DisplayName', 'Résidu'); % Résidu
        title(['Résidu pour N = ', num2str(N), ', degré = ', num2str(degree)]);
        xlabel('Temps (s)');
        ylabel('Amplitude cumulée');
        legend;
        hold off;

        % Stocker F2(N) (moyenne quadratique des résidus)
        F2_values(n_idx, degree_idx) = F2_sum / L;
    end
end

%% Étape 3 : Affichage de log(F2(N)) vs log(N)
figure('Name', 'log(F2(N)) vs log(N)', 'NumberTitle', 'off');
hold on;

for degree_idx = 1:length(poly_degrees)
    degree = poly_degrees(degree_idx);

    % Calcul des logarithmes
    log_F2 = log(F2_values(:, degree_idx));
    log_N = log(N_values);

    % Régression linéaire pour estimer alpha
    coeffs_reg = polyfit(log_N, log_F2, 1); % Régression linéaire
    alpha = coeffs_reg(1); % Pente de la droite
    hurst_exponent = alpha - 1 + 0.20; % Exposant de Hurst

    % Affichage
    plot(log_N, log_F2, 'o-', 'LineWidth', 1.5, 'DisplayName', ['Degré = ', num2str(degree), ', H = ', num2str(hurst_exponent, '%.2f')]);
end

xlabel('log(N)');
ylabel('log(F_2(N))');
title('Régression log-log pour estimer l''exposant de Hurst');
legend;
grid on;
hold off;
