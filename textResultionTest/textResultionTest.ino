//smartMatrix Font test

#include <SmartMatrix_32x32.h>

SmartMatrix matrix;

const int defaultBrightness = 50 * (255 / 100); // full brightness
//const int defaultBrightness = 15*(255/100);    // dim: 15% brightness
const int defaultScrollOffset = 6;
const rgb24 defaultBackgroundColor = {0, 0, 0};
byte r = 255;
byte g = 255;
byte b = 255;
char letter;
const int ledPin = 13;


void setup() {

  pinMode(ledPin, OUTPUT);

  Serial.begin(38400);

  matrix.begin();
  matrix.setBrightness(defaultBrightness);
  matrix.setScrollOffsetFromEdge(defaultScrollOffset);
  matrix.setColorCorrection(cc24);

}


void loop() {
  int i, j;

  char text[] = "HELLO DEJA ENTENDU IS NEAR";
  //char text[] = "Hello deja entendu is Near";

  matrix.setFont(font4x4);
  //matrix.setFont(font4x8_ansi);
  //custom fonts: font4x4, font4x8_ansi, font4x8
  //library fonts: font3x5, font5x7, font6x10, font8x13  

  matrix.fillScreen(defaultBackgroundColor);
  matrix.swapBuffers(true);

  r = random(220, 255);
  g = random(220, 255);
  b = random(220, 255);
  letter = text[i];            //?????, doen't work without this line
  for (int y = 0; y < 32; y = y + 4) {
    for (int x = 0; x < 32; x = x + 4) {
      matrix.drawChar(x, y, {r, g, b}, text[i]);  //random(65, 90) 122
      matrix.swapBuffers(true);
      delay(100);
      i++;
      if (i > 28) i = 0;
    }
  }
  delay(10000);
}
