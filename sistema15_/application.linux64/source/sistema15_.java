import processing.core.*; 
import processing.data.*; 

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

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class sistema15_ extends PApplet {


















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



public boolean sketchFullScreen() {
  return true;
}

public void setup(){
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


public void draw(){


  background(0,0,0);
  estados.update();

  arduinoManager.update();

  //println(arduinoManager.getGalvanicos());
  graph.setValue(arduinoManager.getGalvanicos());
  
  //graph.draw();
  
  screens.draw();
  
}





public void speakPrintTweet() {
  int index = PApplet.parseInt( random( estadosDeAnimo.size() ) ) ;
  currentTweet = twitter.getTweet(index);
  //arduinoManager.printTicket(currentTweet);
  String scriptPath = "/home/microhom/Desktop/scripttest";
  String[] cmd = {scriptPath,currentTweet}; 
  
  exec(cmd);
  
  triggered= true;
    
  
  
}



public void stop()
{
  // always close Minim audio classes when you are done with them
  minim.stop();
  super.stop();
}


int led = 0;

public void mousePressed(){
  led+=10;
  led%=255;
  arduino.analogWrite(LEDPIN,led);
}
class ArduinoManager {
  ArduinoManager () {    
    galvanicosStore = new ArrayList();
  } 

  public void setupArduino(Arduino _arduino) {
    arduino = _arduino;
    
    //for (int i = 0; i <= 13; i++)
    //  arduino.pinMode(i, Arduino.INPUT);

    pinGalvanico=0;
    pinIR = 3;
    IRThreshold = IR_THRESHOLD;
    
    galvanicoMIN = RANGO_GALVANICO_BAJO;
    galvanicoMAX = RANGO_GALVANICO_ALTO;
    ledBreatheFreq=5;
  }



  public void update() { 

    galvanicos = arduino.analogRead( pinGalvanico );
    galvanicosStore.add( (Integer) galvanicos);
        
    if(galvanicosStore.size()>GALVANICOS_STORE_NUM) 
      galvanicosStore.remove(0);
      
    if( ledsFading ) {
      ledBreathe--;
      if(ledBreathe<=0)
        ledsFading=false;
      arduino.analogWrite(LEDPIN,ledBreathe);
    }

    

    if( ledsBreathing ) {
      ledBreathe+=ledBreatheFreq;
      ledBreathe%=255;
      arduino.analogWrite(LEDPIN,ledBreathe);
    }
  
  
  }
  
  public int getGalvanicosAverage(){
    int suma=0;
    int elpromedio;
    for(int i = 0; i < galvanicosStore.size(); i++)
      suma += (Integer) galvanicosStore.get(i);
      
    elpromedio=suma/GALVANICOS_STORE_NUM;
    return elpromedio;
  }
  
  public void setSerial(Serial _serial) {
    serial = _serial;
  } 
  
  public void setLedsBreathe(int _val) {
    switch(_val) {
      case 0:
        ledBreatheFreq=5;
      break;
      case 1:
        ledBreatheFreq=10;
      break;
      case 2:
        ledBreatheFreq=15;
      break;
    }
    ledsBreathing = true;
  }
  
  
  public void setLedsFadeOut() {
    ledsBreathing = false;
    ledsFading = true;
  }
  
  public void setLedLow(){
    ledsBreathing = false;
    ledsFading = false;
    arduino.analogWrite(LEDPIN,185);

  }

  public boolean checkIR() {

    boolean bool=false;
    int ir = arduino.analogRead(pinIR);
    
    if ( ir > IRThreshold)
      bool=true;
    else
      bool=false;


    return bool;
    
  }

  public boolean getGalvanicosActive() {
      //println(galvanicosAverage);
      if(getGalvanicosAverage()>NO_TOUCH_THRESHOLD)
        return true;
      else
        return false;
  }
  
  public boolean getGalvanicosStable() {
    int galvanicosSum=0;
    
    boolean stable = true;
    for(int i = 0; i<GALVANICOS_STORE_NUM; i++)
      galvanicosSum+=(Integer)galvanicosStore.get(i);
      
    int galvanicosAverage;
    
    galvanicosAverage = galvanicosSum/GALVANICOS_STORE_NUM;

    for(int i = 0; i<GALVANICOS_STORE_NUM; i++)
      if( abs( (Integer) galvanicosStore.get(i) - galvanicosAverage ) > GALVANICOS_STABILITY_THRESHOLD) {       
        stable=false;
        break;
      }

    return stable;

  }
  
  public int getGalvanicos(){
    return galvanicos;
  }


  public void printTicket(String _string) {
    serial.clear();
    serial.write("&");
    serial.write(_string);
    serial.write("$");
    serial.write("$");
    serial.write("$");
    serial.write("$");
    serial.write("$");
    serial.write("$");
    serial.write("$");
    serial.write("$");
    serial.write("$");
    
  }

  boolean ledsBreathing   = false;
  boolean ledsFading      = false;
  boolean ledsPulsating   = false;  
  
  
  int ledBreathe=0;
  int ledBreatheFreq = 1;
  
  int galvanicoMIN;
  int galvanicoMAX;

  String address;
  Arduino arduino;
  int galvanicos;
  
  int galvanicosAverage;
  
  int pinGalvanico;
  int pinIR;
  int IRThreshold;
  
  ArrayList galvanicosStore;

  Serial serial;

  //  Galvanicos galvanicos;
}





class Galvanico {

  Galvanico() {
  }  

  public void setValue(int _val) {
    valor = _val;
  }

  int valor;
  int valorPromedio;
  int valorMin;
  int valorMax;

}




class Graph {

  Graph() {
  

    values = new ArrayList[NUM_SENSORS];  // Create an empty ArrayList

    for (int i = 0; i < NUM_SENSORS; i++) {

      values[i]=new ArrayList();
      sensor = values[i];  

      for (int j = 0; j < GRAPH_LENGTH; j++)
        sensor.add((Integer) 0 );
    }

    promedios = new ArrayList();

    colores = new int[NUM_GALVANICOS];
    colores[0] = color(255, 255, 255);
    /*
    colores[1] = color(0, 202, 220);
    colores[2] = color(154, 0, 200);
    colores[3] = color(223, 51, 0);
    colores[4] = color(93, 251, 140);
    colores[5] = color(253, 51, 100);
    */
    
    averages = new int[numLecturas];
    rawValues = new int[GRAPH_LENGTH];


  }

  public void setValue(int _valor) {

    int sum=0;

    for (int i = 0; i<NUM_GALVANICOS; i++) {
      sensor = values[i];

      sensor.add( (Integer) _valor );

      if (sensor.size()>GRAPH_LENGTH)
        sensor.remove(0);

      //sum += _valores[ i ];
      
    }

    //int average = sum / NUM_GALVANICOS;
    //promedios.add( (Integer) average );
  }

  //int[] valores;

  public int placeY(int _pos) {
    int newY = _pos;
    newY *= 0.75f;
    newY += 150;
    
    return newY;
  }

  public void draw() {
    textFont(font2);
    textAlign(LEFT);
    stroke(255,255,255);
 
  sum=0;
  
  for (int i = 0; i < 1; i++) {
     sensor = values[i];
     
     
     valor = (Integer)sensor.get(i);
     
     //sum+=valor;
     
     fill( colores[i] );
     //stroke( colores[i] );
     strokeWeight(2);   // Default
     for (int j = 0; j < GRAPH_LENGTH; j++) {        
          valor =  (Integer) sensor.get(j);
          oldIndex = (j+1)%GRAPH_LENGTH;
          valorViejo =  (Integer) sensor.get(oldIndex);

          //ellipse( (250-(j/2))+300,valor/2 + 100,2,2 );
          line( 520-(j*4)+100, placeY(valor), 520-(j*4+1)+100, placeY(valorViejo) );
          readCounter++;
          
          readCounter%=numLecturas;
          
          if(readCounter==0) {
          
          }

     }
     
     
     stroke(color(255,255,255));
     
     int smoothSum,smoothValue;
     int numPromedios = GRAPH_LENGTH / numLecturas;
     
     for (int j = 0; j < numPromedios; j++) {        
       smoothSum=0;
       for (int k = 0; k < numLecturas; k++) {        
         smoothValue =  (Integer) sensor.get((j*numLecturas)+k);
         
         smoothSum += smoothValue; 
       }
       
       average = smoothSum / numLecturas;
       stroke(255,125,0);
       ellipse( (520-((j*4*numLecturas)))+100, placeY(average) ,3,3);//(250-(((j+1)*numLecturas)/2))+800,200+oldAverage/2);
       oldAverage=average;
       stroke(255,255,255);
     }
     
     
     

  }
  int promedio = sum/4;
  promedios.add((Integer)average);
  if(promedios.size()>GRAPH_LENGTH)
       promedios.remove(0);
  
  
  int promediosSum=0;
  strokeWeight(3);   
  for (int j = 0; j < GRAPH_LENGTH; j++)
    rawValues[j]= (Integer) sensor.get(j);


  minValue=min(rawValues);
  maxValue=max(rawValues);
  
  int promedioFinalSum=0;

  for (int j = 0; j < GRAPH_LENGTH; j++){   
    int val;
    val = (Integer) promedios.get(j%promedios.size());

    promedioFinalSum+=val;
      
  }

  promedioFinal = promedioFinalSum/GRAPH_LENGTH;


  strokeWeight(3);   // Default

  stroke(255,0,0);
  
  line( 400, placeY(minValue) ,400+GRAPH_LENGTH, placeY(minValue) );
  stroke(255,255,255);
  line( 400, placeY(promedioFinal),400+GRAPH_LENGTH, placeY(promedioFinal) );
  stroke(0,255,0);
  line( 400, placeY(maxValue) ,400+GRAPH_LENGTH, placeY(maxValue) );

  stroke(255,125,0);
  fill(255,0,0);
  text(str( minValue), 650, 30 );
  fill(255,255,255);
  text(str( promedioFinal ), 650, 80 );
  fill(0,255,0);
  text(str( maxValue), 650, 130 );
  
  promedioFinal=0;
  
  
  strokeWeight(4);   // Default

  for (int j = 0; j < GRAPH_LENGTH; j++) {        
             oldIndex = (j+1)%GRAPH_LENGTH;
          int val, val2;
          val = (Integer)   promedios.get(j%promedios.size());
          val2 = (Integer)  promedios.get(oldIndex%promedios.size());

      averages[readCounter] = val;
      promedioFinalSum+=val;

      promediosSum+=val;
      readCounter++;
      readCounter%=numLecturas;
      
      
      
      
      stroke(255,255,255);
      fill(255,255,255);

      line( (250-(j))+100, placeY(val) ,(250-((j+1)))+100, placeY(val2) );
      
      if(readCounter==0) {

        average = promediosSum/numLecturas;
        promediosSum=0;
        stroke(0,0,0);
        ellipse( (GRAPH_LENGTH)-j+400, placeY(average) ,10,10);
      
      }

  }
        
    
  stroke(255,255,255);
  fill(color(255));
  
  for (int i = 0; i < 9; i++) {        
    
    text(str( (600/12)*i), 30, placeY( (600/12)*i )  );
  
  }
   
  }
  
  public int getMinValue()  { return minValue; }
  public int getMaxValue()  { return maxValue; }
  public int getAverage()   { return promedioFinal; }


  ArrayList[] values;
  ArrayList sensor;
  ArrayList promedios;
  int valor;
  
  int oldIndex;
  int valorViejo;
  
int NUM_SENSORS  = 1;


 

  int[] averages;
  int[] rawValues;

  int readCounter=0;
  int numLecturas=10;
  int sum=0;
  int average,oldAverage = 0;

  int[] colores;
  
  int minValue;
  int maxValue;
  int promedioFinal;
    
}



class Sonido{
  Sonido(){}
  
  public void playSample(String _file){
  
}
  
  

Minim minim;
AudioSample voz;
//WaveformRenderer waveform;



ArrayList samples;


public void setupAudio(Minim _minim)
{
  
  minim = _minim;

  minim.debugOn();
  
  
//  samples = new ArrayList();

  
}


public void createSample(String msg) {
   
  //String scriptPath = "/home/microhom/Desktop/scripttest";
  //String[] cmd = {scriptPath,msg,textFile }; 
  
  //exec(cmd);
  
}

public void speakSample(){
  audioPlaying=true;

  voz.trigger();  
  
  //voz.addListener(waveform);
  //
}

public void stopSample() {
    voz.stop();
    voz.close();
  
    audioPlaying=false;
    message="ya";


}






}



class Voz{
  Voz(){}
  
  
  public void speak(String _string) {
    String scriptPath = "/home/microhom/Desktop/scripttest";
    String[] cmd = {scriptPath,_string}; 
    
    exec(cmd);
  }
}

class Estados {

  Estados() {
    counter = 0;
    readingValues=false;
    writingValues=false;
    triggeredEstado=false;
    isUserThere=false;
  }
  
  public void init(ArduinoManager _arduino,Sonido _sonido,TwitterManager _twitter, Graph _graph, Screens _screens,Voz _voz){
    arduino  =  _arduino;
    sonido   =  _sonido;
    twitter  =  _twitter;
    graph    =  _graph;
    screens  =  _screens;
    voz      =  _voz;
  }
  
  
  public void update() {
        /*
        if(isUserThere) {
          if(!arduinoManager.checkIR()){
            reiniciar();
            isUserThere=false;
          }
      
        }
        */
    counter++;
    
    switch(ESTADO){
    
    
      //sinusoidal grave continuo
      case 0:        
        if(!triggeredEstado) { 
          sonido.playSample("01.wav");
          triggeredEstado = true;
          arduinoManager.setLedLow();
        }
        if(arduinoManager.checkIR() && counter>=TIEMPO_INICIO){
          siguienteEstado();
          isUserThere=true;
      
        }
      break;
    
      case 1:
        graph.draw();

        if(!triggeredEstado) { 
          sonido.playSample("02.wav");
          triggeredEstado = true;
          arduinoManager.setLedsBreathe(0);
        }
        if( arduinoManager.getGalvanicosActive() && counter>=TIEMPO_DEDOS_INIT )
          siguienteEstado();
        if( !arduinoManager.getGalvanicosActive() && counter>=TIEMPO_SIN_DEDOS && !arduinoManager.checkIR() )
          reiniciar();
    
      break;
    
      case 2:
        graph.draw();
        if(!triggeredEstado) { 
          triggeredEstado = true;
          readingValues = true;
          arduinoManager.setLedsBreathe(1);
          
        }
        if( counter<TIEMPO_PARA_PONER_MANOS ) {
          if(counter>TIEMPO_PREPARACION)
            if( arduinoManager.getGalvanicosStable() )
              siguienteEstado();
        }
        else {
          pedirManos();
        }
        
    
      break;
    
      case 3:
        graph.draw();

        if(!triggeredEstado) { 
          triggeredEstado = true;
          writingValues=true;
          arduinoManager.setLedsBreathe(2);

        }
        if( arduinoManager.getGalvanicosStable() ) {
          if( counter>=TIEMPO_LECTURA ) siguienteEstado();
        
        }
        else  {
          pedirManos();
        }
    
      break;
    
      case 4:        
        if(!triggeredEstado) { 
          sonido.playSample("03.wav");
          triggeredEstado = true;
          arduinoManager.setLedsFadeOut();
          writeValues();         
          tweet = twitter.getTweet( getState() );   
          screens.setTweet(tweet);
          
        }
      if( counter>=TIEMPO_PROCESANDO ) {
          siguienteEstado();         
      }
      if( !arduinoManager.getGalvanicosActive() ){
        pedirManos();
      }
    
      break;
    
    
      case 5:        
        if(!triggeredEstado) { 
          triggeredEstado = true;
          arduinoManager.printTicket( tweet );
          voz.speak(tweet);

        }
        if( counter>=TIEMPO_RESULTADO ) {
          siguienteEstado();         
        }
    
      break;
      
      case 6:
        
        if(!triggeredEstado) { 
          //.playSample("04.wav");
          triggeredEstado = true;
          //arduinoManager.setLedsFadeOut();
        }
        if( counter>=TIEMPO_DESPEDIDA ) siguienteEstado();
    
      break;
  
      case 7:
        
        if(!triggeredEstado) { 
          //.playSample("04.wav");
          triggeredEstado = true;
          //arduinoManager.setLedsFadeOut();
        }
        if( counter>=TIEMPO_PAUSA ) siguienteEstado();
    
      break;
      
    case 22:
        
        if(!triggeredEstado) { 
          triggeredEstado = true;
          readingValues = true;            
        }
        if( arduinoManager.getGalvanicosActive() && counter>=TIEMPO_DEDOS_INIT )
          irAEstado(3);
        if( !arduinoManager.getGalvanicosActive() && counter>=TIEMPO_SIN_DEDOS && !arduinoManager.checkIR() )
          reiniciar();

    break;

  }
    }
    
  
  
  public void writeValues(){
    writingValues = false;
    minValue = graph.getMinValue();    
    maxValue = graph.getMaxValue();
    average  = graph.getAverage();
  }
  
  public void siguienteEstado() {
    ESTADO++; 
    ESTADO%=NUM_ESTADOS;
    counter=0;
    triggeredEstado = false;
  }
  
  public void irAEstado(int _estado) {
    ESTADO = _estado;
    ESTADO%=NUM_ESTADOS;
    counter=0;
    triggeredEstado = false;
  }
  
  public void reiniciar() {
    ESTADO=0;

    counter=0;
    triggeredEstado = false;
  }

  public void pedirManos(){
    ESTADO = 22;
    counter=0;
    triggeredEstado = false;
  }



  public int getState() {
    boolean high=true;
    boolean positive=true;
    
    int state = 0;
    
     if( abs(maxValue-minValue) >= ACTIVITY_THRESHOLD )
       high=true;
     else
       high=false;
       
     if(average >= POLARITY_THRESHOLD)
       positive=true;
     else
       positive=false;
     
     if( positive && high )
       state = 0;
     else
     if( !positive && high )
       state = 1;
     if( positive && !high )
       state = 2;
     else
     if( !positive && !high )
       state = 3;
    
    return state;
  
  }
  
  

  boolean triggeredEstado;
  
  int counter;


  ArduinoManager   arduino;
  Graph            graph;
  Sonido           sonido;
  TwitterManager   twitter;
  Screens          screens;
  Voz              voz;
  
  String tweet;
  
  boolean readingValues,writingValues;
  
  boolean isUserThere;

  int minValue, maxValue, average;


}


class Screens{
  Screens(){
    tweet = "";
  }
  
  public void draw(){
    textAlign(CENTER);
    textFont(font,42);    

    switch( ESTADO ) {

      case 0:
      
      text("come closer / acercate",width/2,height/2);
      break;
      
      case 1:
        //textFont(font);    
        text("place your fingers on the sensors",width/2,50);
        text("coloca dedos sobre sensores",width/2,110);
      break;
      
      case 22:
        textFont(font,40);    

        text("place your fingers on the sensors again",width/2,50);
        text("vuelve a colocar dedos sobre sensores",width/2,110);
      break;
      
      case 2:
        text("take a deep breath",width/2,50);
        text("respira profundo",width/2,110);

      break;
      
      case 3:
        text("reading...",width/2,50);
        text("leyendo...",width/2,110);
        
      break;
  
      case 4:    
        text("processing readings...",width/2, height/2 - 50  );
        text("procesando lecturas...",width/2, height/2 + 50 );
        
      break;
      case 5:  
        textFont(font);    
        textAlign(CENTER,CENTER);
        text(tweet, 0,0,720,480);
      break;
      case 6:
        text("see you soon",width/2, height/2 - 50  );
        text("nos vemos pronto",width/2, height/2 + 50 );
      break;
      case 7:
      //negros
      break;       
    
    }
    
  }
  
  public void setTweet(String _tweet) {
    tweet = _tweet;
  }

  String tweet;
}









/*

void drawScreens() {
  
  if(pantalla == 0){
 
      message = "end of the reading";
      text(message,width/2,height/2);

  }
  if(pantalla == 1){
      fill((counter%12) * 13 );
      text("Deep Thought -V.2. //// ", 100, 200, 1000, 680);
       
       fill(255);
      text("place your fingers on the sensors//", 100, 400, 900, 680);
      

  }
  if(pantalla == 2){
     fill((counter%12) * 13 );
      text("Deep Thought -V.2. //// ", 100, 200, 1000, 680);
       fill(255);
      text("-Take a deep breath//", 100, 400, 1000, 680);
      text("-Let chance happen//", 100, 500, 900, 680);
  }
  if(pantalla == 3){
      message = "reading sensors";
      text(message,width/2,height/2);
      
      drawSensors();
  }
  if(pantalla == 4){
      message = "processing data";
      text(message,width/2,height/2);
  }
  if(pantalla == 5){
    //message = "...";
    //if(audioPlaying==true)
    myPort.write('H');
    message = currentTweet;
      myPort.clear();
    
    background(0);//((counter%12) * 13);

        
    text(message, 80, 140, 900, 680);
     fill(255);
      text("-print: DTV2 @Twitter:", 80, 590, 1000, 680);

// drawAudio();

  }
  
}

void drawSensors(){

      int tabulation = 50;
      int separation = (width-(tabulation*2)) / noSensors;
      int centerX = width/2;

      for(int i = 0; i<noSensors; i++){
        text(i, tabulation+(centerX - (((noSensors/2)-i)*separation)),300);
      }

}









String[] words = { "...final", "...tiempo", "...existencia", "...cambio", "...sue\u00f1o", "...compromiso", "...promesa", "...deseos", "..../)(*&^%$", "...12345", "...//@#$%%^",  "..///354683",  ".////098^4#6", "juntos", "intrgaci\u00f3n"};
String[] words2 = { "...cuidado", "...busqueda", "...encuentro", "..../\u00a1\u2122\u00a3\u00a2", "...@#$%^&()_+", "...//\u00ba\u00aa\u2022\u00b6",  "..///\u00b6\u00a7\u221e\u00a2\u00a3",  ".////\u2122\u221e\u00a7\u00aa\u00ba", "...soledad", "...recuerdo", "...esperanza", "...integridad", "...futuro"};
String[] words3 = { "..../\u00a2\u00a3\u221e\u00a7", "...\u00a3\u00a2\u221e\u00a7\u00b6\u2022\u2122\u00a1\u00a3", "...//\u00ba\u00aa\u2022\u00b6\u00a7",  "..///$%^&",  ".////)(*&^", "...proceso", "...simple", "...cambios", "...sistema", "...coraz\u00f3n", "...mente", "...evoluci\u00f3n"};



int whichWord = 0;
int whichWord2 = 0;
int whichWord3 = 0;

void setup() {
size (720, 480);

textFont(font);

frameRate(15);

}

void draw() {

  background (0);
  fill(133);
  text("Search in progress ... one moment please:", 90, 60, 550, 180);  
  
  whichWord++;
  if (whichWord == words.length) {
    whichWord = 0;
  }
  
    whichWord2++;
  if (whichWord2 == words2.length) {
    whichWord2 = 0;
  }
  
    whichWord3++;
  if (whichWord3 == words3.length) {
    whichWord3 = 0;
  }

fill(255);
 textAlign(LEFT);
 text(words[whichWord],90, 240);
 textAlign(LEFT);
text(words2[whichWord2], 90, 310);
 textAlign(LEFT);
text(words3[whichWord3], 90, 385);
}










*/
 

// pegar informacion del dev.twitter.com
String consumer_key = "oKYNpI5s7WNRP1V85tkmw";
String consumer_secret = "LZJb0fQT0xBNGNCIEg5JFRfJORBzLywUgHYEYOZyErg";
String oauth_token = "83521479-KqVM9N83waKm60D0KTctMyd1sXhYDQgMJhPOHvbsI";
String oauth_token_secret = "mgERslIneJ9Y63frNWG6SQEsPm7uNCIN7NHT2nVZSA";

//string de terminos para busquedas



String [] positive = {
   "optimism", "love", "clarity", "dream",  "growing up", "evolution", "luck", "fight", "commitment"};
String [] negative = {
   "soledad", "confusion", "vacio", "desesperacion", "fatiga", "tristeza",  "cobardia", "egoismo", "banalidad"};
String [] positiveN = {
   "cinismo", "sarcasmo", "indiferencia", "flojera", "absurdo"};
String [] negativeN = {
   "equilibrio", "desapego", "encuentro", "despertar", "esperanza"};
   
   
   
ArrayList estadosDeAnimo;
HashMap phraseList;




class TwitterManager {

    
  TwitterManager(){
    
    phraseList = new HashMap<String, List<String> >();
    
    estadosDeAnimo = new ArrayList();
    
    estadosDeAnimo.add( positive );
    estadosDeAnimo.add( negative );
    estadosDeAnimo.add( positiveN );
    estadosDeAnimo.add( negativeN );
    
    message = "...";
    
  
    // configuraci\u00f3n del twitter4j
  
      
    for(int i = 0; i < estadosDeAnimo.size(); i++ )
    {
        String[] palabras = (String[])estadosDeAnimo.get(i);
        
        for(int j = 0; j<palabras.length; j++)
          generarListaFrases(palabras[j]);
        
    }
  
    
  }
  
  
  public void generarListaFrases(String palabra){
    
    
    Twitter twitter = new TwitterFactory().getOAuthAuthorizedInstance (
    consumer_key, consumer_secret, new AccessToken( oauth_token, oauth_token_secret) );
  
    try{
  
      Query query = new Query( palabra );//cargar el resultado de un string con random
     // query.setGeoCode(new GeoLocation(50.0, 10.0), 1000.0, Query.KILOMETERS);
      query.setRpp(100000);
      query.setLang("es"); // busqueda espa\u00f1ol
      QueryResult result = twitter.search(query);
            
      ArrayList tweets = (ArrayList) result.getTweets();      
      
      phraseList.put(palabra,tweets);
                
    }
    catch(TwitterException te){
      
        println("couldn't connect: " +te);   
    
    }
  
  }
    
  
  
  public String getTweet ( int index ){
  
    String msg;
    
    String[] palabras = (String[])estadosDeAnimo.get(index);
  
  
    //RANDOM
  
  
    int wordIndex = PApplet.parseInt( random( palabras.length ) ) ;
  
            
    ArrayList tweetz = (ArrayList) phraseList.get(palabras[wordIndex]);
        
    //RANDOM
  
    int twitIndex = PApplet.parseInt( random( tweetz.size() ) );
        
    Tweet t = (Tweet) tweetz.get(twitIndex);
        
    String user = t.getFromUser();
    msg = t.getText();
  
    Date d = t.getCreatedAt();
  
  //  println("Tweet by" + user + "at" + d + ": " + msg);
    
    
    
  
    msg = msg.replaceAll("[^A-Za-z\u00e1\u00e9\u00ed\u00f3\u00fa\u00f1.,?@# ]", "");
    //msg = msg.replaceAll("ce", "se");
    //msg = msg.replaceAll("ci", "si");
    //msg = msg.replaceAll("z", "s");
  
  
    String tmpString="";
    String convertedString;
  
    msg = cleanString(msg,"http");
    
    msg = cleanString(msg,"www");
    
    msg = cleanString(msg,"#");
    msg = cleanString(msg,"@");
    
    msg = msg.replace("RT","");
  
    return msg;
  
  
  
  }
  
  public String cleanString(String msg, String str){
  
    String tmpString="";
  
    while(msg.contains(str))  {
      int indexArroba = msg.indexOf(str);
      
      if(indexArroba>=0) {
      
        tmpString = msg.substring(indexArroba) ;
        if(tmpString.indexOf(" ")>=0)
          tmpString = tmpString.substring(0,tmpString.indexOf(" ") );
          String msg2 =
          msg = msg.replace( tmpString, "" );
          //println("borr\u00e9: "+tmpString );
      
      }    
    

    }  
    return msg;
    
  }

  
  
  }

  public int sketchWidth() { return 720; }
  public int sketchHeight() { return 480; }
  static public void main(String args[]) {
    PApplet.main(new String[] { "--full-screen", "--bgcolor=#666666", "--hide-stop", "sistema15_" });
  }
}
