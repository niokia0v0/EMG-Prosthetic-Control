%% Script pour l'entraînement du réseau de neurones avec transfer learning
% Ce script utilise les scalogrammes générés pour entraîner un réseau de neurones 
% par transfer learning afin de classifier les mouvements

% Chemin du répertoire des données
Data_Rep = "MaBdD";  % Ajustez ce chemin si nécessaire

% 1- Chargement des images avec leurs labels
disp('Chargement des images...');
MesImages = imageDatastore(Data_Rep, 'IncludeSubfolders', true, 'FileExtensions', '.jpg', 'LabelSource', 'foldernames');

% Affichage du nombre d'images par catégorie
labelCount = countEachLabel(MesImages);
disp('Nombre d''images par catégorie:');
disp(labelCount);

% 2- Division des images en 2 catégories : entrainement (80%) et test (20%)
disp('Division des données en ensembles d''entraînement et de validation...');
rng default  % Pour la reproductibilité
[imgsTrain, imgsValidation] = splitEachLabel(MesImages, 0.8, 'randomized');
disp(['Nombre d''images d''entraînement: ', num2str(numel(imgsTrain.Files))]);
disp(['Nombre d''images de validation: ', num2str(numel(imgsValidation.Files))]);

% Récupération des labels de validation pour la matrice de confusion
YTrue = imgsValidation.Labels;

% 3- Chargement du réseau pré-entraîné GoogLeNet
disp('Chargement du réseau pré-entraîné GoogLeNet...');
net = googlenet;

% Affichage du graphe des différentes couches du réseau
lgraph = layerGraph(net);
numberOfLayers = numel(lgraph.Layers);
figure('Units', 'normalized', 'Position', [0.1 0.1 0.8 0.8]);
plot(lgraph);
title(['GoogLeNet Layer Graph: ', num2str(numberOfLayers), ' Layers']);

% Modification de la probabilité de la couche finale du réseau
disp('Modification des couches du réseau pour notre application...');
newDropoutLayer = dropoutLayer(0.6, 'Name', 'new_Dropout');
lgraph = replaceLayer(lgraph, 'pool5-drop_7x7_s1', newDropoutLayer);

% 4- Modification de la dernière couche et de la classification finale
numClasses = numel(categories(imgsTrain.Labels));
newConnectedLayer = fullyConnectedLayer(numClasses, 'Name', 'new_fc', ...
    'WeightLearnRateFactor', 5, 'BiasLearnRateFactor', 5);
lgraph = replaceLayer(lgraph, 'loss3-classifier', newConnectedLayer);

% Remplacement de la couche de classification
newClassLayer = classificationLayer('Name', 'new_classoutput');
lgraph = replaceLayer(lgraph, 'output', newClassLayer);

% Redimensionnement des images pour correspondre à notre réseau
imagesize = [224 224 3];  % GoogLeNet attend des images RGB 224x224
disp('Redimensionnement des images pour le réseau...');

% Vérification si les images sont en niveaux de gris et conversion en RGB si nécessaire
imgInfo = imfinfo(imgsTrain.Files{1});
if imgInfo.BitDepth == 8  % Image en niveaux de gris
    disp('Conversion des images en niveaux de gris vers RGB...');
    
    % Fonction pour convertir une image en niveaux de gris en RGB
    rgbConverter = @(img) repmat(img, [1, 1, 3]);
    
    % Création de datastores augmentés avec conversion
    imgsTrain = augmentedImageDatastore(imagesize, imgsTrain, 'ColorPreprocessing', 'gray2rgb');
    imgsValidation = augmentedImageDatastore(imagesize, imgsValidation, 'ColorPreprocessing', 'gray2rgb');
else
    % Si déjà en RGB, juste redimensionner
    imgsTrain = augmentedImageDatastore(imagesize, imgsTrain);
    imgsValidation = augmentedImageDatastore(imagesize, imgsValidation);
end

% 5- Entraînement du réseau sur nos données
disp('Configuration des options d''entraînement...');
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 15, ...
    'MaxEpochs', 30, ...
    'InitialLearnRate', 1e-4, ...
    'ValidationData', imgsValidation, ...
    'ValidationFrequency', 10, ...
    'Verbose', 1, ...
    'ExecutionEnvironment', 'auto', ...  % 'auto' pour utiliser GPU si disponible
    'Plots', 'training-progress');

% Entraînement du réseau
disp('Début de l''entraînement du réseau...');
rng default
trainedGN = trainNetwork(imgsTrain, lgraph, options);

% Vérification de la dernière couche
disp('Vérification de la dernière couche du réseau:');
disp(trainedGN.Layers(end));

% Validation : évaluation du réseau avec les images de test
disp('Évaluation du réseau sur les données de validation...');
[YPred, probs] = classify(trainedGN, imgsValidation);

% Calcul de la précision
accuracy = sum(YPred == YTrue) / numel(YTrue);
disp(['Précision du modèle: ', num2str(accuracy * 100), '%']);

% Matrice de confusion pour observer le résultat de la validation
figure;
cm = confusionchart(YTrue, YPred);
cm.Title = 'Matrice de Confusion - Classification des Mouvements';
cm.RowSummary = 'row-normalized';
cm.ColumnSummary = 'column-normalized';

% Sauvegarde du réseau entraîné
disp('Sauvegarde du réseau entraîné...');
save trainedGN trainedGN

disp('Entraînement et évaluation terminés.');
