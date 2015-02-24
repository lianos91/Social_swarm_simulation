class BinLat{
  int CellSize;
  ArrayList<Cell> grid; //access (x1,y1): x1+Xmax*1
  int Xmax,Ymax;
  int offsetx,offsety;
 
  BinLat(int _size,int ofx,int ofy){
    this.grid = new ArrayList<Cell>();
    this.CellSize = _size;
    this.offsetx = ofx;
    this.offsety = ofy;
    this.Xmax = ceil(width/CellSize);
    this.Ymax = ceil(height/CellSize);
    println(Xmax+" "+Ymax);
    for(int y=0; y< Ymax; y++)
      for(int x=0; x< Xmax; x++)
        this.grid.add(new Cell(x,y,_size,offsetx,offsety));
  }
  
  Cell AccessCell(float indx,float indy){ //return cell from float indices
    return this.grid.get(int(indx)+int(indy)*this.Xmax);
  }
  
  PVector[] neighborcells(Cell cell){
    PVector central = new PVector(cell.index.x,cell.index.y);
    return new PVector[]{central,new PVector(central.x+1,central.y),new PVector(central.x-1,central.y),new PVector(central.x,central.y+1),new PVector(central.x,central.y-1),new PVector(central.x+1,central.y+1)};
  }
  
  void Migrate(Cell c0, Cell c1,int index){ //boid index go from cell_0 to cell_1
    c0.delete(index);
    c1.insert(index);
  }
  
  void visualize(){
    stroke(255);
    noFill();
      for(int y=0; y< Ymax; y++)
        for(int x=0; x< Xmax; x++){
          rect(this.grid.get(x+y*Xmax).index.x*CellSize-offsetx,this.grid.get(x+y*Xmax).index.y*CellSize-offsety,this.CellSize,this.CellSize);
        }
  }

 Cell findcell(float x1,float y1){ //find cell from spatial coordinates
    return AccessCell(floor((this.offsetx+x1)/CellSize),floor((this.offsety+y1)/CellSize));
  }
  
  void ObInit(ArrayList obs){
    for (int i=0;i<obs.size();i++){
      LinObs ob = (LinObs) obs.get(i);
      addObst(ob.x1,ob.y1,ob.x2,ob.y2,i);
    }
  
  }
  
  void addObst(float x1,float y1,float x2, float y2,int obIdx){
    //alg1
    float d1,d2;
    int sign_x = (x2>x1)?1:-1;
    int sign_y = (y2>y1)?1:-1;
    Cell cneigh,cnew;
    Cell c_end = findcell(x2,y2);
    Cell c = findcell(x1,y1);

    c_end.Obs.add(obIdx);    
    while(!(c==c_end)){
    //for(int k=0;k<10;k++){
      d1 = 2*CellSize;
      d2 = d1;
      c.Obs.add(obIdx);
      cnew = c;      
      if((c.index.x+sign_x>=0)&&(c.index.x+sign_x<this.Xmax)){ 
        cneigh = AccessCell(c.index.x+sign_x,c.index.y); 
        d1=cneigh.distance(x2,y2,x1,y1);
        if (d1<=CellSize*sqrt(2)/2)
          cnew = cneigh;
      }
      if((c.index.y+sign_y>=0)&&(c.index.y+sign_y<this.Ymax)){
        cneigh = AccessCell(c.index.x,c.index.y+sign_y);        
        d2=cneigh.distance(x2,y2,x1,y1);
        if (d2<=CellSize*sqrt(2)/2)
          if (d2<d1)
            cnew = cneigh;
      }
      c = cnew;
    }
  }
  
 Cell insBoid(int boididx,PVector location){ //insert boid to proper cell during birth,return reference to cell
    Cell c1 = findcell(location.x,location.y);
    c1.insert(boididx);
    return c1;
  }
  
  
}
