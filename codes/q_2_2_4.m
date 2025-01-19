clear;
close all;
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chargement du signal de Weierstrass %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data/data_weierstrass.mat');
signal_weierstrass = data{1,1};  % extraire la variable du fichier
  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chargement du signal de parole %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('data/fcno03fz.mat');
signal_parole = fcno03fz; 

  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Traitement des signaux  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RSB_values = [5, 10, 15]; %%% Définition des niveaux de RSB à tester %%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Tracés %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;

for i = 1:length(RSB_values)
    RSB = RSB_values(i);  
    
    %%% Ajout de bruit au signal de Weierstrass %%%
    signal_bruite = ajouter_bruit(RSB, signal_weierstrass);
    
    %%% Tracé du signal original et du signal bruité %%%
    subplot(length(RSB_values), 1, i);
    plot(signal_bruite, 'r', 'LineWidth', 1, DisplayName='Signal bruité');        % Signal bruité
    hold on;
    plot(signal_weierstrass, 'b', 'LineWidth', 1, DisplayName='Signal original'); % Signal original
    
    %%% Ajustements du graphe %%%
    title(['\color{blue} Signal de Weierstrass' '\color{red} bruité avec RSB = ', num2str(RSB), ' dB']);
    xlabel('Échantillons');
    ylabel('Amplitude');
    grid on; 
end

figure;

for i = 1:length(RSB_values)
    RSB = RSB_values(i);  
    
    %%% Ajout de bruit au signal de parole %%%
    signal_parole_bruite = ajouter_bruit(RSB, signal_parole);
    
    %%% Tracé du signal original et du signal bruité %%%
    subplot(length(RSB_values), 1, i);
    plot(signal_parole_bruite, 'r', 'LineWidth', 1, DisplayName='Signal bruité');      % Signal bruité
    hold on;
    plot(signal_parole, 'b', 'LineWidth', 1, DisplayName='Signal original');           % Signal original
    
    %%% Ajustements du graphe %%%
    title(['\color{blue} Signal de parole' '\color{red} bruité avec RSB = ', num2str(RSB), ' dB']);
    xlabel('Échantillons');
    ylabel('Amplitude');
    grid on;    
end
