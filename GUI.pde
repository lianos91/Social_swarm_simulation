import controlP5.*;
ControlP5 controlP5;

void setupGUI()
{
  controlP5 = new ControlP5(this);

  Slider s1 = controlP5.addSlider("sep", 0, 5, flock.FSep, 20, 15, 100, 10); 
  s1.setId(1);

  Slider s2 = controlP5.addSlider("coh", 0, 5, flock.FCoh, 20, 30, 100, 10); 
  s2.setId(2);

  Slider s5 = controlP5.addSlider("Sep Dist", 0, 80, 30, 150, 15, 100, 10); 
  s5.setId(5);  

  Slider s6 = controlP5.addSlider("Vision", 0, 80, 30, 150, 30, 100, 10); 
  s6.setId(6);  
  
  Slider s7 = controlP5.addSlider("MSP", 0, 5, flock.MSP, 150, 45, 100, 10); 
  s7.setId(7);  

  Slider s8 = controlP5.addSlider("MTS", 0, 0.5, flock.MTS, 150, 60, 100, 10); 
  s8.setId(8);
  
  Slider s9 = controlP5.addSlider("Cluster Distance MAX", 0, 100, 0, 300, 15, 100, 10); 
  s9.setId(9);
  
  Slider s10 = controlP5.addSlider("Tail length", 0, 150, TAIL_LENGTH, 300, 30, 100, 10); 
  s10.setId(10);
  
  Slider s11= controlP5.addSlider("Tail resolution", 0, 25, TAIL_RES, 300, 45, 100, 10); 
  s11.setId(11);
  
  Slider s12= controlP5.addSlider("obstacle power", 0, 5, flock.FObs, 550, 15, 100, 10); 
  s12.setId(12);


  Slider s14= controlP5.addSlider("ali S", 0, 3, flock.FAlig[0], 20, 130, 100, 10); 
  s14.setId(14);
  Slider s15= controlP5.addSlider("wander S", 0, 3, flock.FWand[0], 20, 145, 100, 10); 
  s15.setId(15);
  Slider s16= controlP5.addSlider("fatt S", 0, 3, flock.FAttr[0], 20, 160, 100, 10); 
  s16.setId(16);
  Slider s17= controlP5.addSlider("ali W", 0, 3, flock.FAlig[1], 20, 190, 100, 10); 
  s17.setId(17);
  Slider s18= controlP5.addSlider("wander W", 0, 3, flock.FWand[1], 20, 205, 100, 10); 
  s18.setId(18);
  Slider s19= controlP5.addSlider("fatt W", 0, 3, flock.FAttr[1], 20, 220, 100, 10); 
  s19.setId(19);
  Slider s20= controlP5.addSlider("ali C", 0, 3, flock.FAlig[2], 20, 245, 100, 10); 
  s20.setId(20);
  Slider s21= controlP5.addSlider("wander C", 0, 3, flock.FWand[2], 20, 260, 100, 10); 
  s21.setId(21);
  Slider s22= controlP5.addSlider("fatt C", 0, 3, flock.FAttr[2], 20, 275, 100, 10); 
  s22.setId(22);
  Slider s23= controlP5.addSlider("ali Cops", 0, 3, flock.FAlig[3], 20, 300, 100, 10); 
  s23.setId(23);
  Slider s24= controlP5.addSlider("wander Cops", 0, 3, flock.FWand[3], 20, 315, 100, 10); 
  s24.setId(24);
  Slider s25= controlP5.addSlider("fatt Cops", 0, 3, flock.FAttr[3], 20, 330, 100, 10); 
  s25.setId(25);



  controlP5.addButton("RESET",0,width-50,20,30,50);
  controlP5.addButton("RE_GEO",0,width-100,20,30,50);
  controlP5.addButton("DEBUG",0,width-150,20,30,50);

  controlP5.setAutoDraw(false);
}

void DEBUG()
{
   DEBUG_LO = !DEBUG_LO;
   DEBUG_ATT = !DEBUG_ATT;
}

void RE_GEO()
{
  
  getObsSVG();
  
  getAtt2("map/Large_attractors.svg",4);
  getAtt2("map/Small_targets_attractors.svg",0.7);
  
  getSt("map/generators_day.svg",StartP);
  
  RESET();
  
  //setupGUI(); 
  
}

void controlEvent(ControlEvent theEvent) {

  switch(theEvent.controller().id()) 
  {
    case(1):
    flock.FSep = theEvent.controller().value();
    break;
    case(2):
    flock.FCoh = theEvent.controller().value();
    break;
    case(5):
    flock.desiredseparation = theEvent.controller().value();
    break;
    case(7):
    flock.MSP = theEvent.controller().value();
    break;
    case(8):
    flock.MTS = theEvent.controller().value();
    break;
    case(10):
    TAIL_LENGTH = (int)theEvent.controller().value();
    case(11):
    TAIL_RES = (int)theEvent.controller().value();
    break;
    case(12):
    flock.FObs = theEvent.controller().value();
    break;
    
    
    case(14):
    flock.FAlig[0] = theEvent.controller().value();
    break;
    case(15):
    flock.FWand[0] = theEvent.controller().value();
    break;
    case(16):
    flock.FAttr[0] = theEvent.controller().value();
    break;
    case(17):
    flock.FAlig[1] = theEvent.controller().value();
    break;
    case(18):
    flock.FWand[1] = theEvent.controller().value();
    break;
    case(19):
    flock.FAttr[1] = theEvent.controller().value();
    break;
    case(20):
    flock.FAlig[2] = theEvent.controller().value();
    case(21):
    flock.FWand[2] = theEvent.controller().value();
    break;
    case(22):
    flock.FAttr[2] = theEvent.controller().value();
    break;
    case(23):
    flock.FAlig[3] = theEvent.controller().value();
    break;
    case(24):
    flock.FWand[3] = theEvent.controller().value();
    break;
    case(25):
    flock.FAttr[3] = theEvent.controller().value();
    break;
  }
}  

