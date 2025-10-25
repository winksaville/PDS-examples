// PD-Stepper: blink LED1 (IO10) and send log via Serial1 on IO13/IO14

#include "src/setup.h"
#include "src/loop.h"

bool led_on = false;

// The entry point is `__wrap_app_main`, see the
// `buildit:` target in Makefile for more details.
extern "C" void __wrap_app_main(void) {
  initArduino(); // Initialize Arduino framework if desired not needed
  setup();
  uint64_t loop_count = 0;
  Serial1.println("main: entering main loop");
  while (true) {
    if (loop_count % 10 == 0) {
      Serial1.println("Loop count: " + String(loop_count));
    }
    loop();
    loop_count++;
  }
}
