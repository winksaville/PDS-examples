#include "src/setup.h"

void setup() {
  pinMode(LED1_PIN, OUTPUT);
  Serial1.begin(115200, SERIAL_8N1, 13, 14);  // RX=13, TX=14
  Serial1.println("Main LED1 blink test...");
}