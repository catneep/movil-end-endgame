#include <Servo.h>
#include <SoftwareSerial.h>
SoftwareSerial BTserial(12, 13); // Bluetooth RX | TX pins

Servo x_axis_servo, y_axis_servo;
int x_axis_position = 0;
int y_axis_position = 0;

// Movimiento de servos
int DEGREES = 35;

void setup(){
  // Inicializa pines de control de servos
  x_axis_servo.attach(5);
  y_axis_servo.attach(6);

  Serial.begin(9600);
  Serial.println("Awaiting BT directives...");

  // HC-06 default serial speed is 9600
  BTserial.begin(9600);
}
 
void loop(){
  // Recibe info de módulo BT
  if (BTserial.available()){
    int receivedValue = BTserial.read();
    Serial.write(receivedValue);

    // Evalúa instrucción recibida por BT
    switch(receivedValue){
      case 100: // d
        move_servo(x_axis_servo, -DEGREES);
        break;
      case 117: // u
        move_servo(x_axis_servo, DEGREES);
        break;
      case 108: // l
        move_servo(y_axis_servo, -DEGREES);
        break;
      case 114: // r
        move_servo(y_axis_servo, DEGREES);
        break;
      default:
        Serial.write("Connected");
    }
  }
 
  // Envía info del monitor serial a módulo BT
  if (Serial.available()){
    BTserial.write(Serial.read());
  }
}

void move_servo(Servo servo, int degrees){
  if (degrees > 0) for (int i = 0; i < degrees; i++){
    servo.write(i);
    delay(10);
  }

  if (degrees < 0) for (int i = degrees; i > 0; i--){
    servo.write(i);
    delay(10);
  }
}
