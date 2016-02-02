/* stepper motor pins */
int XM1 = 9;
int XM2 = 11;
int XM3 = 10;
int XM4 = 12;
int YM1 = 5;
int YM2 = 7;
int YM3 = 6;
int YM4 = 8;
/* Limit switches */
int LimX = A0;
int LimY = A1;
/* delay between each step change */
const int delayTime = 3;
/* direction mode */
int dirX;
int dirY;
#define DIR_LEFT 1
#define DIR_RIGHT 2
/* step mode */
int modeX;
int modeY;
#define STEP_WAVE 1
#define STEP_FULL 2
#define STEP_HALF 3
uint8_t lastwavestepX;
uint8_t lastwavestepY;
/* positional status */
unsigned int stepStatusX;
unsigned int stepStatusY;


void zero();
void stepX();
void stepY();
uint8_t fourBitShift(uint8_t val);
void setup() {
  Serial.begin(9600);



Serial.println("HELLO, PLEASE ENTER CONFIG SETTINGS: X1A X1B X2A X2B Y1A Y1B Y2A Y2B LIMITX LIMITY");
/* dont need this for time being */
/*
while (Serial.available() ==0) {}
  XM1 = Serial.parseInt();
  XM2 = Serial.parseInt();
  XM3 = Serial.parseInt();
  XM4 = Serial.parseInt();
  YM1 = Serial.parseInt();
  YM2 = Serial.parseInt();
  YM3 = Serial.parseInt();
  YM4 = Serial.parseInt();
  LimX = Serial.parseInt();
  LimY = Serial.parseInt();
 */
 if ((XM1 +XM2 + XM3 + XM4) > 0 && (YM1 +YM2 + YM3 + YM4) > 0 && (LimX + LimY) > 0)
    Serial.println("OK");  
  pinMode(XM1, OUTPUT);
  pinMode(XM2, OUTPUT);
  pinMode(XM3, OUTPUT);
  pinMode(XM4, OUTPUT);
  pinMode(YM1, OUTPUT);
  pinMode(YM2, OUTPUT);
  pinMode(YM3, OUTPUT);
  pinMode(YM4, OUTPUT);
  
  pinMode(LimX, INPUT);
  pinMode(LimY, INPUT);
  /* set pullups */
  digitalWrite(LimX, HIGH);
  digitalWrite(LimY, HIGH);

  /* intialise all motor states */
    modeX = STEP_WAVE;
  modeY = STEP_WAVE;
  stepStatusX = 0B0011; // 3 for FULL step and 1 for WAVE/HALF Step
  stepStatusY = 3; // 3 for FULL step and 1 for WAVE/HALF Step
  lastwavestepX = 0B1001;
    lastwavestepY = 0B1001;
  Serial.println("ZEROING ALL AXES");
  zero();
}

void zero()
{
  // for each axis step all the way until a limit is met.
  dirX = DIR_RIGHT;
  dirY = DIR_LEFT;
  Serial.println(stepStatusX);
  while (digitalRead(LimX) == 1)
  {
    stepX();
    Serial.println(stepStatusX);
    delay(delayTime);
  }
  Serial.println("X ZEROED");
  while (digitalRead(LimY) == 1)
  {
    stepY();
    delay(delayTime);
  }
}

uint8_t fourBitShiftRight(uint8_t val)
{
  return   ((((val & 0B1000) >> 3) | (val << 1 )) & 0B1111);
}
uint8_t fourBitShiftLeft(uint8_t val)
{
  return   ((((val & 0B1000) << 3) | (val >> 1 )) & 0B1111);
}

void stepX()
{
  if (modeX == STEP_HALF)
  {
     uint8_t currentstep = 0;
      if (stepStatusX == 2 || stepStatusX == 4 || stepStatusX == 8 || stepStatusX == 1)
      {// power of 2
        if (dirX == DIR_LEFT)
         currentstep =  fourBitShiftRight(lastwavestepX);
        else
         currentstep =  fourBitShiftLeft(lastwavestepX);
      }
      else
      { 
        if (dirX == DIR_LEFT)
          currentstep = fourBitShiftLeft(lastwavestepX);
        else
          currentstep = fourBitShiftRight(lastwavestepX);
      }
      lastwavestepX = stepStatusX;
      stepStatusX = currentstep;
  }
  else
  {
    // WAVE STEP AND FULL STEP, Simply shift output.
    if (dirX == DIR_LEFT)
      stepStatusX = fourBitShiftLeft(stepStatusX);
    else
      stepStatusX = fourBitShiftRight(stepStatusX);
  }
  
digitalWrite(XM1, (stepStatusX & 0B1000) >> 3);
digitalWrite(XM2, (stepStatusX & 0B0100) >> 2);
digitalWrite(XM3, (stepStatusX & 0B0010) >> 1);
digitalWrite(XM4, (stepStatusX & 0B0001));
}
void stepY()
{
  // update the next output and output it.
if (dirY == DIR_LEFT)
  stepStatusY = (((stepStatusY & 0B1000) >> 3) | (stepStatusY << 1 ));
else
  stepStatusY = (((stepStatusY & 0B1) << 3) | (stepStatusY >> 1));

stepStatusY = stepStatusY & 0B1111;
digitalWrite(YM1, (stepStatusY & 0B1000) >> 4);
digitalWrite(YM2, (stepStatusY & 0B0100) >> 3);
digitalWrite(YM3, (stepStatusY & 0B0010) >> 2);
digitalWrite(YM4, (stepStatusY & 0B0001) >> 1);
}
void loop() {
 while (Serial.available() ==0) {}
 
}
