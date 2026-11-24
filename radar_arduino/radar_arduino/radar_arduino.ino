#include <Servo.h>

// Ultrasonic Sensor 1
const int trigPin1 = 2;
const int echoPin1 = 3;

// Ultrasonic Sensor 2
const int trigPin2 = 4;
const int echoPin2 = 5;

// LEDs for Sensor 1
const int greenLed1 = 8;
const int redLed1 = 9;

// LEDs for Sensor 2
const int greenLed2 = 10;
const int redLed2 = 11;

// Buzzer
const int buzzerPin = 12;

// Servos
Servo servo1;
Servo servo2;
const int servoPin1 = 6;
const int servoPin2 = 7;

// Object detection threshold (in cm)
const int objectThreshold = 20;

// Servo sweep control
int angle1 = 0;
int angle2 = 180;
int step1 = 2;
int step2 = -2;

// Last time data was sent to Processing
unsigned long lastSendTime = 0;
const int sendInterval = 50; // Send data every 50ms

// Buzzer control
bool objectDetected = false; // New variable to track object detection

// Servo protection
unsigned long lastServoMoveTime = 0;
const int servoMoveInterval = 20; // Minimum time between servo moves

void setup() {
  // Ultrasonic pins
  pinMode(trigPin1, OUTPUT);
  pinMode(echoPin1, INPUT);
  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);

  // LED pins
  pinMode(greenLed1, OUTPUT);
  pinMode(redLed1, OUTPUT);
  pinMode(greenLed2, OUTPUT);
  pinMode(redLed2, OUTPUT);

  // Buzzer
  pinMode(buzzerPin, OUTPUT);

  // Attach servos with servo protection
  servo1.attach(servoPin1, 544, 2400);
  servo2.attach(servoPin2, 544, 2400);

  // Initialize servos to starting positions
  servo1.write(angle1);
  servo2.write(angle2);
  delay(500);

  Serial.begin(115200);
}

void loop() {
  long distance1 = getDistance(trigPin1, echoPin1);
  long distance2 = getDistance(trigPin2, echoPin2);

  // Check if any object is detected
  bool currentDetection = (distance1 > 0 && distance1 < objectThreshold) || 
                         (distance2 > 0 && distance2 < objectThreshold);

  // Sensor 1 LED control
  if (distance1 > 0 && distance1 < objectThreshold) {
    digitalWrite(greenLed1, LOW);
    digitalWrite(redLed1, HIGH);
  } else {
    digitalWrite(greenLed1, HIGH);
    digitalWrite(redLed1, LOW);
  }

  // Sensor 2 LED control
  if (distance2 > 0 && distance2 < objectThreshold) {
    digitalWrite(greenLed2, LOW);
    digitalWrite(redLed2, HIGH);
  } else {
    digitalWrite(greenLed2, HIGH);
    digitalWrite(redLed2, LOW);
  }

  // Buzzer control
  if (currentDetection) {
    digitalWrite(buzzerPin, HIGH); // Turn buzzer on when object is detected
  } else {
    digitalWrite(buzzerPin, LOW); // Turn buzzer off when no object is detected
  }

  // Servo sweeping with protection
  if (millis() - lastServoMoveTime >= servoMoveInterval) {
    servo1.write(angle1);
    servo2.write(angle2);
    lastServoMoveTime = millis();
    
    angle1 += step1;
    angle2 += step2;

    if (angle1 >= 180 || angle1 <= 0) step1 = -step1;
    if (angle2 >= 180 || angle2 <= 0) step2 = -step2;
  }

  // Send data to Processing
  if (millis() - lastSendTime >= sendInterval) {
    sendToProcessing(angle1, distance1, angle2, distance2);
    lastSendTime = millis();
  }

  delay(15);
}

long getDistance(int trigPin, int echoPin) {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 30000);
  if (duration == 0) return 0;

  long distance = duration * 0.034 / 2;
  return distance;
}

void sendToProcessing(int angle1, long distance1, int angle2, long distance2) {
  Serial.print(angle1);
  Serial.print(",");
  Serial.print(distance1);
  Serial.print(",");
  Serial.print(angle2);
  Serial.print(",");
  Serial.print(distance2);
  Serial.println(".");
}
