class Cell{

  ArrayList<Integer> Obs;
  ArrayList<Integer> Boids;
  PVector index; //top-left corner
  int size;
  int offsetx;
  int offsety; 
  
  Cell(int x,int y,int s,int ofx,int ofy){
    this.Obs = new ArrayList();
    this.Boids = new ArrayList();
    this.index = new PVector(x,y);  
    this.size = s;
    this.offsetx = ofx;
    this.offsety = ofy;
  }

  void delete(int BoidIdx){
    this.Boids.remove( (Integer)BoidIdx );
  }
  void insert(int BoidIdx){
    this.Boids.add( BoidIdx );
  }

  float distance(float x1,float y1,float x2,float y2){ //distance of center of cell from p1p2 straight line
    float centerx,centery;
    centerx = (index.x+0.5)*this.size-offsetx;
    centery = (index.y+0.5)*this.size-offsety;
    float x4, y4; 
    x4 = x2 - x1; 
    y4 = y2 - y1; 
    PVector te = new PVector(x4, y4, 0);
    float u = (centerx - x1)*(x2 - x1) + (centery - y1)*(y2 - y1);
    u /= pow(te.dist(new PVector(0,0,0)), 2);
    float x, y; 
    x = x1 + u * (x2 - x1); 
    y = y1 + u * (y2 - y1); 
    PVector ab = new PVector(x,y,0);

    return PVector.dist(ab, new PVector(centerx, centery, 0));
  }
}
