function Commande_Prothese(a);


%% Connexion série Arduino-Matlab-ArduinoConnexion série Arduino-Matlab-Arduino options d'élément
if (~isempty(instrfind))
    fclose(instrfind);
end

s2=serial('COM5','Baudrate',115200);  % Port COM à modifier !
fopen(s2);
flushinput(s2);
pause(2);

%% Pour envoyer une commande à la prothèse, utiliser la fonction ci-dessous
fprintf(s2,'%d\n',a) % a contient le mouvement (1,2 ou 3)

pause(2);
%% A insérer à la fin du programme
fclose(s2);
delete(s2);
clear s2;


