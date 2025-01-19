clc;
clear;
close all;

%% Chargement des fichiers audio
[signal_homme1, ~] = audioread('data/RAVDESS/meme_phrase_meme_emotion_sexes_differents/homme1.wav');
[signal_homme2, ~] = audioread('data/RAVDESS/meme_phrase_meme_emotion_sexes_differents/homme2.wav');
[signal_femme1, ~] = audioread('data/RAVDESS/meme_phrase_meme_emotion_sexes_differents/femme1.wav');
[signal_femme2, ~] = audioread('data/RAVDESS/meme_phrase_meme_emotion_sexes_differents/femme2.wav');

signaux = {signal_homme1, signal_homme2, signal_femme1, signal_femme2};
labels = {'Homme 1', 'Homme 2', 'Femme 1', 'Femme 2'};

min_length = min(cellfun(@length, signaux));
M = min_length; % Utiliser la totalité du plus court signal

% Tronquer tous les signaux à M
for i = 1:length(signaux)
    signaux{i} = signaux{i}(1:M);
end

% Ajout d'un très faible bruit
epsilon_noise = 1e-12;
for i = 1:length(signaux)
    signaux{i} = signaux{i} + epsilon_noise*randn(size(signaux{i}));
end

% Filtrage simple : garder zone plus énergétique
for i = 1:length(signaux)
    sig = signaux{i};
    energie = sig.^2;
    seuil = 0.05 * max(energie);
    idx = find(energie > seuil);
    if length(idx) > 200
        % Garder une portion plus énergétique
        start_idx = idx(1);
        end_idx = idx(end);
        len = end_idx - start_idx + 1;
        if len < M
            M = len; % Ajuster M si la portion est plus petite
        end
        signaux{i} = sig(start_idx:start_idx+M-1);
    else
        % Sinon on garde tout mais M reste min_length
        signaux{i} = sig(1:M);
    end
end

% Valeurs de N plus nombreuses et plus petites
N_values = [4, 8, 16, 32, 64];

% On ne garde que le degré 1
degree = 1;

% Normalisation pour éviter segments constants
for i = 1:length(signaux)
    sig = signaux{i};
    max_val = max(abs(sig))+eps;
    signaux{i} = sig / max_val;
end

hurst_results = zeros(length(signaux), 1); % Une seule colonne pour degré 1

%% Figure combinée
figure('Name', 'log(F2(N)) vs log(N) - Tous les signaux', 'NumberTitle', 'off');
hold on;

%% Application du DFA pour le degré 1
for signal_idx = 1:length(signaux)
    signal = signaux{signal_idx};

    % Mise à jour de M si nécessaire
    if length(signal) < M
        M = length(signal);
    end
    signal = signal(1:M);

    signal_centered = signal - mean(signal);
    profile = cumsum(signal_centered);

    F2_values = NaN(length(N_values), 1);

    for n_idx = 1:length(N_values)
        N = N_values(n_idx);
        L = floor(M / N);
        if L < 1
            continue;
        end

        F2_sum = 0;
        valid_segments = 0;

        for l = 1:L
            indices = (l-1)*N+1 : l*N;
            segment = profile(indices);
            k = (1:N)';

            if var(segment) < eps
                continue;
            end

            coeffs = polyfit(k, segment, degree);
            trend = polyval(coeffs, k);
            residu = segment - trend;

            if var(residu) < eps
                continue;
            end

            F2_sum = F2_sum + mean(residu.^2);
            valid_segments = valid_segments + 1;
        end

        if valid_segments > 0
            F2_values(n_idx) = F2_sum / valid_segments;
        end
    end

    valid_idx = ~isnan(F2_values);
    if sum(valid_idx) < 2
        % Pas assez de points, essayer d'ajuster encore N_values ou M
        hurst_results(signal_idx) = NaN;
        fprintf('Avertissement: Pas assez de points valides pour la régression pour %s\n', ...
            labels{signal_idx});
        continue;
    end

    log_F2 = log(F2_values(valid_idx));
    log_N = log(N_values(valid_idx));
    coeffs_reg = polyfit(log_N, log_F2, 1);
    alpha = coeffs_reg(1);
    hurst_exponent = alpha - 1;
    hurst_results(signal_idx) = hurst_exponent;

    % Tracé sur le graphe combiné
    plot(log_N, log_F2, 'o-', 'LineWidth', 1.5, ...
        'DisplayName', [labels{signal_idx}, ' (H=', num2str(hurst_exponent, '%.2f'), ')']);
end

xlabel('log(N)');
ylabel('log(F_2(N))');
title('Régression log-log pour les signaux vocaux H/F');
legend('show');
grid on;
hold off;

%% Résultats finaux
disp('Valeurs de Hurst estimées pour chaque acteur :');
disp(array2table(hurst_results, 'VariableNames', {'deg 1'}, 'RowNames', labels));
