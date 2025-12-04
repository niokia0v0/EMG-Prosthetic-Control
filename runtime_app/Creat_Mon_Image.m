function Creat_Mon_Image(emg, Fe)
    %% Fonction pour créer une image de scalogramme à partir d'un signal EMG
    % Paramètres:
    %   emg - Signal EMG à analyser (matrice avec 2 colonnes pour 2 capteurs)
    %   Fe  - Fréquence d'échantillonnage en Hz
    
    % Combiner les deux canaux EMG en un seul vecteur comme dans la fonction originale
    if size(emg, 2) > 1
        emg_signal = [emg(:,1); emg(:,2)]; 
    else
        emg_signal = emg;
    end
    
    % Obtenir la longueur du signal
    lemg = length(emg_signal);
    t = (0:lemg-1)/Fe;
    
    % Création du scalogramme en utilisant la transformée en ondelettes continue
    fb = cwtfilterbank('SignalLength', lemg, 'SamplingFrequency', Fe, 'VoicesPerOctave', 12);
    [cfs, frq] = wt(fb, emg_signal);
    
    % Affichage du scalogramme
    figure('visible', 'on');
    pcolor(t, frq, abs(cfs));
    set(gca, 'yscale', 'log');
    shading interp;
    axis tight;
    title('Scalogramme du signal EMG');
    
    % Sauvegarde du scalogramme dans le répertoire de travail
    saveas(gcf, 'Mon_Image.jpg');
    close(gcf);
end
