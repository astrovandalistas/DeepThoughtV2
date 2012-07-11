
class Estados {

  Estados() {
    counter = 0;
    readingValues=false;
    writingValues=false;
    triggeredEstado=false;
    isUserThere=false;
  }
  
  void init(ArduinoManager _arduino,Sonido _sonido,TwitterManager _twitter, Graph _graph, Screens _screens,Voz _voz){
    arduino  =  _arduino;
    sonido   =  _sonido;
    twitter  =  _twitter;
    graph    =  _graph;
    screens  =  _screens;
    voz      =  _voz;
  }
  
  
  void update() {
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
    
  
  
  void writeValues(){
    writingValues = false;
    minValue = graph.getMinValue();    
    maxValue = graph.getMaxValue();
    average  = graph.getAverage();
  }
  
  void siguienteEstado() {
    ESTADO++; 
    ESTADO%=NUM_ESTADOS;
    counter=0;
    triggeredEstado = false;
  }
  
  void irAEstado(int _estado) {
    ESTADO = _estado;
    ESTADO%=NUM_ESTADOS;
    counter=0;
    triggeredEstado = false;
  }
  
  void reiniciar() {
    ESTADO=0;

    counter=0;
    triggeredEstado = false;
  }

  void pedirManos(){
    ESTADO = 22;
    counter=0;
    triggeredEstado = false;
  }



  int getState() {
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


