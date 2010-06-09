final float EPS = .0001;

float[] x,y;
float[] xLast, yLast;
float[] ax,ay;

final int nParts = 40;
final float tStep = 1.0/60.0;

int perimIters = 5; //number of perimiter fixing iterations to do - more means closer to perfect solidity
float relaxFactor = .9; //1.0 would mean perfect solidity (no blobbiness) if it worked (unstable)

float leftWallX = -60.0f;
float rightWallX = 60.0f;
float floorY = -30.0f;
float ceilY = 30.0f;

float gravityForce = 0.0;
float rad = 10.0f;

float blobAreaTarget;
float sideLength;

float mouseRad = 5.0f;

boolean[] keyState;

float rotateAccel = 10.0;
float jumpSquish = 40.0;

PFont font;

void setup() {
  size(800,400,P3D);
  frameRate(60);
  setupParticles();
  keyState = new boolean[255];
//  font = loadFont("Serif-19.vlw")
}

boolean hitFloor;

void draw() {
  hitFloor = false;
 // textFont(font);
  textMode(SCREEN);
  background(0);
  stroke(255);
  fill(255);
  text("Volume Preserving Blob - A: left, D: right, SPACE: jump",10,25);
  for (int i=0; i<3; ++i) {
    respondToInput();
    integrateParticles(tStep);
    constrainBlobEdges();
    collideWithFloorAndWalls();
    collideWithMouse();
  }
  drawBlob();
  drawMouse();
}

void respondToInput() {
  int lr = 0;
  boolean jump = false;
  if (keyState['d']) lr += 1;
  if (keyState['a']) lr -= 1;
  if (keyState[' ']) jump = true;
  
  if (lr != 0) {
    for (int i=0; i<nParts; ++i) {
      int next = (i==nParts-1)?0:i+1;
      float dx = x[next]-x[i];
      float dy = y[next]-y[i];
      float distance = sqrt(dx*dx+dy*dy);
      if (distance < EPS) distance = 1.0;
      dx /= distance;
      dy /= distance;
      ax[i] += lr * dx * rotateAccel;
      ay[i] += lr * dy * rotateAccel;
    }
  }
  
  if (jump && hitFloor) {
    // Find COM
    float cmx = 0.0f;
    float cmy = 0.0f;
    for (int i=0; i<nParts; ++i) {
      cmx += x[i];
      cmy += y[i];
    }
    cmx /= nParts;
    cmy /= nParts;
    for (int i=0; i<nParts; ++i) {
      ax[i] -= (x[i]-cmx)*jumpSquish;
    }
  }
}

void drawMouse() {
  noStroke();
  fill(100);
  float scaleMouseX = (rightWallX-leftWallX)/(width-20);
  float scaleMouseY = (ceilY-floorY)/(height-20);
  ellipse(mouseX,mouseY,2*mouseRad/scaleMouseX,2*mouseRad/scaleMouseY);
}

void keyPressed() {
  if (0 < key && key < 255) keyState[key] = true;
}

void keyReleased() {
  if (0 < key && key < 255) keyState[key] = false;
}

void drawBlob() {
  //fill(0,255,0);
  noFill();
  beginShape(POLYGON);
  for (int i=0; i<nParts; ++i) {
    //int next = (i==nParts-1)?0:i+1;
    float x0 = map(x[i],leftWallX,rightWallX,10,width-10);
    float y0 = map(y[i],floorY,ceilY,height-10,10);
    vertex(x0,y0);
//    float x1 = map(x[next],leftWallX,rightWallX,10,width-10);
//    float y1 = map(y[next],floorY,ceilY,height-10,10);
//    line(x0,y0,x1,y1);
  }
  vertex(map(x[0],leftWallX,rightWallX,10,width-10),map(y[0],floorY,ceilY,height-10,10));
  endShape();
  for (int i=0; i<nParts; ++i) {
    //int next = (i==nParts-1)?0:i+1;
    float x0 = map(x[i],leftWallX,rightWallX,10,width-10);
    float y0 = map(y[i],floorY,ceilY,height-10,10);
    ellipse(x0,y0,2,2);
//    float x1 = map(x[next],leftWallX,rightWallX,10,width-10);
//    float y1 = map(y[next],floorY,ceilY,height-10,10);
//    line(x0,y0,x1,y1);
  }
}

float worldX(float screenx) {
  return map(screenx,10,width-10,leftWallX,rightWallX);
}

float worldY(float screeny) {
  return map(screeny,height-10,10,floorY,ceilY);
}

void setupParticles() {
  x = new float[nParts];
  y = new float[nParts];
  xLast = new float[nParts];
  yLast = new float[nParts];
  ax = new float[nParts];
  ay = new float[nParts];
  
  float cx = 0.0f;
  float cy = 0.0f;
  for (int i=0; i<nParts; ++i) {
    float ang = map(i,0,nParts,0,TWO_PI);
    x[i] = cx + sin(ang)*rad;
    y[i] = cy + cos(ang)*rad;
    xLast[i] = x[i];
    yLast[i] = y[i];
    ax[i] = 0;
    ay[i] = 0;
  }
  
  sideLength = sqrt( (x[1]-x[0])*(x[1]-x[0])+(y[1]-y[0])*(y[1]-y[0]) );
  
  blobAreaTarget = getArea();
}

void fixPerimeter() {
    // Fix up side lengths
  float[] diffx = new float[nParts];
  float[] diffy = new float[nParts];
  
  for (int j=0; j<perimIters; ++j) {
    for (int i=0; i<nParts; ++i) {
      int next = (i==nParts-1)?0:i+1;
      float dx = x[next]-x[i];
      float dy = y[next]-y[i];
      float distance = sqrt(dx*dx+dy*dy);
      if (distance < EPS) distance = 1.0;
      float diffRatio = 1.0 - sideLength / distance;
      diffx[i] += .5*relaxFactor * dx * diffRatio;
      diffy[i] += .5*relaxFactor * dy * diffRatio;
      diffx[next] -= .5*relaxFactor * dx * diffRatio;
      diffy[next] -= .5*relaxFactor * dy * diffRatio;
    }
  
    for (int i=0; i<nParts; ++i) {
      x[i] += diffx[i];
      y[i] += diffy[i];
      diffx[i] = 0;
      diffy[i] = 0;
    }
  }
}

void constrainBlobEdges() {
  
  
  fixPerimeter();
  
  float perimeter = 0.0;
  float[] distance = new float[nParts]; //distance from vertex i to vertex i+1
  float[] nx = new float[nParts]; //normals
  float[] ny = new float[nParts];
  for (int i=0; i<nParts; ++i) {
    int next = (i==nParts-1)?0:i+1;
    float dx = x[next]-x[i];
    float dy = y[next]-y[i];
    distance[i] = sqrt(dx*dx+dy*dy);
    if (distance[i] < EPS) distance[i] = 1.0;
    nx[i] = dy / distance[i];
    ny[i] = -dx / distance[i];
    perimeter += distance[i];
  }
  
  float deltaArea = blobAreaTarget - getArea();
  float toExtrude = 0.5*deltaArea / perimeter;
  
  for (int i=0; i<nParts; ++i) {
    int next = (i==nParts-1)?0:i+1;
    x[next] += toExtrude * (nx[i] + nx[next]);
    y[next] += toExtrude * (ny[i] + ny[next]);
  }
  
}

float getArea() {
  float area = 0.0f;

  area += x[nParts-1]*y[0]-x[0]*y[nParts-1];
  for (int i=0; i<nParts-1; ++i){
    area += x[i]*y[i+1]-x[i+1]*y[i];
  }
  area *= .5f;
  return area;
}

void integrateParticles(float dt) {
  float dtSquared = dt*dt;
  float gravityAddY = -gravityForce * dtSquared;
  for (int i=0; i<nParts; ++i) {
    float bufferX = x[i];
    float bufferY = y[i];
    x[i] = 2*x[i] - xLast[i] + ax[i]*dtSquared;
    y[i] = 2*y[i] - yLast[i] + ay[i]*dtSquared + gravityAddY;
    xLast[i] = bufferX;
    yLast[i] = bufferY;
    ax[i] = 0;
    ay[i] = 0;
  }
}

void collideWithFloorAndWalls() 
{
  for (int i=0; i<nParts; ++i) 
{
    if (x[i] < leftWallX) 
		x[i] = leftWallX;
    else if (x[i] > rightWallX)	
		x[i] = rightWallX;
    if (y[i] < floorY) 
	{
      y[i] = floorY;
      xLast[i] = x[i];
      hitFloor = true;
    } else if (y[i] > ceilY)
	{
		y[i] = ceilY;
		xLast[i] = x[i];
	}
  }
}

void collideWithMouse() {
  float mx = worldX(mouseX);
  float my = worldY(mouseY);
  for (int i=0; i<nParts; ++i) {
    float dx = mx-x[i];
    float dy = my-y[i];
    float distSqr = dx*dx+dy*dy;
    if (distSqr > mouseRad*mouseRad) continue;
    if (distSqr < EPS*EPS) continue;
    float distance = sqrt(distSqr);
    x[i] -= dx*(mouseRad/distance-1.0);
    y[i] -= dy*(mouseRad/distance-1.0);
  }
}
