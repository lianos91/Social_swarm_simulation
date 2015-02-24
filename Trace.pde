class H_Trace{
  
  ArrayList L = new ArrayList();
  int k;
  float stdev;
  PVector mean;
  PVector rem; 
  public H_Trace() {
    rem = new PVector(0,0,0);
    mean = new PVector(0,0,0);
  }

  public void add(PVector loc) {
    L.add(loc);
    while(L.size() >= TAIL_LENGTH+1){
      rem = ((PVector)L.get(0)).get();
      L.remove(0);
    }
  }

  void drawlines(color c){
    
    PVector a, b;

    strokeWeight(1);
    noFill(); 

    for (int i = 1; i < L.size(); i++) {
      a = (PVector) L.get(i - 1);
      b = (PVector) L.get(i);
      float d = PVector.dist(a, b);
      if (d <50) {
        strokeWeight(1);
        stroke(c,map(i,0,L.size(),0,200));
        line(a.x, a.y, a.z, b.x, b.y, b.z);
      }
    }
  }

  void updateDev(int step){
    PVector x = new PVector(0,0,0);
    
    this.mean.set(0,0,0);
    for (int i=0; i < L.size(); i+= step ){
      mean.add((PVector)L.get(i));
    }
    this.mean.div(L.size()/step); // calculate mean
    
    this.stdev = 0;
    for (int i=0; i < L.size(); i+= step ){ //calc stdev
      x = ((PVector)L.get(i)).get();
      x.sub(mean);
      stdev += pow(x.mag(),2);
    } 
    stdev = sqrt(stdev/(L.size()/step));
    
  }
}

