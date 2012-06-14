PFont font;
String[] words = { "...final", "...tiempo", "...existencia", "...cambio", "...sueño", "...compromiso", "...promesa", "...deseos", "..../)(*&^%$", "...12345", "...//@#$%%^",  "..///354683",  ".////098^4#6", "juntos", "intrgación"};
String[] words2 = { "...cuidado", "...busqueda", "...encuentro", "..../¡™£¢", "...@#$%^&()_+", "...//ºª•¶",  "..///¶§∞¢£",  ".////™∞§ªº", "...soledad", "...recuerdo", "...esperanza", "...integridad", "...futuro"};
String[] words3 = {"..../¢£∞§", "...£¢∞§¶•™¡£", "...//ºª•¶§",  "..///$%^&",  ".////)(*&^", "...proceso", "...simple", "...cambios", "...sistema", "...corazón", "...mente", "...evolución"};



int whichWord = 0;
int whichWord2 = 0;
int whichWord3 = 0;

void setup() {
size (720, 480);
font = loadFont("Helvetica-Bold-48.vlw");
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
