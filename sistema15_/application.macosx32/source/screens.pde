class Screens{
  Screens(){
    tweet = "";
  }
  
  void draw(){
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
  
  void setTweet(String _tweet) {
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









String[] words = { "...final", "...tiempo", "...existencia", "...cambio", "...sueño", "...compromiso", "...promesa", "...deseos", "..../)(*&^%$", "...12345", "...//@#$%%^",  "..///354683",  ".////098^4#6", "juntos", "intrgación"};
String[] words2 = { "...cuidado", "...busqueda", "...encuentro", "..../¡™£¢", "...@#$%^&()_+", "...//ºª•¶",  "..///¶§∞¢£",  ".////™∞§ªº", "...soledad", "...recuerdo", "...esperanza", "...integridad", "...futuro"};
String[] words3 = { "..../¢£∞§", "...£¢∞§¶•™¡£", "...//ºª•¶§",  "..///$%^&",  ".////)(*&^", "...proceso", "...simple", "...cambios", "...sistema", "...corazón", "...mente", "...evolución"};



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
