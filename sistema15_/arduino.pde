class ArduinoManager {
  ArduinoManager () {    
    galvanicosStore = new ArrayList();
  } 

  void setupArduino(Arduino _arduino) {
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



  void update() { 

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
  
  int getGalvanicosAverage(){
    int suma=0;
    int elpromedio;
    for(int i = 0; i < galvanicosStore.size(); i++)
      suma += (Integer) galvanicosStore.get(i);
      
    elpromedio=suma/GALVANICOS_STORE_NUM;
    return elpromedio;
  }
  
  void setSerial(Serial _serial) {
    serial = _serial;
  } 
  
  void setLedsBreathe(int _val) {
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
  
  
  void setLedsFadeOut() {
    ledsBreathing = false;
    ledsFading = true;
  }
  
  void setLedLow(){
    ledsBreathing = false;
    ledsFading = false;
    arduino.analogWrite(LEDPIN,185);

  }

  boolean checkIR() {

    boolean bool=false;
    int ir = arduino.analogRead(pinIR);
    
    if ( ir > IRThreshold)
      bool=true;
    else
      bool=false;


    return bool;
    
  }

  boolean getGalvanicosActive() {
      //println(galvanicosAverage);
      if(getGalvanicosAverage()>NO_TOUCH_THRESHOLD)
        return true;
      else
        return false;
  }
  
  boolean getGalvanicosStable() {
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
  
  int getGalvanicos(){
    return galvanicos;
  }


  void printTicket(String _string) {
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

  void setValue(int _val) {
    valor = _val;
  }

  int valor;
  int valorPromedio;
  int valorMin;
  int valorMax;

}



