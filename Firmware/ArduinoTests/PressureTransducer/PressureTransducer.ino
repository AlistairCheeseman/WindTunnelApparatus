#include <Wire.h>

void setup()
{
delay(1000);
delay(1000);  
  Wire.begin();        // join i2c bus (address optional for master)
  Serial.begin(9600);  // start serial for output
  //Wire.setClock(400000L);
}

void loop()
{
  uint16_t val = 0x0000;
  Wire.requestFrom(0x28, 2);
  while(Wire.available())
  {
    val = (Wire.read()<<8); // receive a byte as character
    val = val | Wire.read(); // receive a byte as character  
    }  
  uint8_t sensstatus  = (val >> 14);
  if (sensstatus)
  {
  Serial.println("Error");
  Serial.println(sensstatus, BIN);
  }
  
  Serial.println(val,DEC);

  delay(100);
}
