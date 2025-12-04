%% Programme principal du projet "Chi_Fou_Mi"
%----------------------------------------

clear
clc
close all

% Chargement du réseau pré-entraîné
load('trainedGN.mat');

% Définition de la fréquence d'échantillonnage
Fe = 408;

%% 1- Liaison Arduino -> Matlab pour la lecture des EMGs
disp('Prêt à capturer le signal EMG...');
disp('Préparez votre mouvement... 2sec');
[emg, ~, s1] = Mes_EMG();
disp('ACQUISITION TERMINÉE!');

%% 2- Transformation des EMGs en Image "scalogramme"
disp('Création du scalogramme...');
Creat_Mon_Image(emg, Fe);
disp('Scalogramme créé et sauvegardé comme "Mon_Image.jpg"');

%% 3- Utilisation de notre réseau pour la prise de décision : commande
disp('Classification du mouvement...');
a = Mon_DL(trainedGN);
disp(['Mouvement détecté: ', num2str(a)]);

%% 4- Liaison Matlab -> Arduino pour l'envoi de la commande
disp('Envoi de la commande à la prothèse...');
Commande_Prothese(a);
disp('Commande envoyée avec succès!');
