function [emg,Fe,s1] = Mes_EMG;
clear
if (~isempty(instrfind))
    fclose(instrfind);
end
tv = '35';
filename = sprintf('Mvt3_%s.mat',tv);
s1=serial('COM3','Baudrate',115200);  %Port COM à vérifier !
fopen(s1);
flushinput(s1);
accX=[];t=[];
str='';
j=1;%
x=0;
formatSpec = '%d %d\n';
Freq=408;%nombre de points par seconde
duree=11;%durée d'enregistrement en s
points = Freq*duree;
Start=3;%Début à 3 secondes
Stop=8;%fin à 8 secondes
while(j<points+1)
    if(j == Start*Freq)%Beep au bout de 3 secondes
        beep
        disp("Début de l'acquisition")
    end
    if(j == Stop*Freq)
        beep
        disp("Fin de l'acquisition")
    end
    
    str=fscanf(s1, formatSpec);
    if size(str)~=[2 1]
        continue
    end;
    accX=[accX;str(1:2)'];   %les données des 2 capteurs 
    t=[t;datestr(now, 'dd_hh_MM_ss.FFF')];
    x(j)=j;
    j=j+1;
end;
plot(accX)
disp(strcat("Enregistrement du fichier ",filename))
save(filename,'accX')
emg = accX;
Fe = Freq;