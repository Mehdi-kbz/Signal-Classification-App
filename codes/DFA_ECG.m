clc;
clear;
close all;

%% Chargement des fichiers audio ECG
[ecg_normal, fs_normal] = audioread('DATA/ECG/normal.wav'); % Signal normal
[ecg_pathological, fs_pathological] = audioread('DATA/ECG/arythmie.wav'); % Signal avec arythmie

% Ajustez les signaux à la même longueur
min_length = min(length(ecg_normal), length(ecg_pathological));
ecg_normal = ecg_normal(1:min_length);
ecg_pathological = ecg_pathological(1:min_length);

% Normalisation des signaux
ecg_normal = ecg_normal / max(abs(ecg_normal));
ecg_pathological = ecg_pathological / max(abs(ecg_pathological));

% Ajout d'un très faible bruit pour éviter des segments constants
epsilon_noise = 1e-12;
ecg_normal = ecg_normal + epsilon_noise * randn(size(ecg_normal));
ecg_pathological = ecg_pathological + epsilon_noise * randn(size(ecg_pathological));

%% Liste des signaux et étiquettes
signals = {ecg_normal, ecg_pathological};
labels = {'Normal', 'Arythmie'};

%% Affichage des signaux ECG avec fond noir
figure('Name', 'Signaux ECG', 'NumberTitle', 'off');

% Signal normal
subplot(2, 1, 1);
plot(ecg_normal, 'b');
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w'); % Fond noir pour l'axe
set(gcf, 'Color', 'k'); % Fond noir pour la figure
title('Signal ECG - Normal', 'Color', 'w');
xlabel('Temps (échantillons)', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
grid on;

% Signal pathologique
subplot(2, 1, 2);
plot(ecg_pathological, 'r');
set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'GridColor', 'w'); % Fond noir pour l'axe
set(gcf, 'Color', 'k'); % Fond noir pour la figure
title('Signal ECG - Arythmie', 'Color', 'w');
xlabel('Temps (échantillons)', 'Color', 'w');
ylabel('Amplitude', 'Color', 'w');
grid on;


%% Paramètres DFA
M = length(ecg_normal); % Longueur des signaux
N_values = [10, 20, 50, 100]; % Tailles des segments pour DFA
hurst_results = zeros(length(signals), 1); % Stockage des résultats

%% DFA et affichage des courbes log-log
figure('Name', 'log(F2(N)) vs log(N) - Tous les signaux', 'NumberTitle', 'off');
hold on;

for signal_idx = 1:length(signals)
    signal = signals{signal_idx};
    
    % Centrage et intégration
    signal_centered = signal - mean(signal);
    profile = cumsum(signal_centered);

    % Calcul des fluctuations F2(N)
    F2_values = zeros(length(N_values), 1);
    for n_idx = 1:length(N_values)
        N = N_values(n_idx);
        L = floor(M / N);
        if L < 1, continue; end

        F2_sum = 0;
        for l = 1:L
            segment = profile((l-1)*N+1 : l*N);
            k = (1:N)';
            trend = polyfit(k, segment, 1); % Ajustement linéaire
            residu = segment - polyval(trend, k);
            F2_sum = F2_sum + mean(residu.^2);
        end
        F2_values(n_idx) = F2_sum / L;
    end

    % Régression log-log pour estimer H
    log_N = log(N_values);
    log_F2 = log(F2_values);
    coeffs = polyfit(log_N, log_F2, 1);
    alpha = coeffs(1);
    hurst_results(signal_idx) = alpha - 1;

    
    % Tracé des courbes log-log
    plot(log_N, log_F2, 'o-', 'LineWidth', 1.5, ...
        'DisplayName', [labels{signal_idx}, ', H=', num2str(hurst_results(signal_idx), '%.2f')]);
end

xlabel('log(N)');
ylabel('log(F_2(N))');
title('Régression log-log pour les signaux ECG');
legend('show');
grid on;
hold off;

%% Résultats finaux
disp('Valeurs de Hurst estimées pour les signaux ECG :');
disp(array2table(hurst_results, 'VariableNames', {'Hurst'}, 'RowNames', labels));
