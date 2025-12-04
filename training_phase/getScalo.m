%% Script pour créer la base de données des scalogrammes
% Ce script charge les fichiers EMG, crée des scalogrammes et les sauvegarde dans la structure de dossiers appropriée

% Définir les paramètres
NMvt = 3;        % Nombre de mouvements
Nrepet = 35;     % Nombre de répétitions par mouvement
Fe = 408;        % Fréquence d'échantillonnage (Hz), ajuster si nécessaire

% Créer les répertoires de sortie s'ils n'existent pas
if ~exist('MaBdD', 'dir')
    mkdir('MaBdD');
end

for n = 1:NMvt
    if ~exist(['MaBdD\Mvt' num2str(n)], 'dir')
        mkdir(['MaBdD\Mvt' num2str(n)]);
    end
end

% Traitement de tous les fichiers EMG
for mvt = 1:NMvt
    for rep = 1:Nrepet
        % Construire le nom du fichier d'entrée
        input_filename = ['mesures\Mvt' num2str(mvt) '_' num2str(rep) '.mat'];
        
        % Charger le fichier EMG
        disp(['Traitement de ' input_filename]);
        data = load(input_filename);
        
        % Créer le scalogramme
        Creat_Image(data.accX, Fe, mvt, rep);
    end
end

disp('Traitement terminé. Base de données de scalogrammes créée avec succès.');

%% Fonction locale pour créer une image de scalogramme
function Creat_Image(EMG, Fe, mvt_num, rep_num)
    % Combiner les deux canaux EMG en un seul vecteur
    emg = [EMG(:,1); EMG(:,2)]; 
    lemg = length(emg);
    t = (0:lemg-1)/Fe;
    
    % Création du scalogramme
    fb = cwtfilterbank('SignalLength', lemg, 'SamplingFrequency', Fe, 'VoicesPerOctave', 12);
    [cfs, frq] = wt(fb, emg);
    
    % Affichage du scalogramme
    figure('visible', 'off');  % 'on' pour voir les figures pendant le traitement, 'off' pour les cacher
    pcolor(t, frq, abs(cfs));
    set(gca, 'yscale', 'log');
    shading interp;
    axis tight;
    title(['Scalogramme - Mvt' num2str(mvt_num) ' Rep' num2str(rep_num)]);
    
    % Sauvegarde de l'image
    output_filename = ['MaBdD\Mvt' num2str(mvt_num) '\Scalo' num2str(rep_num) '.jpg'];
    saveas(gcf, output_filename);
    close(gcf);  % Fermer la figure après sauvegarde
    
    disp(['Scalogramme créé et sauvegardé: ' output_filename]);
end
