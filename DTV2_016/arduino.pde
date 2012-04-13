
int readSensor(int i) {
int value = 0;
//VALUE=LEER ARDUINO

return value;  
}



int readIR() {
  int value = 0;
  // read IR 
  return value;  
}


void printTicket(String msg){
  //sendtoarduino(msg)

}


boolean allSensorsPressed(){

  boolean allOn = true;
  for(int i = 0; i<noSensors; i++){
    if(readSensor(i)<touchThres)  
      allOn =false;
  }
  return allOn;
}



