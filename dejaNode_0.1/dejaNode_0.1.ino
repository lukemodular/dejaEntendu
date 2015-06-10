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

byte fw_version = 3;
//const char fw_date = "10-jun-2015";


const char* phrase[] = { 
  "deja entendu", 
  "vraiment pas pire", 
  "geniale", 
  "Ostie!"
};

int phrase_count = 4;


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

//const int defaultBrightness = 100*(255/100);    // full brightness
const int defaultBrightness = 15 * (255 / 100); // dim: 15% brightness
const rgb24 defaultBackgroundColor = { 0, 0, 0 };
byte colorRand;

char nodeBuffer[16];
const rgb24 whiteColor = {0xff, 0xff, 0xff};

//________________________________________________________________
//variables Audio

// GUItool: begin automatically generated code
AudioSynthWaveformSineModulated sine_fm1;       //xy=145,290
AudioSynthWaveform       waveform1;      //xy=146,174
AudioEffectEnvelope      envelope1;      //xy=308,174
AudioEffectFade          fade1;          //xy=466,237
AudioEffectFade          fade2;          //xy=466,292
AudioMixer4              mixer1;         //xy=654,299
AudioOutputAnalog        out;           //xy=853,299
AudioConnection          patchCord1(sine_fm1, fade2);
AudioConnection          patchCord2(waveform1, envelope1);
AudioConnection          patchCord3(envelope1, fade1);
AudioConnection          patchCord4(fade1, 0, mixer1, 0);
AudioConnection          patchCord5(fade2, 0, mixer1, 1);
AudioConnection          patchCord6(mixer1, out);
// GUItool: end automatically generated code

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
  txmsg.len = 8;
  txmsg.id = 0x700+nodeID;
  txmsg.buf[0] = 1;  // application sends 1, bootloader sends 0
  txmsg.buf[1]=mac[0];
  txmsg.buf[2]=mac[1];
  txmsg.buf[3]=mac[2];
  txmsg.buf[4]=mac[3];
  txmsg.buf[5]=mac[4];
  txmsg.buf[6]=mac[5];
  txmsg.buf[7]=fw_version;
  CANbus.write(txmsg);

  if (mode) {
    matrix.setFont(font5x7);
    matrix.fillScreen({0,0,0});
    matrix.setBrightness(15 * (255 / 100)); // 15% brightness
    matrix.swapBuffers(true);
    sprintf(nodeBuffer, "%d", nodeID);
    matrix.drawString(0,0,{255,255,255},nodeBuffer);
    matrix.drawString(0,14,{200,0,200},"ID");
    sprintf(nodeBuffer, "v%d", fw_version);
    matrix.drawString(0,24,{120,120,120},nodeBuffer);
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
  sprintf(nodeBuffer, "v%d", fw_version);
  matrix.drawString(0,24,{120,120,120},nodeBuffer);
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

  mixer1.gain(0,1.0);
  
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

// ------------ 000h(+nodeID) IDENTIFY--------------------

        if ( (rx_cobID==0) && (rxmsg.len==2) && (rxmsg.buf[0]==0) ) {
          if (rx_nodeID) {
            Serial.printf("[IDENTIFY node %d]",rx_nodeID);
            Serial.println("");
          } else {
            Serial.println("[IDENTIFY all]");
          }
          identify(rxmsg.buf[1]);
          continue;
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

// ------------ 100h(+nodeID) SOUND ---------------------
 
        if ( (rx_cobID==0x100) && (rxmsg.len==3) ) {
          Serial.print("[VOLUME ");
          int cmd = rxmsg.buf[0];
          uint32_t val = ((uint32_t)rxmsg.buf[1]<<8) | (uint32_t)rxmsg.buf[2];
          switch (cmd) {
            case 0: // set volume ( val/1000 ) gain
            Serial.print("set] gain ");
            Serial.print((float)(val)/1000.0);
            Serial.println();
            mixer1.gain(0,(float)(val)/1000.0);  // 1000 = no gain 1.0             
            break;
            
            case 1: // fadeIn (mS)
            Serial.print("fadeIn] mS: ");
            Serial.print(val);
            Serial.println();
            fade1.fadeIn(val);
            break;
            
            case 2: // fadeOut (mS)
            Serial.print("fadeOut] mS: ");
            Serial.print(val);
            Serial.println();
            fade1.fadeOut(val);            
            break;
            
            default:
            Serial.println("unrecognized command]");
            break;
          }         
  
        continue;
        } 
 
        if ( (rx_cobID==0x100) && (rxmsg.buf[0]==3) && (rxmsg.len==6) ) {
          Serial.println("[SOUND noteON]");
          waveform1.frequency(rxmsg.buf[1]);
          //waveform1.amplitude(0.3*random(1, 5));
          envelope1.noteOn();
          //noteLength = random(500, 4000);
          noteLength = 100;
          noteOnTimer = 2000;        //note happend???
          noteOffTimer = noteLength;
          continue;
        }
        
 
// ------------ 200h(+nodeID) LED ---------------------
 
 
        if ( (rx_cobID==0x200) && (rxmsg.len==2) && (rxmsg.buf[0]==1) ) {
          Serial.println("[BRIGHTNESS]");
          matrix.setBrightness(rxmsg.buf[1]); 
          continue;
        } 
        
        if ( (rx_cobID==0x200) && (rxmsg.len==4) && (rxmsg.buf[0]==0) ) {
          Serial.println("[LED: clear display]");
          matrix.fillScreen({rxmsg.buf[1],rxmsg.buf[2],rxmsg.buf[3]});
          matrix.swapBuffers(true);
          continue;
        } 

        if ( (rx_cobID==0x200) && (rxmsg.len==8) && (rxmsg.buf[0]==3) ) {
          int local_coord = rxmsg.buf[6] & 0x10;
          int transparent = rxmsg.buf[6] & 0x20;
          Serial.println("[LED: phrase]");
//        Serial.printf("x=%d y=%d\n",(int((nodeID-1)%17)*32),(int((nodeID-1)/17)*32));
 
          if (rxmsg.buf[7]<=phrase_count) {
            switch (rxmsg.buf[6]&0x03) {
               case 0:
                 matrix.setFont(font4x4);
                 break;
               case 1:
                 matrix.setFont(font4x8_ansi);
                 break;
               case 2:
                 matrix.setFont(font3x5);
                 break;
               default:
                 matrix.setFont(font5x7);
                 break;
            }
//            matrix.fillScreen({0,0,0});  // don't erase screen!
//           matrix.setBrightness(15 * (255 / 100)); // 15% brightness
            matrix.swapBuffers(true);
            if (local_coord) {
              if (transparent) {
                matrix.drawString( (int)rxmsg.buf[1],(int)rxmsg.buf[2],
                {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
                phrase[rxmsg.buf[7]]);
              } else {
                matrix.drawString( (int)rxmsg.buf[1],(int)rxmsg.buf[2],
                {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
                {0,0,0},  // BG color
                phrase[rxmsg.buf[7]]);
              }
            } else {
              if (transparent) {
                matrix.drawString(
                (int)rxmsg.buf[1]-(int((nodeID-1)%17)*32),
                (int)rxmsg.buf[2]-(int((nodeID-1)/17)*32),
                {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
                phrase[rxmsg.buf[7]]);
              } else {
                matrix.drawString(
                (int)rxmsg.buf[1]-(int((nodeID-1)%17)*32),
                (int)rxmsg.buf[2]-(int((nodeID-1)/17)*32),
                {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
                {0,0,0},  // BG color
                phrase[rxmsg.buf[7]]);
              }
            }
            matrix.swapBuffers(true);
          }
          continue;
        }

    
           if ( (rx_cobID==0x200) && (rxmsg.len==8) && (rxmsg.buf[0]==2) ) {
          int local_coord = rxmsg.buf[6] & 0x10;
          int transparent = rxmsg.buf[6] & 0x20;
          Serial.println("[LED: char]");
 
         switch (rxmsg.buf[6]&0x03) {
           case 0:
             matrix.setFont(font4x4);
             break;
           case 1:
             matrix.setFont(font4x8_ansi);
             break;
           case 2:
             matrix.setFont(font3x5);
             break;
           default:
             matrix.setFont(font5x7);
             break;
          }
 //       matrix.fillScreen({0,0,0});
          matrix.swapBuffers(true);
          if (local_coord) {
            if (transparent) {
              matrix.drawChar( (int)rxmsg.buf[1],(int)rxmsg.buf[2],
              {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
              rxmsg.buf[7]);
            } else {
              matrix.drawChar( (int)rxmsg.buf[1],(int)rxmsg.buf[2],
              {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
              {0,0,0},  // BG color
              rxmsg.buf[7]);
            }
          } else {
            if (transparent) {
              matrix.drawChar(
              (int)rxmsg.buf[1]-(int((nodeID-1)%17)*32),
              (int)rxmsg.buf[2]-(int((nodeID-1)/17)*32),
              {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
              rxmsg.buf[7]);
            } else {
              matrix.drawChar(
              (int)rxmsg.buf[1]-(int((nodeID-1)%17)*32),
              (int)rxmsg.buf[2]-(int((nodeID-1)/17)*32),
              {rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]}, // FG color
              {0,0,0},  // BG color
              rxmsg.buf[7]);
            }
          }
            matrix.swapBuffers(true);
            continue;
        }
        
        
        if ( (rx_cobID==0x200) && (rxmsg.len==8) && (rxmsg.buf[0]==4) ) {
          int local_coord = rxmsg.buf[6] & 0x10;
          int transparent = rxmsg.buf[6] & 0x20;
          Serial.println("[LED: scrollText]");
 
          if (rxmsg.buf[7]<=phrase_count) {
            switch (rxmsg.buf[6]&0x03) {
             case 0:
               matrix.setScrollFont(font4x4);
               break;
             case 1:
               matrix.setScrollFont(font4x8_ansi);
               break;
             case 2:
               matrix.setScrollFont(font3x5);
               break;
             default:
               matrix.setScrollFont(font5x7);
               break;
            }
            matrix.setScrollColor({rxmsg.buf[3],rxmsg.buf[4],rxmsg.buf[5]});
            matrix.setScrollMode(wrapForward);
            matrix.setScrollSpeed((unsigned char)rxmsg.buf[5]);
            matrix.setScrollOffsetFromTop((int)rxmsg.buf[1]);
  
            matrix.scrollText(phrase[rxmsg.buf[7]],1); // number scrolls = 1  
//        while (matrix.getScrollStatus());
         }
         continue;
        }

        
        
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
#if 0
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
#endif

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


