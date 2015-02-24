class LinObs {
  
  float x1, y1, x2, y2;
  PVector pos;  

  LinObs(float _x1, float _y1, float _x2, float _y2) {
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
    pos = new PVector(x1, y1, 0);
  }

  LinObs(PVector a, PVector b) {
    x1 = a.x;
    y1 = a.y;
    x2 = b.x;
    y2 = b.y;
    pos = new PVector(x1, y1, 0);
  }

  PVector test(PVector loc) { //add collision shit
    //if not coincident
    if(!((x1 == x2) && (y1 == y2))){

      float x3 = loc.x;
      float y3 = loc.y;

      float x4, y4; 
      x4 = x2 - x1; 
      y4 = y2 - y1; 
      PVector te = new PVector(x4, y4, 0);

      float u;

      u = (x3 - x1) * (x2 - x1) + (y3 - y1) * (y2 - y1);
      u /= pow(te.dist(new PVector(0,0,0)), 2);
      
      if((u>=0)&&(u<=1)){ //segment condition - 1st surface field
        float x, y; 
        x = x1 + u * (x2 - x1); 
        y = y1 + u * (y2 - y1); 
        PVector ab = new PVector(x,y,0);

        float distance = PVector.dist(ab, new PVector(x3, y3, 0));
       
        if(distance < 8) {              //!!!!!!!!!!!!!!!!!!!!!calibrate         
          if(DEBUG_LO){
            stroke(255,255 - distance*1.5);
            line(ab.x, ab.y, x3, y3);
          }
          PVector diff = loc.sub(loc, ab);
          diff.normalize();
          diff.div(distance);
          return diff;
        }
      }
      else{ //  corner field
        PVector d = new PVector(x1,y1,0);
        if (u > 0)
          d.set(x2,y2,0);
        float distance = PVector.dist(d,loc);
        if (distance < 12.5){          //!!!!!!!!!!!!calibrate
          /*if(DEBUG_LO){
            stroke(255,255 - distance*1.5);
            line(d.x, d.y, loc.x, loc.y);
          }*/
          PVector diff = loc.sub(loc, d);
          diff.normalize();
          diff.div(distance);
          return diff;  
        }  
      }
    }
    return new PVector(0,0,0);
  }

  void render(){
    strokeWeight(1);
    stroke(255, 90, 150,180); 
    noFill();
    line(x1, y1, x2, y2);
  }
}
