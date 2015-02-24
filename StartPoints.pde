
class H_StartPoint{
  
  PVector loc;
  
  float r = 4;
  
  H_StartPoint(PVector _loc){
    loc = _loc;
    loc.x = _loc.x;
    loc.y = _loc.y;
  }
  
   void render(){
    stroke(#ABFF4D);
    
    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    line(-r, 0, 0, r, 0, 0);
    line(0, -r, 0, 0, r, 0);
    line(0, 0, -r, 0, 0, r);    
    popMatrix();
  }  
}
