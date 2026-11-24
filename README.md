# Arduino Dual Ultrasonic Radar

A two-sensor radar built with an Arduino. Two HC-SR04 ultrasonic sensors each sit on a servo and sweep back and forth. The Arduino measures distance, lights a green or red LED per sensor, sounds a buzzer when something is closer than 20 cm, and streams the readings over USB serial to a Processing program that draws two live radar screens on a PC.

This started as my bachelor's graduation project (2023, IT / networks, Voronezh State University) and was developed further afterwards. It is a small intrusion / moving-object detection demo for a protection system.

## What it does

- Two servos sweep two ultrasonic sensors through 0-180 degrees, in opposite directions.
- Each sensor measures distance with the HC-SR04 trigger/echo method.
- An object closer than **20 cm** turns that sensor's LED red and turns the buzzer on. Otherwise the LED is green.
- The Arduino sends the angle and distance of both sensors to the PC every 50 ms.
- The Processing sketch shows two radar screens, the detected points with a short trail, and a panel with the live angle and distance for each sensor.

## Repository layout

```
radar_arduino/radar_arduino.ino         Arduino sketch (sensors, servos, LEDs, buzzer, serial output)
radar_processing/radar_processing.pde   Processing sketch (dual radar display)
```

Each sketch is in a folder with the same name, as the Arduino IDE and Processing expect.

## Hardware

- Arduino board (Uno or compatible)
- 2 x HC-SR04 ultrasonic sensors
- 2 x hobby servo motors (one carries each sensor)
- 2 x green LEDs and 2 x red LEDs (with series resistors)
- 1 x buzzer (driven directly from a digital pin)
- Jumper wires, breadboard, external 5 V supply for the servos if the board's 5 V is not enough
- USB cable to the PC

## Wiring (pins used in the sketch)

| Part | Arduino pin |
| --- | --- |
| Sensor 1 TRIG | D2 |
| Sensor 1 ECHO | D3 |
| Sensor 2 TRIG | D4 |
| Sensor 2 ECHO | D5 |
| Servo 1 signal | D6 |
| Servo 2 signal | D7 |
| Sensor 1 green LED | D8 |
| Sensor 1 red LED | D9 |
| Sensor 2 green LED | D10 |
| Sensor 2 red LED | D11 |
| Buzzer | D12 |

Power the sensors from 5 V and share a common ground between the Arduino, sensors, servos, LEDs and buzzer.

## How the two parts talk over serial

The Arduino prints one line every 50 ms at **115200 baud**, in this format:

```
angle1,distance1,angle2,distance2.
```

Example: `90,34,90,0.` means sensor 1 is at 90 degrees and sees an object 34 cm away, and sensor 2 is at 90 degrees with nothing in range. A distance of `0` means no echo (nothing detected).

The line ends with a full stop `.`. The Processing sketch reads up to that character, splits the text on commas, and checks that it got four values before using them.

## How to run it

1. Wire the hardware as in the table above.
2. Open `radar_arduino/radar_arduino.ino` in the Arduino IDE (the `Servo` library is included with the IDE), select your board and port, and upload.
3. Close the Arduino Serial Monitor so the port is free.
4. Open `radar_processing/radar_processing.pde` in [Processing](https://processing.org/) (it uses the built-in `processing.serial` library).
5. The sketch opens `COM3` at 115200 baud. If your Arduino is on a different port, change `"COM3"` in `setup()`.
6. Run the sketch. Press the space bar to clear the trail of detected points.

## Display notes

- The radar display scales 0-200 cm to the radar radius. Objects farther than 200 cm are not drawn.
- Sensor 1 is drawn in red and sensor 2 in blue.
- The buzzer/LED alert distance is set by `objectThreshold` (20 cm) in the Arduino sketch.

## Demo

_Demo video and screenshots: coming soon._

## Possible improvements

- Pick the serial port automatically instead of hard-coding `COM3`.
- Log detections with a timestamp.
- Add a larger display range and a configurable alert distance.

## Author

Asad Moursi, IT and networking graduate, Cairo, Egypt.
