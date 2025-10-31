#include "loop.h"

void loop() {
  led_on = !led_on;
  digitalWrite(LED1_PIN, led_on ? HIGH : LOW);
  Serial1.println(led_on ? "LED1 ON" : "LED1 OFF");
  delay(500);
}
