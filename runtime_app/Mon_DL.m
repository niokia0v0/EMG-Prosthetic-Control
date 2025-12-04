function a = Mon_DL(trainedGN)
    %% Fonction pour classifier une image avec le réseau pré-entraîné
    % Paramètres:
    %   trainedGN - Réseau de neurones pré-entraîné
    % Retourne:
    %   a - Numéro du mouvement reconnu (1, 2 ou 3)
    
    % Lecture de l'image du scalogramme
    img = imread('Mon_Image.jpg');
    
    % Redimensionnement de l'image pour le réseau (224x224)
    img = imresize(img, [224 224]);
    
    % % Vérification que l'image est en RGB
    % if size(img, 3) == 1
    %     img = repmat(img, [1, 1, 3]);
    % end
    
    % Classification avec le réseau pré-entraîné
    [label, ~] = classify(trainedGN, img);
    
    % Conversion du label en numéro de mouvement
    categoryStr = char(label);
    
    % Détermination du mouvement (ajuster selon vos catégories)
    if strcmp(categoryStr, 'Mvt1') || str2double(categoryStr) == 1
        a = 1;
    elseif strcmp(categoryStr, 'Mvt2') || str2double(categoryStr) == 2
        a = 2;
    elseif strcmp(categoryStr, 'Mvt3') || str2double(categoryStr) == 3
        a = 3;
    else
        % Tentative de conversion directe si le label est numérique
        try
            a = str2double(categoryStr);
            if isnan(a) || a < 1 || a > 3
                a = 1; % Valeur par défaut
                warning('Label non reconnu, utilisation de la valeur par défaut 1');
            end
        catch
            a = 1; % Valeur par défaut
            warning('Label non reconnu, utilisation de la valeur par défaut 1');
        end
    end
end
