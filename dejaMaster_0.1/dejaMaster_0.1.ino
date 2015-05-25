//________________________________________________________________
// dejaEntendu master

#include <FlexCAN.h>

byte nodes = 3;
byte led = 13;
FlexCAN CANbus(1000000);
static CAN_message_t msg;
char frameBuf[1024];
byte x_msg;
byte y_msg;
byte c_msg;
int baudrate;


// -------------------------------------------------------------
void setup(void)
{
  Serial.begin(230400);
  CANbus.begin();
  pinMode(led, OUTPUT);
  delay(500);
}


// -------------------------------------------------------------
void loop(void) {
  
  while (Serial.available()) {
    digitalWrite(led, 1);
    Serial.readBytes(frameBuf, 1024);
    msg.len = 8;  //CAN frame with up to 8 bytes
    int j = 0;
    for (int i = 0; i < 1024; i++) {
      if (j < 7) {
        msg.buf[j] = '0' + frameBuf[i];
        j++;
      }
      else
      {
        msg.buf[j] = '0' + frameBuf[i];
        for (int idn = 0; idn < nodes; ++idn ) {
          msg.id = idn;
          CANbus.write(msg);
          delay(2);
        }
        j = 0;
      }
      //      Serial.print("x_msg: ");
      //      Serial.println(msg.buf[0]);
      //      Serial.print("y_msg: ");
      //      Serial.println(msg.buf[1]);
      //      Serial.print("c_msg: ");
      //      Serial.println(msg.buf[2]);
    }
    digitalWrite(led, 0);
  }

}



/*
 if (canMetro.check()) {

 // insert a time delay between transmissions
 if ( !txTimer ) {

 txTimer = 50;//milliseconds, shorter???
 msg.len = 8;   //longer??
 for (int idn=0; idn<nodes; ++idn ) {
 msg.id = idn;
 for( int idb=0; idb<msg.len; ++idb ) {
 //better message!!
 msg.buf[idb] = '0'+idb;
 }
 }


 // send 6 at a time to force tx buffering
 txCount = 8;
 digitalWrite(led, 1);
 Serial.println(".");
 while ( txCount-- ) {
 CANbus.write(msg);
 msg.buf[0]++;
 }
 digitalWrite(led, 0);
 // time delay to force some rx data queue use
 rxTimer = 3;//milliseconds
 }

 }
 */

