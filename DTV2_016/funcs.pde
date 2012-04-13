

void startApp() {
  play = true;
  pantalla = 1;
  counter = 0;
}


void stopApp() {
  triggered = false;
//  stopSample();
  play = false;
  pantalla = 0;
  counter = 0;
}

void resetApp() {
  triggered = false;
//  stopSample();
  play = true;
  pantalla = 0;
  counter = 0;
}


void playScreens(){

  if( !play ){
   if( readIR() < IRthres )
   startApp();
  }
  
  
  if(play) {

    counter++;


    // pantalla bienvenida
    //   dura un tiempo

    // loading systema
    if( pantalla == 0) {
      if(counter > tiempoReset)
      {
        pantalla = 1;
        counter =  0;
      }
    }        
    // ponga los dedos
    //   si están todos, sigue
    if( pantalla == 1) {
      if(counter > tiempoBienvenida ) {
        pantalla = 2;
        counter = 0;
      }
    }
    
    // secuencia de numeros (leyendo los sensores)
    //   dura 15 segs
    if( pantalla == 2) {
      if( allSensorsPressed() ) {
        pantalla = 3;
        counter = 0;
      }
    }

    // procesando informacion
    // dura 5 segundos 3,2,1
    if( pantalla == 3) {
     
       if(  counter > tiempoLeyendo ) {

         // Promedio de sensores en el tiempo, usando counter
         /*
         1. crear array noSensors x n
           ArrayList sensorArry = new ArrayList();
         2. llenarlo en el tiempo
           for(int i...
             sensorArray.add(readSensor(i)
         3. promediar
           for(int i...         
             for(int j...
               suma += (int) sensorArray[i].get(j);
         */
         pantalla = 4;
         counter = 0;
       }
    }
    
    // habla la frase
    // muestra soundwave
    // imprime tiket
    if( pantalla == 4) {

     if( counter > tiempoProcesando ) {

        pantalla = 5;
        
        counter = 0;
     }
    }

    // finaliza
    if( pantalla == 5 ) {

       if(!triggered) {
         speakPrintTweet();
         println("trigger");
       }
     //printTicket();

      if( counter > tiempoHablando ) {
        println("stop");
        //stopSample();
        resetApp();
  
      }
    }
    

    
    
    
  }
}


