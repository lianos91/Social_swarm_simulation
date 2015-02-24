public class Attractor{
  
  PVector loc;
  
  float power;
  float r = 7;
  int t;
  
  Attractor(){
    loc = new PVector(random(-worldSize/2, worldSize/2), random(-worldSize/2, worldSize/2), random(-worldSize/2, worldSize/2));
    power = random(-1, 1);
  }
  
  Attractor(PVector _loc,float _pow){
    this.loc = _loc;
    this.power = _pow;
  }
  
  void render(){
    stroke( map(power, -1, 2, 0, 255), 100, map(power, -1, 1, 255, 0) );
    //stroke(255);
    pushMatrix();
    translate(loc.x, loc.y, loc.z);
    line(-r, 0, 0, r, 0, 0);
    line(0, -r, 0, 0, r, 0);
    line(0, 0, -r, 0, 0, r);    
    popMatrix();
  }
}
