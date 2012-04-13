/* 
DTV2 - Codigo que controla todas las funciones de DeepThought. version 016.
Leslie Garcia + Rodrigo Trevino Frenk
http://dalab.ws/dtv2
*/

import fullscreen.*; 
import processing.serial.*;
FullScreen fs;

//------------------------------------------
// VARIABLES DE SCREENS
int counter = 0; 
int pantalla = 1;
int tiempo = 300;

int noSensors = 10;

int IRthres=10;
int touchThres=1000;

int tiempoReset=50;

int tiempoBienvenida=90;
int tiempoLeyendo=30;
int tiempoProcesando=30;
int tiempoHablando=240;

//int stopSampleAfter = 12000;

PFont font;
boolean play = false;

String message;
String currentTweet;


boolean triggered = false;
boolean preloadAudio = false;
boolean audioPlaying = false;

Serial myPort; 
int val;       




void setup() {
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 38400);
  
  size(1024,768);
    // Create the fullscreen object
  fs = new FullScreen(this); 
  
  // enter fullscreen mode
  fs.enter(); 

  smooth();
  font = loadFont("Helvetica-Bold-48.vlw");
  textFont(font, 70);
  
 
  //textAlign(CENTER);
  startApp();
  
  setupTwitter();
  setupAudio();
  
  
  frameRate(15);


  
}


void draw() {
  
  background( 0 );
  delay(1);

  playScreens();
  
  drawScreens();
  
}

void keyPressed()
{
  pantalla = 5;
  
}



void speakPrintTweet() {
  int index = int( random( estadosDeAnimo.size() ) ) ;
  currentTweet = getTweet(index);
  printTicket(currentTweet);
  String scriptPath = "/home/microhom/Desktop/scripttest";
  String[] cmd = {scriptPath,currentTweet}; 
  
  exec(cmd);
  
  triggered= true;
    
  
  
}
