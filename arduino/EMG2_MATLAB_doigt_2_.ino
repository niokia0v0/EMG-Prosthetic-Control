#include <Servo.h> 
Servo myservo1;


int sensorpinEMG1 = A2;    // select the input pin for the EMG 1
int sensorpinEMG2 = A4;    // select the input pin for the EMG 2
int sensorEMG1=0, sensorEMG2=0;  // variable to store the value coming from the EMG
long Mouvement=0;

void setup() {
  //Initialisation du port série à 115200bauds
  myservo1.attach(9);
  myservo1.write(20);
  Serial.begin(115200);

  pinMode(A4, INPUT);
}

void loop() {
  // read the value from the sensor:
  sensorEMG1 = analogRead(sensorpinEMG1);
  sensorEMG2 = analogRead(sensorpinEMG2);
  //Envoi de la mesure sur le port série pour traitement sur MATLAB
  Serial.print(sensorEMG1);
  Serial.print(" ");
  Serial.println(sensorEMG2);
  delay(2);
  if (Serial.available() > 0) {
    Mouvement = Serial.parseInt(SKIP_ALL);
    switch(Mouvement){
      case 0: //Ne fait rien
        break;
      case 1://Chi
        myservo1.write(60);
        break;
      case 2://Fou
        myservo1.write(80);
        break;
      case 3://Mi
        myservo1.write(100);
        break;
      default ://Do nothing
        myservo1.write(20);
        break;                      
    }
  }
}  
