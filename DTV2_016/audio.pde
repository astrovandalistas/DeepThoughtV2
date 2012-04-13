

import ddf.minim.*;

Minim minim;
AudioSample voz;
WaveformRenderer waveform;



ArrayList samples;


void setupAudio()
{

  minim = new Minim(this);
  minim.debugOn();
  
  
//  samples = new ArrayList();

  
}


void createSample(String msg) {
   
  String scriptPath = "/home/microhom/Desktop/scripttest";
  String[] cmd = {scriptPath,msg,textFile }; 
  
  exec(cmd);
  
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

void stop()
{
  // always close Minim audio classes when you are done with them
  minim.stop();
  super.stop();
}



