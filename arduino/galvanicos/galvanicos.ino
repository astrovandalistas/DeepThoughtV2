#define smooth 20    
int oldReading = 0;    
int analogValueSmooth = 0;
int thresh = 10;
int smoothArray[smooth];
//set baud rate
int baud = 9600;

void setup()
{
  Serial.begin(baud);	
}

void loop() {
    addToArray();
    int smoothReading = findAverage();
    if (smoothReading > -1){
      int diff = smoothReading - oldReading;
     //los valores invertidos del op amp , estamos convirtiendo los numero
     Serial.write(1023-smoothReading);
     Serial.write(44); //print este no jala bien
    }
    oldReading = smoothReading;
}

void addToArray(){
      for (int i = smooth-1; i >= 1; i--){
        smoothArray[i] = smoothArray[i-1];
      }
   smoothArray[0] = analogRead(5);  
}


int findAverage(){
  int average = 0;
  for (int i = 0; i < smooth; i++){
    average += smoothArray[i];
  }
  average = average / smooth;
  return average;
}
