// avr-libc library includes
#include <avr/io.h> //  can be omitted
#include <avr/interrupt.h> // can be omitted
#define LEDPIN 13
/* or use
DDRB = DDRB | B00100000;  // this sets pin 5  as output                       // without changing the value of the other
                         // pins 
*/
void setup()
{
pinMode(LEDPIN, OUTPUT);

// initialize Timer1
cli();         // disable global interrupts
TCCR1A = 0;    // set entire TCCR1A register to 0
TCCR1B = 0;    // set entire TCCR1A register to 0

// enable Timer1 overflow interrupt:
TIMSK1 |= (1 << TOIE1);
// Preload with value 3036
//use 64886 for 100Hz
//use 64286 for 50 Hz
//use 34286 for 2 Hz
TCNT1=0x0BDC;
// Set CS10 bit so timer runs at clock speed: (no prescaling)
TCCR1B |= (1 << CS12); // Sets bit CS12 in TCCR1B
// This is achieved by shifting binary 1 (0b00000001)
// to the left by CS12 bits. This is then bitwise
// OR-ed into the current value of TCCR1B, which effectively set
// this one bit high. Similar: TCCR1B |= _BV(CS12);
//  or: TCCR1B= 0x04;

// enable global interrupts:
sei();
}

ISR(TIMER1_OVF_vect)
{
digitalWrite(LEDPIN, !digitalRead(LEDPIN));
TCNT1=0x0BDC; // reload the timer preload
}

void loop() {}
