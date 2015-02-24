
public class cameraDrag implements PeasyDragHandler{  
  public void handleDrag(double dx,double dy){
    GlobTranslation[1] += dy/1.5;
    GlobTranslation[0] += dx/1.5;
  }
} 
