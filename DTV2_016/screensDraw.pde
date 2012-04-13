void drawScreens() {
  
  if(pantalla == 0){
 
      message = "reset";
      text(message,width/2,height/2);

  }
  if(pantalla == 1){
      fill((counter%12) * 13 );
      text("Deep Thought -V.2.  //// ", 100, 200, 1000, 680);
       
       fill(255);
      text("coloca tus dedos sobre los sensores del tablero//", 100, 400, 900, 680);
      

  }
  if(pantalla == 2){
     fill((counter%12) * 13 );
      text("Deep Thought -V.2.  //// ", 100, 200, 1000, 680);
       fill(255); 
      text("-Respira profundo//", 100, 400, 1000, 680);
      text("-Permite que el azar suceda//", 100, 500, 900, 680);
  }
  if(pantalla == 3){
      message = "leyendo sensores";
      text(message,width/2,height/2);
      
      drawSensors();
  }
  if(pantalla == 4){
      message = "procesando datos";
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

//      drawAudio();

  }
  
}

void drawSensors(){

      int tabulation = 50;
      int separation = (width-(tabulation*2)) / noSensors;
      int centerX = width/2;

      for(int i = 0; i<noSensors; i++){
        text(i,  tabulation+(centerX - (((noSensors/2)-i)*separation)),300);
      }

}



