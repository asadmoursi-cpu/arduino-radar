import processing.serial.*;

Serial myPort;

// Window settings
int windowWidth = 800;
int windowHeight = 1200;
int radarRadius = 200;

// Sensor data
float[] angles = {0, 180};
float[] distances = {0, 0};
color[] sensorColors = {color(255, 0, 0), color(0, 0, 255)};

// Data history
ArrayList<PVector>[] history = new ArrayList[2];
int maxHistory = 100;

void setup() {
  size(1200, 600);
  
  // Initialize data history
  for (int i = 0; i < 2; i++) {
    history[i] = new ArrayList<PVector>();
  }
  
  // Try connecting to COM3
  try {
    myPort = new Serial(this, "COM3", 115200);
    myPort.bufferUntil('.');
    println("Connected to COM3");
  } catch (Exception e) {
    println("Error connecting to COM3: " + e.getMessage());
  }
  
  smooth();
}

void draw() {
  background(0);
  
  // Draw Sensor 1 radar
  drawRadar(200, 300, 0);
  
  // Draw Sensor 2 radar
  drawRadar(600, 300, 1);
  
  // Draw information panel
  drawInfoPanel();
}

void drawRadar(int centerX, int centerY, int sensorIndex) {
  pushMatrix();
  translate(centerX, centerY);
  
  // Draw radar background
  drawRadarBackground();
  
  // Draw sensor sweep
  drawSensorSweep(sensorIndex);
  
  // Draw history points
  drawHistoryPoints(sensorIndex);
  
  popMatrix();
}

void drawRadarBackground() {
  noFill();
  stroke(0, 255, 0, 100);
  strokeWeight(1);
  
  // Draw circles
  for (int r = 40; r <= radarRadius; r += 40) {
    ellipse(0, 0, r*2, r*2);
  }
  
  // Draw radial lines
  for (int a = 0; a < 360; a += 30) {
    float x = cos(radians(a)) * radarRadius;
    float y = sin(radians(a)) * radarRadius;
    line(0, 0, x, y);
  }
  
  // Radar center
  fill(0, 255, 0);
  noStroke();
  ellipse(0, 0, 10, 10);
}

void drawSensorSweep(int sensorIndex) {
  float x = cos(radians(angles[sensorIndex])) * radarRadius;
  float y = sin(radians(angles[sensorIndex])) * radarRadius;
  
  // Draw sensor line
  stroke(sensorColors[sensorIndex], 150);
  line(0, 0, x, y);
  
  // Draw detection point if object detected
  if (distances[sensorIndex] > 0 && distances[sensorIndex] < 200) {
    float detectionX = cos(radians(angles[sensorIndex])) * map(distances[sensorIndex], 0, 200, 0, radarRadius);
    float detectionY = sin(radians(angles[sensorIndex])) * map(distances[sensorIndex], 0, 200, 0, radarRadius);
    
    fill(sensorColors[sensorIndex]);
    noStroke();
    ellipse(detectionX, detectionY, 12, 12);
  }
}

void drawHistoryPoints(int sensorIndex) {
  noStroke();
  for (int i = 0; i < history[sensorIndex].size(); i++) {
    PVector p = history[sensorIndex].get(i);
    float alpha = map(i, 0, history[sensorIndex].size(), 50, 255);
    fill(sensorColors[sensorIndex], alpha);
    ellipse(p.x, p.y, 6, 6);
  }
}

void drawInfoPanel() {
  fill(255);
  textSize(14);
  textAlign(LEFT, TOP);
  
  // Sensor 1 info
  fill(sensorColors[0]);
  text("Sensor 1 (Red)", 30, 20);
  text("Angle: " + nf(angles[0], 0, 1) + "\u00B0", 30, 40);
  text("Distance: " + (distances[0] > 0 ? nf(distances[0], 0, 1) + " cm" : "No object"), 30, 60);
  
  // Sensor 2 info
  fill(sensorColors[1]);
  text("Sensor 2 (Blue)", 630, 20);
  text("Angle: " + nf(angles[1], 0, 1) + "\u00B0", 630, 40);
  text("Distance: " + (distances[1] > 0 ? nf(distances[1], 0, 1) + " cm" : "No object"), 630, 60);
  
  // Connection status
  fill(255);
  text("Connection: " + (myPort != null && myPort.active() ? "Connected to COM3" : "Disconnected"), width/2 - 100, 20);
}

void serialEvent(Serial p) {
  try {
    String inString = p.readStringUntil('.');
    if (inString != null) {
      inString = trim(inString);
      String[] data = split(inString, ',');
      
      if (data.length == 4) {
        angles[0] = float(data[0]);
        distances[0] = float(data[1]);
        angles[1] = float(data[2]);
        distances[1] = float(data[3]);
        
        // Add Sensor 1 data to history
        if (distances[0] > 0 && distances[0] < 200) {
          float x1 = cos(radians(angles[0])) * map(distances[0], 0, 200, 0, radarRadius);
          float y1 = sin(radians(angles[0])) * map(distances[0], 0, 200, 0, radarRadius);
          history[0].add(new PVector(x1, y1));
          if (history[0].size() > maxHistory) history[0].remove(0);
        }
        
        // Add Sensor 2 data to history
        if (distances[1] > 0 && distances[1] < 200) {
          float x2 = cos(radians(angles[1])) * map(distances[1], 0, 200, 0, radarRadius);
          float y2 = sin(radians(angles[1])) * map(distances[1], 0, 200, 0, radarRadius);
          history[1].add(new PVector(x2, y2));
          if (history[1].size() > maxHistory) history[1].remove(0);
        }
      }
    }
  } catch (Exception e) {
    println("Error processing serial data: " + e);
  }
}

void keyPressed() {
  if (key == ' ') {
    // Clear history when spacebar is pressed
    for (int i = 0; i < 2; i++) {
      history[i].clear();
    }
  }
}
