// Print Object
PGraphics frame;

// Image to be printed
// Number of copies can be set at line 67 of printFunctions.pde/.java
PImage img;

// Image dithering offset parameter
int ditherOffset = 2;

// Check to not print w/o prior dither (can be removed for text)
boolean dithered = false;

// Print dimensions in mm
// for best results keep width < width stated on DevTerm Testprint
// but also just experiment
int printWidth = 48;
int printHeight = 48;
// DPI for mm-to-px conversion (203 as stated by cpi do not work here)
int printDPI = 96;

// Convert print dimensions in mm to px
int pxWidth = int(printWidth * (printDPI / 25.4));
int pxHeight = int(printHeight * (printDPI / 25.4));

void settings() {
  println(pxWidth + " " + pxHeight);
  size(pxWidth, pxHeight);
  pixelDensity(displayDensity());
}

void setup() {
  frame = createGraphics(width, height);
  img = createImage(width, height, RGB);

}

void draw() {
  if(!dithered) {
    background(200);
    noFill();
    rectMode(CENTER);
    stroke(25,120,0);
    rect(width/2, height/4, 100, 80);
    fill(0,128,0);
    ellipseMode(CENTER);
    ellipse(width/2, height/2, 30, 30);
    rectMode(CENTER);
    stroke(120,25,0);
    rect(width/2, height - height/4, 20, 20);
  }
}


void keyPressed() {
  if(key == 'd' || key == 'D' && !dithered) {
    makeDither();
  }
  
  if(key == 'p' || key == 'P' && dithered) {
    runPrint();
  }
}

void makeDither() {
  loadPixels();
  img.loadPixels();
  img.pixels = pixels;
  img.updatePixels();
  updatePixels();
  
  dither(img, ditherOffset);
  image(img,0,0);
  
  dithered = true;
}

void runPrint() {

  frame.beginDraw();
  frame.imageMode(CENTER);
  frame.image(img, frame.width/2, frame.height/2);
  frame.endDraw();
  
  printFrame(true);
  
  frame.dispose();
}

// Adapted from Gottfried Haider's Dithering example
/*
 * This implements Bill Atkinson's dithering algorithm
 */
void dither(PImage img, int offset) {
  img.loadPixels();

  for (int y=0; y < img.height; y++) {
    for (int x=0; x < img.width; x++) {
      // set current pixel and error
      float bright = brightness(img.pixels[y*img.width+x]);
      float err;
      if (bright <= 127) {
        img.pixels[y*img.width+x] = 0x000000;
        err = bright;
      } else {
        img.pixels[y*img.width+x] = 0xffffff;
        err = bright-255;
      }
      // distribute error
      int offsets[][] = new int[][]{{1, 0}, {offset, 0}, {-1, 1}, {0, 1}, {1, 1}, {0, offset}};
      for (int i=0; i < offsets.length; i++) {
        int x2 = x + offsets[i][0];
        int y2 = y + offsets[i][1];
        if (x2 < img.width && y2 < img.height) {
          float bright2 = brightness(img.pixels[y2*img.width+x2]);
          bright2 += err * 0.125;
          bright2 = constrain(bright2, 0.0, 255.0);
          img.pixels[y2*img.width+x2] = color(bright2);
        }
      }
    }
  }

  img.updatePixels();
}
