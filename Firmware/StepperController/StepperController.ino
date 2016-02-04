/* stepper motor pins, NOTE ORDER: A1 B1 A2 B2 */
uint8_t XM1 = 9, XM2 = 11, XM3 = 10, XM4 = 12;
uint8_t YM1 = A0, YM2 = A2, YM3 = A1, YM4 = A4; // use analog pins for Y axis.
/* Limit switches, make sure to check at what end of end stop*/
uint8_t LimX = 7, LimY = 8;
/* min delay between each step change */
uint16_t minDelayTime = 1000, maxDelayTime = 5000;
/* what direction each motor rotates in */
uint8_t dirX, dirY;
#define DIR_LEFT 1
#define DIR_RIGHT 2
/* what mode the stepper motor is controlled as */
uint8_t modeX, modeY;
#define STEP_WAVE 1
#define STEP_FULL 2
#define STEP_HALF 3

/* current phase/output of the stepper*/
uint8_t stepStatusX, stepStatusY;
/* if half stepping, we need some extra variables - the previous state */
uint8_t lastHalfStepX, lastHalfStepY;

/* command max length */
// MOTOR MODE SPEED DIRECTION DISTANCE
// 1      1    1       1        2 + 1 = 7
#define MAX_COMMAND_LENGTH 7 


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
  Serial.println("HELLO, PLEASE ENTER CONFIG SETTINGS: MINDELAY (=1) MAXDELAY (=10)");
  while (Serial.available() ==0) {} // wait for serial data
  minDelayTime = Serial.parseInt();
  maxDelayTime = Serial.parseInt();
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

  /* intialise all motor states */
  modeX = STEP_HALF; // default to half wave drive
  modeY = STEP_HALF; // default to half wave drive
  // initialise motor states
  lastHalfStepX = 0B1001; stepStatusX = 0B0011;
  lastHalfStepY = 0B1001; stepStatusY = 0B0011; 
  // zero the aixs
  Serial.println("ZEROING ALL AXES");
  zero();
  // tell the program we are ready to take commands
  Serial.println("OK READY");
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
  return   (((val & 0B0001) << 3) | (val >> 1 )) & 0B1111; // take the right hand digit and insert it on the left.
}

void stepX()
{
  if (modeX == STEP_HALF)// if half stepping, use a different routine
  {
     uint8_t currentstep = 0; // variable to hold new step
     if (dirX == DIR_LEFT)
      currentstep = fourBitShiftLeft(lastHalfStepX); // perform the shift on the previous state
     else
      currentstep = fourBitShiftRight(lastHalfStepX);
     lastHalfStepX = stepStatusX; // put the current state into the previous state variable
     stepStatusX = currentstep; // load up the new current state
  }
  else
  {
    // WAVE STEP AND FULL STEP, Simply shift output.
    if (dirX == DIR_LEFT)
      stepStatusX = fourBitShiftLeft(stepStatusX);
    else
      stepStatusX = fourBitShiftRight(stepStatusX);
  }
  // and output the new motor poles
digitalWrite(XM1, (stepStatusX & 0B1000) >> 3);
digitalWrite(XM2, (stepStatusX & 0B0100) >> 2);
digitalWrite(XM3, (stepStatusX & 0B0010) >> 1);
digitalWrite(XM4, (stepStatusX & 0B0001));
}
void stepY()
{
  if (modeY == STEP_HALF) // if half stepping use a different routine
  {
     uint8_t currentstep = 0; // variable to hold new step
     if (dirY == DIR_LEFT)
      currentstep = fourBitShiftLeft(lastHalfStepY); // perform shift on previous state
     else
      currentstep = fourBitShiftRight(lastHalfStepY);
     lastHalfStepY = stepStatusY; // put the current state into the last state
     stepStatusY = currentstep; // update the output
  }
  else
  {
    // WAVE STEP AND FULL STEP, Simply shift output.
    if (dirY == DIR_LEFT)
      stepStatusY = fourBitShiftLeft(stepStatusY);
    else
      stepStatusY = fourBitShiftRight(stepStatusY);
  }
  // output the new motor state
digitalWrite(YM1, (stepStatusY & 0B1000) >> 4);
digitalWrite(YM2, (stepStatusY & 0B0100) >> 3);
digitalWrite(YM3, (stepStatusY & 0B0010) >> 2);
digitalWrite(YM4, (stepStatusY & 0B0001) >> 1);
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
  byte * command = (byte*) malloc(MAX_COMMAND_LENGTH);
  // initialise to zero
  for (uint8_t val = 0; val <= (MAX_COMMAND_LENGTH - 1); val ++)
    command[val] = 0x00;
  uint8_t hasWholeCommand = 0;
  uint8_t charCount = 0;
  while(0 == hasWholeCommand)
  {
    while(0 == Serial.available()) {} // wait for at least one byte of data.
    byte charIn = Serial.read();
    if ('\r' != charIn &&  '\n' != charIn)
    {
      command[charCount] = charIn;
      charCount++;
    }
    if (0xA == charIn)
      hasWholeCommand = 1; //set flag to show we have whole byte 
  }
  if (command[0] == 0x00)
    return; // the command is blank, quit this loop.
/*
 * ACTUALLY PROCESS THE COMMAND
 */
  // get the total number of revs and steps requested.
uint16_t revs = (command[4] << 8) | command[5];
uint8_t steps = command[6];
  
  if (command[0] == 0x1) // motorX
  {
     if (command[3] == 0x1) // LEFT
      dirX = DIR_LEFT;
     else if (command[3] == 0x2) // RIGHT
      dirX = DIR_RIGHT;

    if (command[1] == 0x1) // HALF
      modeX = STEP_HALF;
    else if (command[1] == 0x2) //WAVE  
      modeX = STEP_WAVE;
    else if (command[1] == 0x2) //FULL  
      modeX = STEP_FULL;

    //actually step the motor
     if (command[2] == 0x1) // FAST
   for ( uint16_t rev = 0; rev <= revs; rev++)
   {
    stepX();
    delayMicroseconds(minDelayTime);
   }
  else if (command[2] == 0x2) // SLOW  
   for ( uint16_t rev = 0; rev <= revs; rev++)
   {
    stepX();
    delayMicroseconds(maxDelayTime);
   }
  else if (command[2] == 0x2) // DYNAMIC
  {
   uint32_t totalStep = (revs * 200) + steps;
   uint16_t currentDelay = maxDelayTime;
   uint16_t accn = 933.34;
   uint16_t newdelay = 0;
   for ( uint16_t rev = 0; rev <= revs; rev++)
   {
    if (newdelay > 1200)
      newdelay = 1/(66.66 + (millis() * accn * 1000));
     stepX();
     delayMicroseconds(currentDelay);
   }
  }



      
  }
  else if (command[0] == 0x2) //motorY
  {
     if (command[3] == 0x1) // LEFT
      dirY = DIR_LEFT;
     else if (command[3] == 0x2) // RIGHT
      dirY = DIR_RIGHT;

    if (command[1] == 0x1) // HALF
      modeY = STEP_HALF;
    else if (command[1] == 0x2) //WAVE  
      modeY = STEP_WAVE;
    else if (command[1] == 0x2) //FULL  
      modeY = STEP_FULL;


          //actually step the motor
     if (command[2] == 0x1) // FAST
   for ( uint16_t rev = 0; rev <= revs; rev++)
   {
    stepY();
    delayMicroseconds(minDelayTime);
   }
  else if (command[2] == 0x2) // SLOW  
   for ( uint16_t rev = 0; rev <= revs; rev++)
   {
    stepY();
    delayMicroseconds(maxDelayTime);
   }
  else if (command[2] == 0x2) // DYNAMIC
  {
   uint32_t totalStep = (revs * 200) + steps;
   uint16_t currentDelay = maxDelayTime;
   uint16_t accn = 933.34;
   uint16_t newdelay = 0;
   for ( uint16_t rev = 0; rev <= revs; rev++)
   {
    if (newdelay > 1200)
      newdelay = 1/(66.66 + (millis() * accn * 1000));
     stepY();
     delayMicroseconds(currentDelay);
   }
  }

  }
 

 
  
 
      
free(command);
  Serial.println("OK DONE"); 
}

