// PD-Stepper: blink LED1 (IO10) and send log via Serial1 on IO13/IO14

#include "src/setup.h"
#include "src/loop.h"

bool led_on = false;

int main() {
  setup();
  while (true) {
    loop();
  }
}
