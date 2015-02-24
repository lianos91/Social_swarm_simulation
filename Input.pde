void getpoints(String file, ArrayList<PVector> array){
  PShape pnts = loadShape(file);
  ArrayList<PShape> arr = new ArrayList<PShape>();
  PShape p;
  arr.add(pnts);
  while (arr.size()>0){
    p = arr.get(arr.size()-1);
    for(int j=0; j<p.getVertexCount(); j++){
      PVector p1 = new PVector(p.getVertexX(j),p.getVertexY(j));
      array.add(p1);  
    }
    arr.remove(arr.size()-1);
    int k = p.getChildCount();
    for (int i=0;i<k;i++)
      arr.add(p.getChild(i));
  }
}

void getAtt2(String file,float power){ //Attractor Power
  ArrayList<PVector> temparr = new ArrayList<PVector>();
  ArrayList Att;
  if(power <= 0.6)
    Att = SmallAtts;
  else
    Att = LargeAtts;
  
  getpoints(file,temparr);
  for (int i=0; i < temparr.size(); i+=8){
    PVector p1 = temparr.get(i).get();
    Att.add(new Attractor(p1,power));
  }
}

void getSt(String file,ArrayList start){
  ArrayList<PVector> temparr = new ArrayList<PVector>();
  getpoints(file,temparr);
  for (int i=0; i < temparr.size(); i+=8){
    PVector p1 = temparr.get(i).get();
    start.add(new H_StartPoint(p1));
  }
}

/*void getCops(String file){
 ArrayList<PVector> temparr = new ArrayList<PVector>();
  getpoints(file,temparr);
  for (int i=0; i < temparr.size(); i+=8){
    PVector p1 = temparr.get(i).get();
    copsst.add(new H_StartPoint(p1));
    copsat.add(new Attractor(p1,4)); //cops points-attractors
  }
}*/
void getCops(){
  String lines[] = loadStrings("cops.txt");
  
  println("There are " + lines.length + " cops points.");
  
  copsst = new ArrayList();
  copsat = new ArrayList();
  
  for (int i=0; i < lines.length; i++) 
  {
    String coords[] = split(lines[i], ", ");
    PVector p1 = new PVector(Float.parseFloat(coords[0]), Float.parseFloat(coords[1]));
    
    copsst.add(new H_StartPoint(p1));
    copsat.add(new Attractor(p1,4)); //cops points-attractors

  }
}

void getObsSVG(){
  field = loadShape("map/nek_final.svg");
  PVector p1 = new PVector();
  PVector p2 = new PVector();
  ArrayList<PShape> arr = new ArrayList<PShape>();
  PShape p;
  
  arr.add(field);
  while (arr.size()>0){
    p = arr.get(arr.size()-1);
    for(int j=1; j<p.getVertexCount(); j++){
      p1.set( p.getVertexX(j-1), p.getVertexY(j-1),0);
      p2.set(p.getVertexX(j),p.getVertexY(j),0);
      LinObs ob = new LinObs(p1,p2);
      obs.add(ob);
    }
    arr.remove(arr.size()-1);
    int k = p.getChildCount();
    for (int i=0;i<k;i++)
      arr.add(p.getChild(i));
    } 
}
