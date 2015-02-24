
import processing.opengl.*;
import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;

PGraphics3D g3; 
PMatrix3D currCameraMatrix;
PeasyCam cam;
cameraDrag cdrag;

float worldSize = 1800;

Flock flock;

BinLat Grid;

ArrayList obs;
ArrayList LargeAtts;
ArrayList SmallAtts;
ArrayList StartP; //starting points
ArrayList InitStartP; // initialization starting points
ArrayList BusStart;

ArrayList copsst; //cops starting points
ArrayList copsat; //cops attractors


int GLOBAL_DEAD;
int TAIL_LENGTH;
int TAIL_RES;

int GlobalTime;
int ResetTime;
int SimulationMins=1; //virtual time
int SimulationHours=8;

int fps = 25; //frames per sec

int realsec;
boolean changesec;

int[] mode = {0,0,0};  //mode for each type [access with (type-1)],val 0 = Low,__val 1 = High 
int Timezone = 0;
int SpawnL = 2;
int SpawnH = 4;
int Range = 2;
int NumSourcesL = 1;
int NumSourcesH = 4;

int[] NumSource = {NumSourcesL, NumSourcesH};
int[] Spawn = {SpawnL, SpawnH};

boolean DEBUG_LO = false;
boolean DEBUG_ATT = false;
boolean PAUSED = false;

PrintWriter output;
PFont f;

PImage img;
PShape field;
int FieldXmax = 1200,FieldXmin=180;
int FieldYmax = 880,FieldYmin = -600;

int[] GlobTranslation = {-700,-100};//global translation
int NumBoids=0;




void setup(){
  
  frameRate(fps);
  output = createWriter("positions.txt");
  f = createFont("Arial",20,true);
  
  img = loadImage("map/nek2go2.jpg");
  
  size(1400,2000,OPENGL);
      
  g3 = (PGraphics3D)g;                    //camera settings
  cdrag = new cameraDrag();               //
  cam = new PeasyCam(this, 0,0,0, 1600);  //
  cam.setMinimumDistance(10);             //
  cam.setMaximumDistance(4500);           //
  cam.setLeftDragHandler(cdrag);          //
  cam.setCenterDragHandler(cdrag);        //
  cam.setRightDragHandler(cdrag);         //
  
  TAIL_LENGTH = 80;
  TAIL_RES = 5;
  
  obs  = new ArrayList();
  LargeAtts = new ArrayList();
  SmallAtts = new ArrayList();
  StartP = new ArrayList();
  InitStartP = new ArrayList();
  BusStart = new ArrayList();
  copsst = new ArrayList(); //cops starting 
  copsat = new ArrayList(); //cops attractors
  
  getObsSVG();
  getAtt2("map/Large_attractors.svg",1); //2nd arg is power:if pow >=0.6 then Large_attractor
  getAtt2("map/Small_targets_attractors.svg",0.2);
  
  getSt("map/generators_day.svg",StartP);
  //getSt("map/initgen.svg",InitStartP);
  
  //getSt("map/busstops.svg",BusStart);

  getCops(); 
  //getCops("map/cops.svg"); 
  
  flock = new Flock(#2EB1FF);
  flock.setParams(2,0, 30, 1.0, 0.05);
  flock.FObs = 5;
 
  
  RESET();

  setupGUI(); 
}

public void RESET(){
  flock.boids = new ArrayList(); //all the humans
  ResetTime = millis();
  int SimulationMins=0;
  int SimulationHours=8;
  
  Grid = null;
  Grid = new BinLat(80,0,800);
  Grid.ObInit(obs);
  
  InitGenBoids();
  
}

void draw(){
  
  background(0);
  pushMatrix();
  GlobalTime = millis();
    
  translate(GlobTranslation[0],GlobTranslation[1]);

  //Grid.visualize();
  
  //image(img,2,2);
  
  if (NumBoids<600) 
    RandGenBoids();
    
  if (changesec)
    println("boids: "+NumBoids);
  
  flock.run();
    
  for(int i = 0; i< obs.size(); i++){
    LinObs ob = (LinObs) obs.get(i); //SHOW OBJECTS
    ob.render();
  }
  for(int i = 0; i< LargeAtts.size(); i++){
    Attractor a = (Attractor) LargeAtts.get(i);  //SHOW Large ATTRACTORS
    a.render();
  }
  for(int i = 0; i< StartP.size(); i++){
    H_StartPoint s = (H_StartPoint) StartP.get(i); //SHOW STARTPOINTS
    s.render();
  }
  for (int i=0; i< copsst.size(); i++){
    H_StartPoint s = (H_StartPoint) copsst.get(i); //SHOW COP STARTPOINTS
    s.render();
  }
  for(int i = 0; i< SmallAtts.size(); i++){
    Attractor a = (Attractor) SmallAtts.get(i);  //SHOW Small ATTRACTORS
    a.render();
  }
  popMatrix();
  
  cam.beginHUD();
  DisplayTime();
  gui();
  cam.endHUD();
  cam.setMouseControlled(true);
  if(mouseY<80) {
    cam.setMouseControlled(false);
  } 
  
  //saveFrame("video/sw-#######.jpg");
}











//------ boid generating functions------//

 void generate(byte type,PVector loc,int birthTime){
    Boid b = new Boid(loc,flock,type,birthTime);  //t is TYPE. last arg = birthtime, 
    int ind = flock.addBoid(b);  //ind = index in flock.boids
    b.cell =  Grid.insBoid(ind,loc); //------update the specific cell(according to startpoint) return cell
   
 }
  
 void busGen(int Time){
   H_StartPoint p = (H_StartPoint) StartP.get(round(random(0,StartP.size()-1))); //pick random (bus) source
   //H_StartPoint p = (H_StartPoint) BusStart.get(round(random(0,StartP.size()-1))); //pick random (bus) source
   int NumOfSpawns = round(random(0,10));
   for(int i=0;i<NumOfSpawns;i++){
     byte type = (byte)round(random(0.5,3.4));//random type
     generate(type,p.loc,Time);  
   }
 }
void RandGenBoids(){
  int Time = GlobalTime - ResetTime;

 // if (SimulationMins%15 == 0)
    //busGen(Time);
  
  if(changesec){  //each second
    setZoneParams();   //set TimeZone
  
    for (byte ty=1;ty<=3;ty++){ //for each type
      for(int z=0;z<NumSource[mode[ty-1]];z++){ //for each of #sources
        H_StartPoint p = (H_StartPoint) StartP.get(round(random(-0.5,StartP.size()-1+0.4))); //pick random source
        int sp = round(random(-0.5, Spawn[mode[ty-1]]+0.4)); //spawn random boids,according to mode of this type(H-L)
        for(int i=0;i<=sp;i++)
          generate(ty,p.loc,Time);  //ty = type
      }
    }
  }
}

void InitGenBoids(){
  int rand,i,j,k;
 
  //generate from startpoints
  for(i = 0; i < StartP.size(); i++){
    H_StartPoint p = (H_StartPoint) StartP.get(i);
    rand = round(random(0,10));
    for(k = 0; k < rand; k++){
      byte t = (byte)round(random(0.5,3.4));
      generate(t,p.loc,0); //type,location,birthtime
    }
  }
  
  for (i=0; i< copsst.size(); i++){ 
    H_StartPoint p = (H_StartPoint) copsst.get(i);
    rand = round(random(0,2));
    for(j = 0; j < rand; j++)
      generate((byte)4,p.loc,0); //type 4 for cops
  }
  
  //generate from grid
  /*for (i=FieldXmin;i<FieldXmax;i+=150){                       //
    for(j=FieldYmin;j<FieldYmax;j+=150){                      //
      rand = round(random(0,10));                              //
      for(k = 0; k < rand; k++){                                //
        byte t = (byte)round(random(0.5,3.4));                  //
        generate(t,new PVector(i,j),0); //type,location,birthtime
      }                                                        //
    }                                                           //   
  } */                                                            //     
  
  //generate from InitStartPoints
  /* for(i = 0; i < InitStartP.size(); i++){
    H_StartPoint p = (H_StartPoint) InitStartP.get(i);
    rand = round(random(0,3));
    for(k = 0; k < rand; k++){
      byte t = (byte)round(random(0.5,3.4));
      generate(t,p.loc,0); //type,location,birthtime
    }
  }*/

}

//-------Time handling---------//

void DisplayTime(){ //_______________4 sec-physical == 1 min-virtual
  int Time = (GlobalTime-ResetTime);
  
  if (realsec >= (millis()%4000)){
    changesec = true;
    SimulationMins = (SimulationMins+1)%60;
    if (SimulationMins == 0)
      SimulationHours=(SimulationHours+1)%24;
  }
  else 
    changesec = false;
  realsec = millis()%4000;

  fill(255);
  textFont(f,40);
  String m = " "+SimulationMins;
  String h = " "+SimulationHours;
  if (SimulationMins < 10)
    m="0"+m;
  if (SimulationHours < 10)
    h="0"+h;
  text(h+" : "+m,20,120);
  if(SimulationHours == 4)
    noLoop();
}
void setZoneParams(){
  if (SimulationHours>=8 && SimulationHours<10 ){
    mode[0] = 1; mode[1] = 1; mode[2] = 0; Timezone = 0;
  }
  if (SimulationHours>=10 && SimulationHours<14 ){
    mode[0] = 1; mode[1] = 0; mode[2] = 0; Timezone = 1;
  }
  if (SimulationHours>=14 && SimulationHours<18 ){
    mode[0] = 1; mode[1] = 1; mode[2] = 1; Timezone = 2;
  }
  if (SimulationHours>=18 && SimulationHours<21 ){
    mode[0] = 0; mode[1] = 0; mode[2] = 1; Timezone = 3;
  }
  if (SimulationHours>=21 && SimulationHours<4 ){
    mode[0] = 0; mode[1] = 0; mode[2] = 1; Timezone = 4;
  }
  return;
}


//---------display gui&vectors-------//

void gui() {
  currCameraMatrix = new PMatrix3D(g3.camera);
  camera();
  fill(180,180,180,20); 
  noStroke();
  rect(0,0,width,80);
  controlP5.draw();
  g3.camera = currCameraMatrix;
}

void keyPressed(){
  if (key==' ') //space key
    if (PAUSED){
      PAUSED = false;
      loop();
    }
    else{
      PAUSED = true;
      noLoop();
    }
}
