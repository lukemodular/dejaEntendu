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

byte led = 13;

//_______________________________________________________________
//Timing
Metro sysTimer = Metro(1);// milliseconds
unsigned int canTimer, ledTimer, monitorTimer, noteOnTimer, noteOffTimer;


//_______________________________________________________________
//variables CAN / nodeID

// passing of nodeID from bootloader done via boot_token variable - defined in linker script (.ld)
#if 1
extern int boot_token;
#else
int boot_token;
#endif
uint8_t nodeID;

int maskID = 0x07F;      // mask 7-bits for node ID - bit filtering of filterID's 0x000 opens to all messages, 0xFFF only to the messages specified
int filterID;
FlexCAN CANbus(1000000);
static CAN_message_t rxmsg,txmsg;
static CAN_filter_t mask;
static CAN_filter_t filter;

//_______________________________________________________________


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

const int defaultBrightness = 100*(255/100);    // full brightness
//const int defaultBrightness = 15 * (255 / 100); // dim: 15% brightness
const rgb24 defaultBackgroundColor = {
  0, 0, 0
};
byte colorRand;

char nodeBuffer[16];
const rgb24 whiteColor = {0xff, 0xff, 0xff};

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
// -------------------------------------------------------------

uint8_t mac[6];
uint32_t mac_id;	// use only last 3 bytes of MAC ID - as top three are always 04:E9:E5 for Teensy addr

void read(uint8_t word, uint8_t *mac, uint8_t offset) {
  FTFL_FCCOB0 = 0x41;             // Selects the READONCE command
  FTFL_FCCOB1 = word;             // read the given word of read once area

  // launch command and wait until complete
  FTFL_FSTAT = FTFL_FSTAT_CCIF;
  while (!(FTFL_FSTAT & FTFL_FSTAT_CCIF));

  *(mac + offset) =   FTFL_FCCOB5;     // collect only the top three bytes,
  *(mac + offset + 1) = FTFL_FCCOB6;   // in the right orientation (big endian).
  *(mac + offset + 2) = FTFL_FCCOB7;   // Skip FTFL_FCCOB4 as it's always 0.
}

void read_mac() {
  read(0xe, mac, 0);
  read(0xf, mac, 3);
  // our shorter MAC ID - only last 3 bytes
  mac_id = ((uint32_t)mac[3]<<16) + ((uint32_t)mac[4]<<8) + (uint32_t)mac[5];
}

void identify(uint8_t mode) {

  // send bootup message with MAC ID
  read_mac();
  txmsg.len = 7;
  txmsg.id = 0x700+nodeID;
  txmsg.buf[0] = 1;  // application sends 1, bootloader sends 0
  txmsg.buf[1]=mac[0];
  txmsg.buf[2]=mac[1];
  txmsg.buf[3]=mac[2];
  txmsg.buf[4]=mac[3];
  txmsg.buf[5]=mac[4];
  txmsg.buf[6]=mac[5];
  CANbus.write(txmsg);

  if (mode) {
    matrix.setFont(font5x7);
    matrix.fillScreen({0,0,0});
    matrix.setBrightness(15 * (255 / 100)); // 15% brightness
    matrix.swapBuffers(true);
    sprintf(nodeBuffer, "%d", nodeID);
    matrix.drawString(0,0,{255,255,255},nodeBuffer);
    matrix.drawString(0,14,{200,0,200},"ID");
    matrix.swapBuffers(true);
    delay(500); 
  }
 
} 

void jumpBootloader(void)
{
  matrix.setFont(font5x7);
  matrix.fillScreen({0,0,0});
  matrix.setBrightness(15 * (255 / 100)); // 15% brightness
  matrix.swapBuffers(true);
  sprintf(nodeBuffer, "%d", nodeID);
  matrix.drawString(0,0,{255,255,255},nodeBuffer);
  matrix.drawString(0,14,{200,0,200},"BOOT");
  matrix.swapBuffers(true);
  
  Serial.println("[jump to bootloader]");
  delay(500);
  boot_token = 0x74624346;
  __disable_irq();
  // Any invalid write to the WDOG registers will trigger an immediate reboot
  WDOG_REFRESH = 0;
  while(1);  /* wait until reset */
};


// -------------------------------------------------------------
// -------------------------------------------------------------

void setup() {

  Serial.begin(115200);


  //___________________________________
  //SETUP CAN
  
  nodeID = boot_token;
  filterID = (int)nodeID;

  mask.id = maskID;

  CANbus.begin(mask);

  filter.id = 0;   // one mailbox for nodeID 0 (global messages) 
  CANbus.setFilter(filter, 0);

  filter.id = filterID;  // mailboxes for this nodeID
  CANbus.setFilter(filter, 1);
  CANbus.setFilter(filter, 2);
  CANbus.setFilter(filter, 3);
  CANbus.setFilter(filter, 4);
  CANbus.setFilter(filter, 5);
  CANbus.setFilter(filter, 6);

  filter.id = 127;      // mailbox for bootloader messages 0x7FF
  CANbus.setFilter(filter, 7);
  
  pinMode(led, OUTPUT);
  //digitalWrite(led, 1);

  delay(2000);
  Serial.println(F("dejaNode_0.1 - Teensy 3.1 CAN Test."));
  Serial.printf("node ID: %d (0x%x)",boot_token,boot_token);
  Serial.println(" ");

  //____________________________________
  //SETUP smartMatrix
  // initialize the digital pin as an output.
  matrix.begin();
  matrix.setBrightness(defaultBrightness);
  matrix.setColorCorrection(cc24);
  //matrix.setRotation(rotation180);
  
  // display node ID
  matrix.setFont(font5x7);
  matrix.fillScreen({0,0,0});
  matrix.swapBuffers(true);
  sprintf(nodeBuffer, "%d", nodeID);
  matrix.drawString(0,0,{255,255,255},nodeBuffer);
  matrix.drawString(0,14,{200,0,200},"init");
  matrix.swapBuffers(true);
  delay(1000);
  
  // clear screen
  matrix.fillScreen(defaultBackgroundColor);
  matrix.swapBuffers(true);

  //____________________________________
  //SETUP audio
  AudioMemory(12);

  waveform1.pulseWidth(0.1);
  //waveform1.arbitraryWaveform(array, 1000);
  waveform1.begin(0.1, 175, WAVEFORM_SINE);
  //Waveforms: WAVEFORM_SINE, WAVEFORM_SQUARE, WAVEFORM_SAWTOOTH, WAVEFORM_TRIANGLE, WAVEFORM_PULSE, WAVEFORM_ARBITRARY
  //fm1.amplitude(0.5);
  //fm1.frequency(200);
  envelope1.attack(5);
  envelope1.hold(0);
  envelope1.decay(2);
  envelope1.sustain(0.8);
  envelope1.release(5);
  //larger attack and release time leads to clicks (after ~100ms)

  // Initialize processor and memory measurements
  AudioProcessorUsageMaxReset();
  AudioMemoryUsageMaxReset();


  sysTimer.reset();
    
  Serial.println("setup() done.");

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
      int rx_nodeID = rxmsg.id & 0x07F;
      int rx_cobID = rxmsg.id & 0xF80;  // mask off nodeID

      Serial.printf("msg 0x%03x l=%d  nodeID=%d cobID=0x%03x",rxmsg.id, rxmsg.len, rx_nodeID, rx_cobID);
      Serial.println("");
        
      	if ((rxmsg.id==0x7FF) && (rxmsg.len==4)) {
		if ((rxmsg.buf[0]==nodeID) && (rxmsg.buf[1]==1) && (rxmsg.buf[2]==0)  && (rxmsg.buf[3]==0x80)) {
			jumpBootloader();
		}
	}

        if ( (rx_cobID==0) && (rxmsg.len==2) && (rxmsg.buf[0]==0) ) {
          if (rx_nodeID) {
            Serial.printf("[IDENTIFY node %d]",rx_nodeID);
            Serial.println("");
          } else {
            Serial.println("[IDENTIFY all]");
          }
          identify(rxmsg.buf[1]); 
        }

        if ( (rx_cobID==0) && (rxmsg.len==2) && (rxmsg.buf[0]==1) ) {
          Serial.println("[RESET]");
          if (rxmsg.buf[1]) {
            delay(500+(nodeID*10)); // stagger the resets to help with power
          } else {
            delay(500);
          }
          __disable_irq();
          // Any invalid write to the WDOG registers will trigger an immediate reboot
          WDOG_REFRESH = 0;
          while(1);  /* wait until reset */
        }
            
 //       switch (rx_cobID) 

#if 0
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
#endif
      canTimer = 2;
    }
  }

  //_________________________________
  //audioNoteOn

  if (!noteOnTimer) {
    waveform1.frequency(175 * random(1, 4));
    //waveform1.amplitude(0.3*random(1, 5));
    envelope1.noteOn();
    //noteLength = random(500, 4000);
    noteLength = 100;
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


