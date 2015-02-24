
class Flock //Boids Supervisor
{
  public ArrayList boids; // An arraylist for all the agents
  color c;
  
  // Parameters for all the agents.
  
  float FSep, FCoh, FObs;
  float desiredseparation; 
  float ForceSep=5, ForceAli=1, ForceObs = 520;
  float MSP, MTS;
  
  float[] FWand = {0.8, 0.21, 0.7, 0.2}; //students, workers, casual, cops
  float[] FAlig = {0.25, 0, 0.26, 3};     //
  float[] FAttr = {0.41, 0.2, 0.61, 6};       //small attractors
  
  int DieTimeThresh = 400*1000;//(milli)seconds to die instantly if still on map(if tottaly stuck)
  int DieDistThresh = 7;

  int frameCounter = 0;
  int frameCheck = 10;
  float localMinThresh = 6;
    
  Flock(color _c){
    boids = new ArrayList();
    this.c = _c;
   }

  void run(){
    for (int i = 0; i < boids.size(); i++){
      Boid b = (Boid) boids.get(i); 
      if (b==null)
        continue;
      if (b.type == 4){ //if cop
        b.run();
        continue;
      }
      configureMode(b);
      if ((b.trace.L.size()<=2)&&b.dead){
        killBoid(b,i);
        continue;
      }
      
      Cell c = Grid.findcell(b.loc.x,b.loc.y); //check for Migration
      if (b.cell != c){
        Grid.Migrate(b.cell,c,i);
        b.cell = c;
      } 
      b.run(); 
    }
  }

  void configureMode(Boid b){
    int timealive = (GlobalTime - ResetTime) - b.BirthTime;
    
    if (timealive > DieTimeThresh){
      b.dead = true;
      return;
    }
   if (!b.GoWork){
    if ((timealive > b.WorkTime)&&(b.type != 4)){ //go to target, no attractors
      b.GoWork = true;
      int n = (int)random(0,SmallAtts.size()); //set target
      Attractor o = (Attractor) SmallAtts.get(n);
      b.target = new Attractor(o.loc,o.t); 
      
      //b.attract = false;
      b.ForceAtt = 0.01;
      b.FWand = 0.1;
      b.FAlig = 0.1;
    }
   } 
   if ((timealive > b.BackTime)&&(b.type != 4)){ // go back
     b.GoBack = true;
     
     int n = (int)random(0,StartP.size()); //set beginning-target to go back
     H_StartPoint o = (H_StartPoint) StartP.get(n);
     b.target.loc = o.loc.get(); 
     
     b.immob = false;
     
     b.ForceAtt = 0.01;
     b.FWand = 0.01;
     b.FAlig = 0.1;
   }
   if (b.GoBack == true)   //when to die from map
     if (b.loc.dist(b.startloc) < DieDistThresh)
       b.dead = true;    
  }

  int addBoid(Boid b){ //insert boid to flock.boids, returns index 
    NumBoids++; 
    for (int i=0;i<boids.size();i++){
      if(boids.get(i)==null){
        boids.set(i,b);
        return i;
      }
    }
    boids.add(b);
    return (boids.size()-1);
  }
  
  void killBoid(Boid b,int idx){
    NumBoids--;
    this.boids.set(idx,null);
    b.cell.delete(idx);
    b = null;
  }
   
  void setParams(float _FSep, float _FCoh, float _desiredseparation, float _MSP, float _MTS){
    FSep = _FSep; FCoh = _FCoh; 
    desiredseparation = _desiredseparation;
    
    MSP = _MSP;
    MTS = _MTS;
  }
  
  
  void checkLocalMin(Boid b){
    frameCounter = (frameCounter+1)%frameCheck;
    if (frameCounter > 0)
      return;
    else{
      b.trace.updateDev(frameCheck);
      //println("std "+b.trace.stdev+" "+b.trace.mean.x+" "+b.trace.mean.y);
      if (b.trace.stdev < localMinThresh){
        //b.Wander = 0.0; //drop wander to unstack FIXME: drop FAtt to 0 
        b.attract=false;
      }
      else{
        //setWander(b);
        b.attract=true;  
      }
    }  
  }
  
}
