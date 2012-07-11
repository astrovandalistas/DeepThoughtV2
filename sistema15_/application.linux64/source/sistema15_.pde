
import ddf.minim.*;

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.http.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;

import processing.serial.*;

import cc.arduino.*;

int TIEMPO_INICIO            = 200;
int TIEMPO_DEDOS_INIT        = 100;
int TIEMPO_SIN_DEDOS         = 500;
int TIEMPO_PARA_PONER_MANOS  = 400;
int TIEMPO_PREPARACION       = 200;
int TIEMPO_LECTURA           = 400;
int TIEMPO_PROCESANDO        = 200;

int TIEMPO_RESULTADO         = 500;
int TIEMPO_DESPEDIDA         = 300;
int TIEMPO_PAUSA             = 200;

int POLARITY_THRESHOLD = 236;
int ACTIVITY_THRESHOLD = 92;


int IR_THRESHOLD   = 455;
int NUM_GALVANICOS = 1;
int GRAPH_LENGTH   = 300;
int NUM_SENSORS    = 1;

int ESTADO;


int GALVANICOS_STORE_NUM = 400;
int GALVANICOS_STABILITY_THRESHOLD = 150;

int NO_TOUCH_THRESHOLD = 100;

int RANGO_GALVANICO_BAJO = 100;
int RANGO_GALVANICO_ALTO = 200;

int NUM_ESTADOS=8;

int LEDPIN = 11;



//-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*--*-*-

Arduino arduino;
ArduinoManager arduinoManager;

Minim            minim;
Serial           serial;
Graph            graph;
Estados          estados;
Sonido           sonido;
Screens          screens;
TwitterManager   twitter;
Voz              voz;



PFont font,font2;
boolean play = false;

String message;
String currentTweet;


boolean triggered = false;
boolean preloadAudio = false;
boolean audioPlaying = false;



boolean sketchFullScreen() {
  return true;
}

void setup(){
  size(720,480);
  
  font  = loadFont("Helvetica-Bold-48.vlw");
  font2 = loadFont("Helvetica-18.vlw");
  textFont(font); 
  
    
  minim = new Minim(this);
  
  String portName = Serial.list()[0];
  serial = new Serial(this, portName, 38400 );
  
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(LEDPIN, Arduino.PWM);

  arduinoManager = new ArduinoManager();
  arduinoManager.setupArduino(arduino);
  arduinoManager.setSerial(serial);
  
  sonido = new Sonido();
  sonido.setupAudio(minim);
  estados = new Estados();
  twitter = new TwitterManager();

  
  graph = new Graph();
  screens = new Screens();

  voz = new Voz();
  
  estados.init( arduinoManager, sonido, twitter, graph, screens, voz );

  
  
}


void draw(){


  background(0,0,0);
  estados.update();

  arduinoManager.update();

  //println(arduinoManager.getGalvanicos());
  graph.setValue(arduinoManager.getGalvanicos());
  
  //graph.draw();
  
  screens.draw();
  
}





void speakPrintTweet() {
  int index = int( random( estadosDeAnimo.size() ) ) ;
  currentTweet = twitter.getTweet(index);
  //arduinoManager.printTicket(currentTweet);
  String scriptPath = "/home/microhom/Desktop/scripttest";
  String[] cmd = {scriptPath,currentTweet}; 
  
  exec(cmd);
  
  triggered= true;
    
  
  
}



void stop()
{
  // always close Minim audio classes when you are done with them
  minim.stop();
  super.stop();
}


int led = 0;

void mousePressed(){
  led+=10;
  led%=255;
  arduino.analogWrite(LEDPIN,led);
}
