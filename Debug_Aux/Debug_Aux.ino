// PD-Stepper: blink LED1 (IO10) and send log via Serial1 on IO13/IO14

const int LED1_PIN = 10;  // LED1
bool led_on = false;

void setup() {
  pinMode(LED1_PIN, OUTPUT);
  Serial1.begin(115200, SERIAL_8N1, 13, 14);  // RX=13, TX=14
  Serial1.println("Starting LED1 blink test...");
}

void loop() {
  led_on = !led_on;
  digitalWrite(LED1_PIN, led_on ? HIGH : LOW);
  Serial1.println(led_on ? "LED1 ON" : "LED1 OFF");
  delay(1000);
}

