#include <Servo.h>
#include <SoftwareSerial.h>
SoftwareSerial BTserial(12, 13); // Bluetooth RX | TX pins

Servo x_axis_servo, y_axis_servo;
int x_axis_position = 0;
int y_axis_position = 0;

void setup(){
  x_axis_servo.attach(5);
  y_axis_servo.attach(6);

  Serial.begin(9600);
  Serial.println("Enter AT commands:");

  // HC-06 default serial speed is 9600
  BTserial.begin(9600);
}
 
void loop(){
  // Keep reading from HC-06 and send to Arduino Serial Monitor
  if (BTserial.available()){
    int receivedValue = BTserial.read();
    Serial.write(receivedValue);

    switch(receivedValue){
      case 100: //d
      case 117: //u
        move_servo(x_axis_servo, 60);
        break;
      case 108: //l
      case 114: //r
        move_servo(y_axis_servo, 60);
        break;
      default:
        Serial.write("Connected");
    }
  }
 
  // Keep reading from Arduino Serial Monitor and send to HC-06
  if (Serial.available()){
    BTserial.write(Serial.read());
  }
}

void move_servo(Servo servo, int degrees){
  for (int i = 0; i < degrees; i++){
    servo.write(i);
    delay(10);
  }

  for (int i = degrees; i > 0; i--){
    servo.write(i);
    delay(10);
  }
}
