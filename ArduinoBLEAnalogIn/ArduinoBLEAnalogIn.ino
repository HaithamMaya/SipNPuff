#include <SPI.h>
#include <EEPROM.h>
#include <boards.h>
#include <RBL_nRF8001.h>

void setup() {
  ble_set_name("Haitham_Arduino");
  ble_begin();
  Serial.begin(57600);
  
  pinMode(13, OUTPUT);
  digitalWrite(13, LOW);
}

void loop() {
  delay(250);
  uint16_t value = analogRead(A0); 
  Serial.println(value);
  if(ble_connected()) {
    ble_write(0x0B);
    ble_write(value >> 8);
    ble_write(value);
  }
  ble_do_events();
  if(ble_available()) {
    while(ble_available()) {
      Serial.write(ble_read());
    }
    Serial.println();
  }
}
