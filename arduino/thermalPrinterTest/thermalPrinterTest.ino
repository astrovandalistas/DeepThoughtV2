/* Example 38.1 - Sparkfun Thermal Printer Test
(COM-10438) http://tronixstuff.wordpress.com/tutorials >
chapter 38 Based on code by Nathan Seidle of Spark Fun Electronics 2011 

http://littlebirdelectronics.com/products/thermal-printer

 get serial order from processing and print. Leslie Garcia. 2011 - DeepThoughtV2 */

#include <NewSoftSerial.h>
NewSoftSerial Thermal(2, 3); // printer RX to digital 2, printer TX to digital 3 
#define FALSE  0
#define TRUE  1
int printUpSideDown = TRUE;
int heatTime = 255; //80 is default from page 23 of datasheet. Controls speed of printing and darkness int heatInterval = 255; //2 is default from page 23 of datasheet. Controls speed of printing and darkness char printDensity = 20; //Not sure what the defaut is. Testing shows the max helps darken text. From page 23. char printBreakTime = 15; //Not sure what the defaut is. Testing shows the max helps darken text. From page 23. char val;

void setup()
{
  Serial.begin(38400); // for debug info to serial monitor   Thermal.begin(19200); // to write to our new printer   initPrinter();
}

void initPrinter()
{
  //Modify the print speed and heat   Thermal.print(27, BYTE);
  Thermal.print(55, BYTE);
  Thermal.print(7, BYTE); //Default 64 dots = 8*('7'+1)   Thermal.print(heatTime, BYTE); //Default 80 or 800us   Thermal.print(heatInterval, BYTE); //Default 2 or 20us   //Modify the print density and timeout   Thermal.print(18, BYTE);
  Thermal.print(35, BYTE);
  int printSetting = (printDensity<<4) | printBreakTime;
  Thermal.print(printSetting, BYTE); //Combination of printDensity and printBreakTime   Serial.println();
  Serial.println("Printer ready");
}

void loop()
{
if (Serial.available()) {
  val = Serial.read(); // read it and store it in val }
 if (val == 'H') {
  Thermal.println("DeepThought V2");
  Thermal.print(10, BYTE);
  Thermal.print(10, BYTE); //Sends the LF to the printer, advances the paper   Thermal.print("hellow world");
  Thermal.print(10, BYTE);
  Thermal.print(10, BYTE);
  Thermal.print("print: Twitter - DTV2.");
  Thermal.print(10, BYTE);
  Thermal.print("by: DREAMADDICTIVE");
  Thermal.print(10, BYTE);
  Thermal.print("http://dalab.ws/dtv2 ");   Thermal.println(millis());
  Thermal.print(10, BYTE);
  Thermal.print(10, BYTE);
  do { } while (1>0);
  }
 }
