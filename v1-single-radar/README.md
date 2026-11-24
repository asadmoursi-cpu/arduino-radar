# v1: Single ultrasonic radar (based on Nurlan Quluzade's tutorial)

This is the first version of the project, built for my graduation thesis. It follows the single-sensor Arduino radar from **Nurlan Quluzade's tutorial**. The Arduino and Processing code here is that tutorial's design, copied from my thesis listing with two small fixes (see below). It is not my original code. My own work starts in v2, the dual-radar version in the repository root.

## What it does

- One HC-SR04 ultrasonic sensor sits on a servo that sweeps from 15 to 165 degrees and back.
- The Arduino measures the distance at each degree and sends `angle,distance.` over USB serial at 9600 baud.
- Two LEDs show the state: one lights when an object is closer than 30 cm, the other when nothing is.
- A Processing sketch reads the serial data and draws a green radar sweep with red marks for objects up to 40 cm. The footer shows the angle and distance, and the author name from the tutorial ("Nurlan Quluzade") stays on screen as credit.

## Files

```
single_radar_arduino/single_radar_arduino.ino         Arduino sketch
single_radar_processing/single_radar_processing.pde   Processing radar display
```

## Pins

| Part | Arduino pin |
| --- | --- |
| HC-SR04 TRIG | D10 |
| HC-SR04 ECHO | D11 |
| LED 1 | D9 |
| LED 2 | D8 |
| Servo signal | D12 |

## Changes from the thesis listing

- Removed a stray full stop after `#include <Servo.h>` (it stops the sketch compiling).
- Added the closing brace of `drawText()` in the Processing sketch, which was cut off in the listing.
- Added a short header comment to each file. Everything else is unchanged, and I have not compile-tested it.

## Run it

1. Upload the Arduino sketch, then close the Serial Monitor.
2. Open the Processing sketch and change `"COM3"` if your board uses another port. Set the window size in `size(...)` to match your screen.
3. Run it.

## Demo and photos

The demo video in the main README shows this version running. Build photos are in [`images/`](../images).
