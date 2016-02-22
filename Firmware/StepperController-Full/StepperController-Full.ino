/// This is a cut down version of the Stepper Firmware. 
/// It offers ONLY FULL STEPPING but does actually work in both directions
/// it is mainly being used to test pruposes and to tweak the acceleration logic
/* stepper motor pins, NOTE ORDER: A1 B1 A2 B2 */
uint8_t XM1 = 9, XM2 = 11, XM3 = 10, XM4 = 12;
uint8_t YM1 = A0, YM2 = A2, YM3 = A1, YM4 = A3; // use analog pins for Y axis.
/* Limit switches, make sure to check at what end of end stop*/
uint8_t LimX = 7, LimY = 8;
/* min delay between each step change */
uint16_t minDelayTime = 1000, maxDelayTime = 5000;
/* what direction each motor rotates in */
uint8_t dirX, dirY;
#define DIR_LEFT 1
#define DIR_RIGHT 2

/* current phase/output of the stepper*/
uint8_t stepStatusX, stepStatusY;

/* command max length */
// MOTOR MODE SPEED DIRECTION DISTANCE HOLD
// 1     1    1     1          2 + 1    1   = 8
#define COMMAND_LENGTH 8


/* prototypes */
void zero();  // rotate each motor to one end until the limit switch is hit, now we know the posn.
void stepX(); // make the Xmotor step
void stepY(); // make the Ymotor step
uint8_t fourBitShiftRight(uint8_t val); // barrel shift right
uint8_t fourBitShiftLeft(uint8_t val);  // barrel shift left
void stopMotorX(); // disable output -- stops motor from being active
void stopMotorY(); // disable output -- stops motor from being active

// step program initialises serial connection and Zeroes (no hold) axes.
void setup() {
  Serial.begin(9600);
  Serial.println("STEPPER V1. ENTER CONFIG");
  while (Serial.available() == 0) {} // wait for serial data
  minDelayTime = Serial.parseFloat() * 1000;
  maxDelayTime = Serial.parseFloat() * 1000;
  Serial.println(minDelayTime, DEC);
  Serial.println(maxDelayTime, DEC);
  //sanity check that configuration is ok.
  if (minDelayTime > 0)
    Serial.println("OK WAIT");




  //Setup ports
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
  /* set pullups on limit switches */
  digitalWrite(LimX, HIGH);
  digitalWrite(LimY, HIGH);

  // initialise motor states
  stepStatusX = 0B0011;
  stepStatusY = 0B0011;
  // zero the aixs
  Serial.println("ZEROING ALL AXES");
  zero();
  // tell the program we are ready to take commands
  while (Serial.available() != 0) {
    Serial.read(); // make sure serial buffer is empty.
  }
  Serial.println("OK WAIT");
}

void zero()
{
  // for each axis step all the way until a limit is met.
  dirX = DIR_RIGHT;
  dirY = DIR_LEFT;
  //while limit switch is not triggered, keep stepping.
  while (digitalRead(LimX) == 1)
  {
    stepX(); // step
    delayMicroseconds(minDelayTime); // wait min delay time
  }
  stopMotorX();
  while (digitalRead(LimY) == 1)
  {
    stepY();
    delayMicroseconds(minDelayTime);
  }
  stopMotorY();
}

uint8_t fourBitShiftRight(uint8_t val)
{
  return   (((val & 0B1000) >> 3) | (val << 1 )) & 0B1111; // take the left hand digit, insert it on the right.
}
uint8_t fourBitShiftLeft(uint8_t val)
{
  return   ((((val & 0B1) << 3) & 0b1000) | ((val >> 1 ) & 0b0111)) & 0B1111; // take the left hand digit, insert it on the right.
}

void stepX()
{
  //  Simply shift output.
  if (dirX == DIR_LEFT)
    stepStatusX = fourBitShiftLeft(stepStatusX);
  else
    stepStatusX = fourBitShiftRight(stepStatusX);
  // and output the new motor poles
  digitalWrite(XM1, (stepStatusX & 0B1000) >> 3);
  digitalWrite(XM2, (stepStatusX & 0B0100) >> 2);
  digitalWrite(XM3, (stepStatusX & 0B0010) >> 1);
  digitalWrite(XM4, (stepStatusX & 0B0001));
}
void stepY()
{
  // Simply shift output.
  if (dirY == DIR_LEFT)
    stepStatusY = fourBitShiftLeft(stepStatusY);
  else
    stepStatusY = fourBitShiftRight(stepStatusY);
  // output the new motor state
  digitalWrite(YM1, (stepStatusY & 0B1000) >> 3);
  digitalWrite(YM2, (stepStatusY & 0B0100) >> 2);
  digitalWrite(YM3, (stepStatusY & 0B0010) >> 1);
  digitalWrite(YM4, (stepStatusY & 0B0001));
}
void stopMotorX()
{
  // If motor state is left, the coils will remain energised so we stop it.
  digitalWrite(XM1, LOW);
  digitalWrite(XM2, LOW);
  digitalWrite(XM3, LOW);
  digitalWrite(XM4, LOW);
}
void stopMotorY()
{
  // If motor state is left, the coils will remain energised so we stop it.
  digitalWrite(YM1, LOW);
  digitalWrite(YM2, LOW);
  digitalWrite(YM3, LOW);
  digitalWrite(YM4, LOW);
}
void loop() {
  byte command[COMMAND_LENGTH];
  // initialise to zero
  for (uint8_t val = 0; val <= (COMMAND_LENGTH - 1); val ++)
    command[val] = 0x00;

  uint8_t hasWholeCommand = 0;
  uint8_t charCount = 0;
  while (0 == hasWholeCommand)
  {
    while (0 == Serial.available()) {} // wait for at least one byte of data.
    byte charIn = Serial.read(); // read 1 byte
    if (charCount < (COMMAND_LENGTH - 1))
    {
      command[charCount] = charIn;
      charCount++;
    }
    else if ('\n' == charIn) // if we received last character and have a full compliment of data
      hasWholeCommand = 1; //set flag to show we have whole payload
  }
  if (command[0] == 0x00)
    return; // the command is blank, quit this loop.
  /*
   * ACTUALLY PROCESS THE COMMAND
   */
  // get the total number of revs and steps requested.
  uint16_t revs = 0;
  revs = (command[4] << 8) | command[5];
  uint8_t steps = 0;
  steps = command[6];
  uint64_t totalStep = 0;
  totalStep = (revs * 200) + steps;
  if (command[0] == 0x1) // motorX
  {
    if (command[3] == 0x1) // LEFT
      dirX = DIR_LEFT;
    else if (command[3] == 0x2) // RIGHT
      dirX = DIR_RIGHT;

    //actually step the motor
    if (command[2] == 0x1) // FAST
    {
      for ( uint64_t rev = 0; rev <= totalStep; rev++)
      {
        stepX();
        delayMicroseconds(minDelayTime);
      }
    }
    else if (command[2] == 0x2) // SLOW
      for ( uint64_t rev = 0; rev <= totalStep; rev++)
      {
        stepX();
        delayMicroseconds(maxDelayTime);
      }
    else if (command[2] == 0x3) // DYNAMIC
    {
      uint16_t currentDelay = maxDelayTime;
      for ( uint64_t rev = 0; rev <= totalStep; rev++)
      {
        if ((rev > totalStep - 600))
        {
          if (currentDelay < maxDelayTime)
            currentDelay = currentDelay + 25;
        }
        else if (rev < 600)
        { // accelerate
          if (currentDelay > minDelayTime)
            currentDelay = currentDelay - 122;
          else
            currentDelay = minDelayTime;
        }
        stepX();
        delayMicroseconds(currentDelay);
      }
    }
    if (command[7] != 0x00)
    {
      delay(command[7]);
    }
    stopMotorX();
  }
  else if (command[0] == 0x2) //motorY
  {
    if (command[3] == 0x1) // LEFT
      dirY = DIR_LEFT;
    else if (command[3] == 0x2) // RIGHT
      dirY = DIR_RIGHT;

    //actually step the motor
    if (command[2] == 0x1) // FAST
      for ( uint64_t rev = 0; rev <= totalStep; rev++)
      {
        stepY();
        delayMicroseconds(minDelayTime);
      }
    else if (command[2] == 0x2) // SLOW
      for ( uint64_t rev = 0; rev <= totalStep; rev++)
      {
        stepY();
        delayMicroseconds(maxDelayTime);
      }
    else if (command[2] == 0x3) // DYNAMIC
    {
      uint16_t currentDelay = maxDelayTime;
      for ( uint64_t rev = 0; rev <= totalStep; rev++)
      {
        if ((rev > totalStep - 600))
        {
          if (currentDelay < maxDelayTime)
            currentDelay = currentDelay + 25;
        }
        else if (rev < 600)
        { // accelerate
          if (currentDelay > minDelayTime)
            currentDelay = currentDelay - 122;
          else
            currentDelay = minDelayTime;
        }
        stepY();
        delayMicroseconds(currentDelay);
      }
    }
    if (command[7] != 0x00)
    {
      delay(command[7]);
    }
    stopMotorY();
  }
  free(command);
  Serial.println("OK DONE");
}

