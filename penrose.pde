// Penrose Tiler v4
//
// Simple port of http://preshing.com/20110831/penrose-tiling-explained/
// P2 tiling in 2 colors
// 
// Works by dividing triangular tiles into sets of smaller tiles.  Penrose tilings are
// aperiodic but go on forever (kind of like a fractial).
//
// https://en.wikipedia.org/wiki/Penrose_tiling
//
// Blake Shaw 2018


int num_subdivisions = 9; // how many times to divide tiles into sub-tiles
int progressiveDeflationNumber = 100; // set to 0 for regular, controls deflation w/ relation to center
int tileOpacity = 200;
int tile1color = color(230, 0, 0, tileOpacity);
int tile2color = color(230, 230, 0, tileOpacity);
boolean drawCircleguides = false;
boolean debug = false; // draws additional labels on points

Point center;
float goldenRatio = (1 + sqrt(5)) / 2;

void setup() {
  size(2000, 2000);
  pixelDensity(2);
  center = new Point(width/2, height/2);
  background(0);
  smooth(8);
}

void draw() {
  ArrayList<Tile> tiles = generateWheelTiles();

  for (int deflationNumber = 1; deflationNumber < num_subdivisions; deflationNumber++) {
    ArrayList<Tile> newTiles = new ArrayList<Tile>();
    for (Tile tile : tiles) {
      for (Tile newTile : deflateTile(tile)){
        if(newTile.distanceToCenter > deflationNumber * progressiveDeflationNumber) { 
          newTiles.add(newTile);
          newTile.draw();
        }
      }
    }
    tiles = newTiles;
  }
 
  save("penrose.png");
  noLoop();
}


ArrayList<Tile> deflateTile(Tile initialTile) {
  ArrayList<Tile> newTiles = new ArrayList<Tile>();
  
  Point p, a, b, c, q, r;
  
  a = initialTile.a;
  b = initialTile.b;
  c = initialTile.c;
    
  if (initialTile.type == 0){
    p = a.plus((b.minus(a)).divide(goldenRatio));
    
    newTiles.add(new Tile(0, c, p, b));
    newTiles.add(new Tile(1, p, c, a));
  } else {
    q = b.plus((a.minus(b)).divide(goldenRatio));
    r = b.plus((c.minus(b)).divide(goldenRatio));
  
    newTiles.add(new Tile(1, r, c, a));
    newTiles.add(new Tile(1, q, r, b));
    newTiles.add(new Tile(0, r, q, a));
  }
  
  return newTiles;
}


ArrayList<Tile> generateWheelTiles() {
  ArrayList<Tile> tiles = new ArrayList<Tile>();
  
  Point a = new Point(width/2, height/2);
  Point b, c;
  float r = width/2;
  float theta;
  
  for(int i=0; i<10; i++){
    theta = (2*i - 1) * PI / 10;
    b = new Point(r * cos(theta) + a.x, r * sin(theta) + a.y);
    theta = (2*i + 1) * PI / 10;
    c = new Point(r * cos(theta) + a.x, r * sin(theta) + a.y);
   
    // Reverse every other triangle so that it's mirrored, this matters later for decomposition
    if (i % 2 == 0) {
      tiles.add(new Tile(0, a, b, c));
    } else {
      tiles.add(new Tile(0, a, c, b));
    }
  }
  
  return tiles;
}


class Point {
  float x, y;
  
  Point(float x0, float y0) {
    x = x0;
    y = y0;
  }
  
  Point plus(Point p) {
    return new Point(x + p.x, y + p.y);
  }
  
  Point minus(Point p) {
    return new Point(x - p.x, y - p.y);
  }
  
  Point divide(float a) {
    return new Point(x / a, y / a);
  }
  
  Point multiply(float a) {
    return new Point(x * a, y * a);
  }
}
    
  
class Tile {
  int type;
  Point a, b, c, middle;
  float distanceToCenter;
  
  Tile(int type0, Point a0, Point b0, Point c0) {
    type = type0;
    a = a0;
    b = b0;
    c = c0;
    
    middle = new Point((a.x + b.x + c.x) / 3, (a.y + b.y + c.y) / 3);
    distanceToCenter = sqrt(pow(center.x - middle.x, 2) + pow(center.y - middle.y, 2));
    draw();
  }
  
  int alpha = tileOpacity;
  
  void draw() {
    if (type == 0) {
      fill(tile1color);
    } else {
      fill(tile2color);
    }
    
    stroke(0, 0, 0, 100);
    triangle(a.x, a.y, b.x, b.y, c.x, c.y);
    
    if (debug) {
     textSize(10);
     fill(255);
     text("A", a.x, a.y);
     text("B", b.x, b.y);
     text("C", c.x, c.y);
    } //<>//
  }
}
