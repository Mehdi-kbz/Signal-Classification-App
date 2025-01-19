clear;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chargement du signal de Weierstrass %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data/data_weierstrass.mat');
signal_weierstrass = data{1,1};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chargement du signal de parole %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data/fcno03fz.mat');
signal_parole = fcno03fz;


%%% Paramètres du signal et du bruit %%%
fs = 1;  % Fréquence d'échantillonnage normalisée
RSB = 10;           

%%% Ajout de bruit aux signaux %%%
signal_weierstrass_bruite = ajouter_bruit(RSB, signal_weierstrass);
signal_parole_bruite = ajouter_bruit(RSB, signal_parole);

%%% Temps associé à chaque échantillon %%%
N_weierstrass = length(signal_weierstrass);
N_parole = length(signal_parole);
t_weierstrass = (0:N_weierstrass-1) / fs;  
t_parole = (0:N_parole-1) / fs; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Signal de Weierstrass %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;

% Représentation temporelle du signal de Weierstrass
subplot(2, 1, 1);
plot(t_weierstrass, signal_weierstrass, 'b', 'LineWidth', 1);
title('Représentation temporelle du signal de Weierstrass');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Spectrogramme du signal de Weierstrass
subplot(2, 1, 2);
spectrogram(signal_weierstrass(:), 128, 120, 128, fs, 'yaxis');  % Spectrogramme avec fréquences normalisées
title('Spectrogramme du signal de Weierstrass');
xlabel('Temps (s)');
ylabel('Fréquence normalisée');
grid on;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Signal de Weierstrass bruité %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;

% Représentation temporelle du signal bruité
subplot(2, 1, 1);
plot(t_weierstrass, signal_weierstrass_bruite, 'r', 'LineWidth', 1);
title(['Représentation temporelle du signal de Weierstrass bruité (RSB = ', num2str(RSB), ' dB)']);
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Spectrogramme du signal bruité
subplot(2, 1, 2);
spectrogram(signal_weierstrass_bruite(:), 128, 120, 128, fs, 'yaxis');  % Spectrogramme avec fréquences normalisées
title('Spectrogramme du signal de Weierstrass bruité');
xlabel('Temps (s)');
ylabel('Fréquence normalisée');
grid on;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Signal de Parole %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;

% Représentation temporelle du signal de parole
subplot(2, 1, 1);
plot(t_parole, signal_parole, 'b', 'LineWidth', 1);
title('Représentation temporelle du signal de parole');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Spectrogramme du signal de parole
subplot(2, 1, 2);
spectrogram(signal_parole(:), 128, 120, 128, fs, 'yaxis');  % Spectrogramme avec fréquences normalisées
title('Spectrogramme du signal de parole');
xlabel('Temps (s)');
ylabel('Fréquence normalisée');
grid on;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Signal de parole bruité %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure;

% Représentation temporelle du signal de parole bruité
subplot(2, 1, 1);
plot(t_parole, signal_parole_bruite, 'r', 'LineWidth', 1);
title(['Représentation temporelle du signal de parole bruité (RSB = ', num2str(RSB), ' dB)']);
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;

% Spectrogramme du signal de parole bruité
subplot(2, 1, 2);
spectrogram(signal_parole_bruite(:), 128, 120, 128, fs, 'yaxis');  % Spectrogramme avec fréquences normalisées
title('Spectrogramme du signal de parole bruité');
xlabel('Temps (s)');
ylabel('Fréquence normalisée');
grid on;