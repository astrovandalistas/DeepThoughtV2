import processing.serial.*;

Serial myPort;  // Create object from Serial class int val;
// Data received from the serial port 
void setup()
{
  size(200, 200);

  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 38400);
}

void draw() {
  background(255);
  if (mouseOverRect() == true) {  // If mouse is over square, 
   fill(204);                    // change color and 
    myPort.write('H');
 println("hola");   // send an H to indicate mouse is over square   }
  else {                        // If mouse is not over square,     
 fill(0);                      // change color and 
          myPort.write('L');              // send an L otherwise   }
  rect(50, 50, 100, 100);         // Draw a square }

boolean mouseOverRect() { // Test if mouse is over square 
return ((mouseX >= 50) && (mouseX <= 150) && (mouseY >= 50) && (mouseY <= 150));
}
