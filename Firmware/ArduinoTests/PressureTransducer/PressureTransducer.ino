#include <Wire.h>

void setup()
{
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
}

void loop()
{
  uint16_t val = 0x0000;
  Wire.requestFrom(0x28, 16);  

  while(Wire.available())    // slave may send less than requested
  { 
    val = (Wire.read()<<8); // receive a byte as character
    val = val | Wire.read(); // receive a byte as character
  }
  Serial.println(val,DEC);

  delay(10);
}
