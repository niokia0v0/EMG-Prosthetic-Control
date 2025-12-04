function [emg, Fe, s1] = Mes_EMG()
    %% Fonction pour mesurer les signaux EMG via Arduino
    % Retourne:
    %   emg - Signal EMG mesuré
    %   Fe - Fréquence d'échantillonnage
    %   s1 - Objet de connexion série
    
    if (~isempty(instrfind))
        fclose(instrfind);
    end
    
    % Configuration du port série
    s1 = serial('COM3', 'Baudrate', 115200);  % Port COM à vérifier !
    fopen(s1);
    flushinput(s1);
    
    % Initialisation des variables
    accX = [];
    formatSpec = '%d %d\n';
    Freq = 408;  % Nombre de points par seconde
    duree = 11;  % Durée d'enregistrement en s (augmentée à 11 comme dans le fichier original)
    points = Freq * duree;
    
    % Définition des moments de début et fin d'acquisition active
    Start = 3;  % Début à 3 secondes
    Stop = 8;   % Fin à 8 secondes
    
    % Acquisition des données
    j = 1;
    while(j < points + 1)
        % Notifications à l'utilisateur
        if(j == Start*Freq)
            disp("DÉBUT DE L'ACQUISITION - EFFECTUEZ LE MOUVEMENT MAINTENANT");
        end
        if(j == Stop*Freq)
            disp("FIN DE L'ACQUISITION - ARRÊTEZ LE MOUVEMENT");
        end
        
        str = fscanf(s1, formatSpec);
        if size(str) ~= [2 1]
            continue;
        end
        accX = [accX; str(1:2)'];  % Les données des 2 capteurs
        j = j + 1;
    end
    
    % Affichage du signal
    figure;
    plot(accX);
    title('Signal EMG acquis');
    xlabel('Échantillons');
    ylabel('Amplitude');
    axis([0 length(accX) 100 400]);  % Ajustement des axes pour correspondre à la figure 1
    
    % Retour des valeurs
    emg = accX;
    Fe = Freq;
end
