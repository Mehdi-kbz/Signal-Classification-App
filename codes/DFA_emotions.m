clc;
clear;
close all;

%% Paramètres
M = 10000; % Longueur du signal. Ajustez selon la durée disponible.
% On utilise une progression logarithmique pour couvrir un large éventail de N
N_values = unique(round(logspace(log10(4), log10(M/4), 10))); 
poly_degrees = [1, 2]; % Degrés de tendance locale

%% Chargement des signaux vocaux
[signal_angry, fs_angry] = audioread('data/RAVDESS/meme_acteur_meme_phrase_emotions_differentes/angry.wav');
[signal_happy, fs_happy] = audioread('data/RAVDESS/meme_acteur_meme_phrase_emotions_differentes/happy.wav');
[signal_sad, fs_sad] = audioread('data/RAVDESS/meme_acteur_meme_phrase_emotions_differentes/sad.wav');

% Vérifier la taille minimale parmi les signaux
min_length = min([length(signal_angry), length(signal_happy), length(signal_sad)]);

% Ajustez les signaux à la taille minimale ou M
if min_length < M
    warning('Les signaux sont plus courts que %d échantillons. Tronquage à %d échantillons.', M, min_length);
    M = min_length;
end

signal_angry = signal_angry(1:M);
signal_happy = signal_happy(1:M);
signal_sad   = signal_sad(1:M);

% Normalisation pour éviter les segments constants
signal_angry = signal_angry / max(abs(signal_angry) + eps);
signal_happy = signal_happy / max(abs(signal_happy) + eps);
signal_sad   = signal_sad   / max(abs(signal_sad) + eps);

% Liste des signaux et étiquettes
signaux = {signal_angry, signal_happy, signal_sad};
labels = {'Angry', 'Happy', 'Sad'};
hurst_results = zeros(length(signaux), length(poly_degrees));

% Initialisation pour le graphe combiné
figure('Name', 'log(F2(N)) vs log(N) - Tous les signaux', 'NumberTitle', 'off');
hold on;

%% Application de la méthode DFA
for signal_idx = 1:length(signaux)
    signal = signaux{signal_idx};

    % Centrage et intégration
    signal_centered = signal - mean(signal);
    profile = cumsum(signal_centered);

    % Calcul des F2(N) pour chaque degré
    F2_values = zeros(length(N_values), length(poly_degrees));
    F2_values(:) = NaN; % Initialisation à NaN

    for degree_idx = 1:length(poly_degrees)
        degree = poly_degrees(degree_idx);

        for n_idx = 1:length(N_values)
            N = N_values(n_idx);
            L = floor(M / N); % Nombre de segments complets

            if L < 1
                % Si pas assez de données pour un certain N
                continue;
            end

            F2_sum = 0;
            valid_segments = 0;

            for l = 1:L
                indices = (l-1)*N+1 : l*N;
                segment = profile(indices);
                k = (1:N)';

                % Vérifiez la variance du segment
                seg_var = var(segment);
                if seg_var < eps
                    % Segment quasi constant, on l'ignore
                    continue;
                end

                % Ajustement de la tendance locale
                coeffs = polyfit(k, segment, degree);
                trend = polyval(coeffs, k);
                residu = segment - trend;

                % Ajout de la fluctuation quadratique
                F2_sum = F2_sum + mean(residu.^2);
                valid_segments = valid_segments + 1;
            end

            % Si aucun segment valide n'est trouvé pour ce N, on laisse F2(N) = NaN
            if valid_segments > 0
                F2_values(n_idx, degree_idx) = F2_sum / valid_segments;
            end
        end

        % Régression log-log pour estimer H
        valid_idx = ~isnan(F2_values(:, degree_idx));
        if sum(valid_idx) < 2
            % Pas assez de points pour la régression
            hurst_results(signal_idx, degree_idx) = NaN;
            fprintf('Avertissement: Pas assez de points valides pour la régression pour %s (Degré %d).\n', ...
                labels{signal_idx}, degree);
            continue;
        end

        log_F2 = log(F2_values(valid_idx, degree_idx));
        log_N = log(N_values(valid_idx));

        coeffs_reg = polyfit(log_N, log_F2, 1);
        alpha = coeffs_reg(1);
        hurst_exponent = alpha - 1;
        hurst_results(signal_idx, degree_idx) = hurst_exponent;

        % Ajout du tracé sur le graphe combiné
        plot(log_N, log_F2, 'o-', 'LineWidth', 1.5, ...
            'DisplayName', [labels{signal_idx}, ' (Degré ', num2str(degree), ')']);
    end
end

% Configuration du graphe combiné
xlabel('log(N)');
ylabel('log(F_2(N))');
title('Régression log-log pour tous les signaux');
legend show;
grid on;
hold off;

%% Résultats finaux
disp('Valeurs de Hurst estimées pour chaque émotion et degré :');
disp(array2table(hurst_results, 'VariableNames', {'Degre_1', 'Degre_2'}, 'RowNames', labels));
