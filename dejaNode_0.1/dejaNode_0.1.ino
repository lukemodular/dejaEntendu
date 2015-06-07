//________________________________________________________________
//dejaEntendu node


/*TODO:
 (globalLight, globalVolume)
 -flags: noteOn, noteOff(--> noteOn), newFrame(1.erease, 2. case(font1, font2, scroll)ds, 3.draw) 

 */

#include <SmartMatrix_32x32.h>
#include <Metro.h>
#include <FlexCAN.h>
#include <EEPROM.h>
#include <Audio.h>
#include <Wire.h>
#include <SPI.h>
#include <SD.h>

SmartMatrix matrix;

//_______________________________________________________________
//Timing
Metro sysTimer = Metro(1);// milliseconds
unsigned int canTimer, ledTimer, monitorTimer, noteOnTimer, noteOffTimer;

//_______________________________________________________________
//variables CAN
byte led = 13;
int maskID = 0xFFF;      //bit filtering of filterID's 0x000 opens to all messages, 0xFFF only to the messages specified
int filterID;

// Our adress we listen to
byte filterid_in_eeprom = 0;
FlexCAN CANbus(1000000);
static CAN_message_t rxmsg;
static CAN_filter_t mask;
static CAN_filter_t filter;
static uint8_t hex[17] = "0123456789abcdef";
byte x_msg;
byte y_msg;
byte c_msg;
byte red;
byte green;
byte blue;
byte frameBuf[1024];
byte test;
int bufCount = 0;
int pxlCount = 0;

//________________________________________________________________
//variables smartMatrix

//const int defaultBrightness = 100*(255/100);    // full brightness
const int defaultBrightness = 15 * (255 / 100); // dim: 15% brightness
const rgb24 defaultBackgroundColor = {
  0, 0, 0
};
byte colorRand;

//________________________________________________________________
//variables Audio

AudioSynthWaveform       waveform1;
AudioSynthWaveformSineModulated fm1;
AudioEffectEnvelope      envelope1;
AudioOutputAnalog        out;
AudioConnection          patchCord1(waveform1, envelope1);
//AudioConnection          patchCord2(fm1, envelope1);
AudioConnection          patchCord2(envelope1, out);
int noteLength;


// -------------------------------------------------------------
void setup() {
  
  
    //____________________________________
  //SETUP audio
  AudioMemory(12);

  waveform1.begin(0.3, 175, WAVEFORM_SINE);
  //Waveforms: WAVEFORM_SINE, WAVEFORM_SQUARE, WAVEFORM_SAWTOOTH, WAVEFORM_TRIANGLE, WAVEFORM_PULSE, WAVEFORM_ARBITRARY
  //waveform1.pulseWidth(0.1);
  envelope1.attack(0);
  envelope1.hold(0);
  envelope1.decay(2);
  envelope1.sustain(0.8);
  envelope1.release(1);
  //larger attack and release time leads to clicks (after ~100ms)

  // Initialize processor and memory measurements
  AudioProcessorUsageMaxReset();
  AudioMemoryUsageMaxReset();
  

  //Serial.begin(115200);


  //___________________________________
  //SETUP CAN

  // Pull filter address out of eeprom
  filterID = EEPROM.read(filterid_in_eeprom);
  mask.id = maskID;
  filter.id = filterID;
  CANbus.begin(mask);
  CANbus.setFilter(filter, 0);
  CANbus.setFilter(filter, 1);
  CANbus.setFilter(filter, 2);
  CANbus.setFilter(filter, 3);
  CANbus.setFilter(filter, 4);
  CANbus.setFilter(filter, 5);
  CANbus.setFilter(filter, 6);
  CANbus.setFilter(filter, 7);
  pinMode(led, OUTPUT);
  //digitalWrite(led, 1);

  delay(2000);
  Serial.println(F("Hello Teensy 3.1 CAN Test."));
  Serial.print("filteID: ");
  Serial.println(filterID, HEX);

  //____________________________________
  //SETUP smartMatrix
  // initialize the digital pin as an output.

  matrix.begin();
  matrix.setBrightness(defaultBrightness);
  matrix.setColorCorrection(cc24);
  //matrix.setRotation(rotation180);


  sysTimer.reset();

}



// -------------------------------------------------------------
void loop() {


  // service software timers based on Metro tick
  if ( sysTimer.check() ) {
    if ( canTimer ) {
      --canTimer;
    }
    if ( ledTimer ) {
      --ledTimer;
    }
    if ( monitorTimer ) {
      --monitorTimer;
    }
    if ( noteOnTimer ) {
      --noteOnTimer;
    }
    if ( noteOffTimer ) {
      --noteOffTimer;
    }
  }



  //_______________________________
  //CAN

  if (!canTimer) {
    while ( CANbus.read(rxmsg) ) {
//             Serial.print("msg.id: ");
//              Serial.println(rxmsg.id, HEX);
//              Serial.print("msg.extended: ");
//              Serial.println(rxmsg.ext);
//              Serial.print("msg.len: ");
//              Serial.println(rxmsg.len);
//              Serial.print("msg.timeout: ");
//              Serial.println(rxmsg.timeout);
      for (int i = 0; i < 8; i++) {
          frameBuf[bufCount] = rxmsg.buf[i] - 48;
          bufCount++;
        }
      }
    if (bufCount > 1023) {
        bufCount = 0;
      }
    //    for (int i = 0; i < 1024; i++) {
    //    frameBuf[i] = random(0, 2);
    //  }
    canTimer = 2;
  }

  //_________________________________
  //audioNoteOn

  if (!noteOnTimer) {
    waveform1.frequency(175 * random(1, 4));
    //waveform1.amplitude(0.3*random(1, 5));
    envelope1.noteOn();
    //noteLength = random(500, 4000);
    noteLength = 2;
    noteOnTimer = 2000;        //note happend???
    noteOffTimer = noteLength;
  }

  //_________________________________
  //smartMatrix

  if (!ledTimer) {
    int pxlCount = 0;
    matrix.swapBuffers(true);
    //matrix.fillScreen(defaultBackgroundColor);
    //matrix.swapBuffers(true);
    test = frameBuf[0];
    for (int x = 0; x < 32; x++) {
      for (int y = 0; y < 32; y++) {
        if (frameBuf[pxlCount] == 1) {
          //matrix.drawChar(x, y, {r, g, b}, text[i]);  //random(65, 90) 122
          //matrix.swapBuffers(true);
          c_msg = 255;
          green = map(c_msg, 0, 255, 0, 230);
          blue = map(c_msg, 0, 255, 0, 240);
          matrix.drawPixel(x, y, {
            c_msg, green, blue
          }
                          );

        }
        if (frameBuf[pxlCount] == 0)  {
          c_msg = 0;
          green = map(c_msg, 0, 255, 0, 230);
          blue = map(c_msg, 0, 255, 0, 240);
          matrix.drawPixel(x, y, {
            c_msg, green, blue
          }
                          );

        }
        pxlCount++;
      }
    }
    ledTimer = 20;
            //matrix.setScrollColor({0xff, 0xff, 0xff});
        //matrix.setScrollMode(wrapForward);
        //matrix.setScrollSpeed(40);
    //matrix.setScrollOffsetFromEdge(y);
            //matrix.setScrollFont(font5x7);
        //matrix.scrollText("Position Scrolling Text Anywhere", 1);
  }

  //_________________________________
  //audioNoteOff

  if (!noteOffTimer) {
    envelope1.noteOff();
    noteOffTimer = 2000;
    noteOnTimer = 1000;
  }

}





//
//
//  //___________________________
//  //System Monitor
//
//  if (!monitorTimer) {
//    Serial.print("Proc = ");
//    Serial.print(AudioProcessorUsage());
//    Serial.print(" (");
//    Serial.print(AudioProcessorUsageMax());
//    Serial.print("),  Mem = ");
//    Serial.print(AudioMemoryUsage());
//    Serial.print(" (");
//    Serial.print(AudioMemoryUsageMax());
//    Serial.println(")");
//    monitorTimer = 5000;
//  }






//  if (ledMetro2.check()) {
//
////        matrix.setScrollColor({0xff, 0xff, 0xff});
////        matrix.setScrollMode(wrapForward);
////        matrix.setScrollSpeed(20);
////        matrix.setScrollOffsetFromEdge(y_msg);
////
////        matrix.setScrollFont(font3x5);
////        matrix.scrollText("DEJA", 1);
////        while (matrix.getScrollStatus());
//
//    matrix.swapBuffers(true);
//    //    matrix.drawChar(x_msg, y_msg, {
//    //      0xff, 0xff, 0xff        }
//    //    , 'A');
//    matrix.drawString(x_msg-8, y_msg-8, {
//      0xff, 0xe6, 0xf0           }
//    , "DEJA");
//
//  }



//    for (int x = 0; x < 32; x++) {
//      for (int y = 0; y < 32; y++) {
//        colorRand = random(0, 255);
//        matrix.drawPixel(x_msg, y_msg, {
//          colorRand, colorRand, colorRand        }
//        );
//      }
//    };


