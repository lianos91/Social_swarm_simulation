class Boid{
  
  Flock parent;
  H_Trace trace;
  
  Attractor target;
  PVector startloc;
  PVector loc;
  PVector vel;
  PVector acc;
  
  byte r;
  float wandertheta, wanderphi, wanderpsi;
  
  float FWand;
  float FAlig;
  float ForceAtt = 2;
  int BirthTime;
  int BackTime; //if timeAlive > backTime then GoBack
  int WorkTime;
  
  ArrayList neighbors = new ArrayList();
  
  byte type;  //1:STUDENT 2:WORKER/RESIDENT 3:CASUAL USERS 4:COPS
  
  int k = 0;
  boolean traceallow = true;
  boolean GoWork = false;
  boolean attract = true;
  boolean GoBack = false;
  boolean dead = false;
  boolean immob = false;
  
  Cell cell;
  // constructor functions
  /////////////////////////////////
  
  Boid(){
    
    acc = new PVector(0,0,0);
    vel = new PVector(0,0,0);
    loc = new PVector(0,0,0);
    
    r = 3;
    
    trace = new H_Trace();
    trace.add(new PVector(loc.x, loc.y, loc.z));
    
    type = 1;
    
    wandertheta = 0;
    wanderphi = 0;
    wanderpsi = 0;
  }
  
  Boid(PVector _loc, Flock _parent, byte _type, int _birthtime){
    
    acc = new PVector(0,0,0);
    vel = new PVector(random(-1,1), random(-1,1),  0);
    
    r = 3;
    
    this.loc = _loc.get();   
    this.startloc = _loc.get();
    this.parent = _parent;
    
    trace = new H_Trace();
    trace.add(new PVector(loc.x, loc.y, loc.z));
    
    BirthTime =  _birthtime; //time of creation___timealive = (GlobalTime - ResTime) - BirthTime
     
    this.type = _type;
    this.FAlig = parent.FAlig[type-1];
    this.ForceAtt = parent.FAttr[type-1];   
    this.FWand = parent.FWand[type-1];   
   
    switch(type){       //----------set Time fields, 
      case 1:          //students
        this.BackTime = (int)random(48000,77000); 
        this.WorkTime = (int)random(7000,44000);
        break;
      case 2:          //workers
        this.BackTime = (int)random(27000,77000); 
        this.WorkTime = (int)random(14000,26000);
        break;
      case 3:          //casual
        this.BackTime = (int)random(33000,44000);
        this.WorkTime = (int)random(17000,30000);
        break;
      case 4:          //cops
        this.BackTime = -1; //dont care 
        this.WorkTime = -1;
        break;
    }
    
   
    if (type == 4){ 
      int n;      //set target if cop
      Attractor o;
      n = (int)random(0,copsat.size());
      o = (Attractor) copsat.get(n);
      this.target = new Attractor(o.loc,o.t); 
    }
    
    wandertheta = 0;
    wanderphi = 0;
    wanderpsi = 0;
  }
  
  // runtime functions - run, flock, update, borders
  /////////////////////////////////
  
  void run(){
    if(!dead && !immob){
      binflock(parent.boids);
      update();
      //borders();
      //if (traceallow){
        //traceallow = false;
        if(++k >= TAIL_RES){
          k = 0;
          trace.add(new PVector(loc.x, loc.y, loc.z));            
        }
      //else
        //traceallow = true;
    
    }
    else if(!immob)
      trace.L.remove(0); //only if gone from map, returned back
    trace.drawlines(parent.c);
    if (!dead){  
      render();
    }
  }
  
  void getNeigh_Obs_Boids(ArrayList tempobs,ArrayList tempboids,PVector[] neighCells){//gather obstacles & boids 
     for(int k=0;k<neighCells.length;k++){                                          //from neighbor cells        
       PVector coord = neighCells[k];
       Cell cll = Grid.AccessCell(coord.x,coord.y);
       
       for(int i=0;i<cll.Obs.size();i++)
         if(!tempobs.contains(cll.Obs.get(i))){
           int obidx = (int) cll.Obs.get(i);
           tempobs.add(obidx);
         }
       for(int i=0;i<cll.Boids.size();i++)
         if(!tempboids.contains(cll.Boids.get(i)))
           tempboids.add((int)cll.Boids.get(i));        
     }
  }
  
  void binflock(ArrayList boids){
    ArrayList<Integer> tempobs = new ArrayList();
    ArrayList<Integer> tempboids = new ArrayList();    
    PVector[] test = Grid.neighborcells(this.cell); 
    getNeigh_Obs_Boids(tempobs,tempboids,test);
    
    
    if(parent.ForceObs > 0){
      PVector obsv = avoidObs2(tempobs); obsv.mult(parent.ForceObs); 
      acc.add(obsv);
    }
     if (this.GoWork){  //target attraction
      PVector att = attractTarget(); att.mult(5); acc.add(att); //target
    }
    else{
      this.FAlig = parent.FAlig[type-1];
      this.ForceAtt = parent.FAttr[type-1];   
      this.FWand = parent.FWand[type-1];   
    } 
    
    flockInteract(tempboids,boids);
    if(this.FWand > 0){
      PVector wanderVector = wander2D();  wanderVector.mult(this.FWand); acc.add(wanderVector);
    } 
    if(this.attract)
      attractors();
  }
  
 
  void attractors(){
    if (type != 4){ 
      Attractor tmp; 
      for (int i=0;i<LargeAtts.size();i++){  //____large attractors
        tmp = (Attractor) LargeAtts.get(i);
          
        PVector pv = steer(tmp.loc,false);
        pv.mult(tmp.power);   
        pv.mult(this.ForceAtt); //ForceAtt = influence from large attractors
        acc.add(pv);
      }
    }
  } 
  
  void update(){
    vel.add(acc);
    vel.limit(parent.MSP);  
    loc.add(vel);
    acc.mult(0);
  }
  
  void borders(){
    if ((loc.x < FieldXmin)||(loc.y < FieldYmin)||(loc.x > FieldXmax)||(loc.y > FieldYmax)) 
    this.dead = true;
  }
  
   // attract 
  /////////////////////////////////
  
  PVector attractTarget(){
    float d = this.loc.dist(target.loc);
    
    stroke(100, 255, 190, map(d, 0, 500, 255, 20));
    if((DEBUG_ATT)&&(!(this.target==null))) line(this.loc.x, this.loc.y, this.loc.z, target.loc.x, target.loc.y, target.loc.z);
    
    return steer(target.loc, false);
  }
  
  // steering metods - seek and arrive
  /////////////////////////////////
  
  // blindly goes towards the target  
  void seek(PVector target){
    acc.add(steer(target, false));
  }
  
  // slows down upon reaching the target
  void arrive(PVector target){
    acc.add(steer(target, true));
  }
  
  // calculates a vector towards the target
  PVector steer(PVector target, boolean slowdown){
    PVector steer;
    PVector desired; 
    
    desired = PVector.sub(target, loc);
    float d = desired.mag();
    
    if(d > 0) {
      desired.normalize();
      
      if((slowdown) && (d < 100))
        desired.mult(parent.MSP*(d/100));
      else
        desired.mult(parent.MSP);
      
      steer = PVector.sub(desired, vel);
      steer.limit(parent.MTS);
    }else{
      steer = new PVector(0,0,0); 
    }
    
    //displayVector(loc, steer);
    return steer;
  }
  
  // wander function
  /////////////////////////////////
  
  PVector wander2D(){
    float wanderR = 16.0f;         // Radius for our "wander circle"
    float wanderD = 60.0f;         // Distance for our "wander circle"
    float change = 0.20f;
    wandertheta += random(-change,change);     // Randomly change wander theta

    // Now we have to calculate the new location to steer towards on the wander circle
    PVector circleloc = vel.get();  // Start with velocity
    circleloc.normalize();            // Normalize to get heading
    circleloc.mult(wanderD);          // Multiply by distance
    circleloc.add(loc);               // Make it relative to boid's location
    
    PVector circleOffSet = new PVector(wanderR*cos(wandertheta),wanderR*sin(wandertheta));
    PVector target = PVector.add(circleloc,circleOffSet);
    
    
    return steer(target, false);
  }
  
  // obstacle avoidance function 
  /////////////////////////////////
   PVector avoidObs2(ArrayList<Integer> tempobs){
    LinObs ob;
    PVector sum = new PVector(0,0,0);
    int count = 0;
    for(int i=0; i<tempobs.size();i++){
      ob = (LinObs) obs.get((int) tempobs.get(i));
      PVector local = ob.test(loc);
      count++;
      sum.add(local);
    }  
    if(count>0){
      sum.div(count);
      return sum;
    }
    return new PVector();
  }

  // behavioural functions - sep, coh, ali
  /////////////////////////////////
  
  void flockInteract(ArrayList<Integer> tempboids,ArrayList boids){ //____________compute sep(0),ali(1)&Coh(2) at once
    PVector[] Allsteer = new PVector[]{ new PVector(0,0,0), new PVector(0,0,0), new PVector(0,0,0)}; 
    int[] Allcount = new int[]{0,0,0};
    PVector steer;
    
    for(int i = 0;i<tempboids.size(); i++){   //for all neighbor boids
      Boid other = (Boid) boids.get((int)tempboids.get(i));
      float d = PVector.dist(other.loc, loc);
      if ((other.type == 4)&&((this.type==1)||(this.type==3))){ //___Separation
        PVector diff = PVector.sub(loc, other.loc);
        diff.normalize();
        diff.div(d);
        Allsteer[0].add(diff);
        Allcount[0]++;
      }
      if ((other.type == this.type)){ //____FAlig & Cohesion
        Allsteer[1].add(other.vel); 
        Allcount[1]++;
        Allsteer[2].add(other.loc); 
        Allcount[2]++;  
      }     
      
    }
    for(int i=0;i<2;i++){
      steer = Allsteer[i];
      if(Allcount[i] > 0) 
        steer.div(Allcount[i]);
      if(steer.mag() > 0){
        steer.normalize();
        steer.mult(parent.MSP);
        steer.sub(vel);
        steer.limit(parent.MTS);
        if (i==0)
          steer.mult(parent.ForceSep);  
        else
          steer.mult(this.FAlig);              
        acc.add(steer); //embed to acceleration
      }
    }
    if (Allcount[2] > 0){
      Allsteer[2].div(Allcount[2]);
      Allsteer[2] = steer(Allsteer[2],false);
      Allsteer[2].mult(parent.FCoh); 
      acc.add(Allsteer[2]);
    } 
  }
  
  // display functions
  /////////////////////////////////////////////////////////////////////////
  void render() {    
    
    switch(type){
      case 1:    //STUDENTS RED
        fill(255,0,0);
        break;
      case 2:    //WORKERS BLUE
        fill(0,0,255);
        break;
      case 3:    //CASUAL USERS YELLOW
        fill(255,255,0);
        break;
      case 4:    //COPS WHITE
        fill(255,255,255);
        break;   
    }
    noStroke();
    pushMatrix();
    translate(loc.x,loc.y, loc.z);
    ellipse(0,0,r,r);
    if (type == 4){
      rectMode(CENTER);
      rect(0,0,2*r,2*r);
    }  
    popMatrix();
  }
  
}
