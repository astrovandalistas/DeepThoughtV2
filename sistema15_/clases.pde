
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

    colores = new color[NUM_GALVANICOS];
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

  void setValue(int _valor) {

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

  int placeY(int _pos) {
    int newY = _pos;
    newY *= 0.75;
    newY += 150;
    
    return newY;
  }

  void draw() {
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
  
  int getMinValue()  { return minValue; }
  int getMaxValue()  { return maxValue; }
  int getAverage()   { return promedioFinal; }


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

  color[] colores;
  
  int minValue;
  int maxValue;
  int promedioFinal;
    
}



class Sonido{
  Sonido(){}
  
  void playSample(String _file){
  
}
  
  

Minim minim;
AudioSample voz;
//WaveformRenderer waveform;



ArrayList samples;


void setupAudio(Minim _minim)
{
  
  minim = _minim;

  minim.debugOn();
  
  
//  samples = new ArrayList();

  
}


void createSample(String msg) {
   
  //String scriptPath = "/home/microhom/Desktop/scripttest";
  //String[] cmd = {scriptPath,msg,textFile }; 
  
  //exec(cmd);
  
}

void speakSample(){
  audioPlaying=true;

  voz.trigger();  
  
  //voz.addListener(waveform);
  //
}

void stopSample() {
    voz.stop();
    voz.close();
  
    audioPlaying=false;
    message="ya";


}






}



class Voz{
  Voz(){}
  
  
  void speak(String _string) {
    String scriptPath = "/home/microhom/Desktop/scripttest";
    String[] cmd = {scriptPath,_string}; 
    
    exec(cmd);
  }
}
