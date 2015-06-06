class test{

 public static void main (String[] args){System.out.println(0);}
}

class balls extends Applet
 {  
 int x;  
 public int init()  
 {  
 Thread t = new Thread(this);    
 t.start();  
 }  
 public  run()  
 {  
 while(true)  
 {  
 repaint();  
 Thread.sleep(100);    
 if( x < wi - 100)  
 x += 5;  
 if( y < he - 100)  
 y += 5;  
 if( x < wi - 100)  
 x = wi - 100;  
 if( y < he - 100)  
 y = he - 100;  
 sang1 = 10;  
 sang2 = 10;  
 }
 }  
 }  
 public paint(Graphics g)  
 {  
 Dimension d = getSize();  
 he = d.height;  
 wi = d.width;  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255))); 
 g.fillArc(x,20,100,100,sang1,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(x,20,100,100,sang1 + 90,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(x,20,100,100,sang1 + 180,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(x,20,100,100,sang1 + 270,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(10, y, 100, 100, sang2 ,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(10,y,100,100, sang2 + 90,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(10,y,100,100,sang2 + 180,90);  
 g.setColor(new Color(r.nextInt(255),r.nextInt(255),r.nextInt(255)));  
 g.fillArc(10,y,100,100,sang2 + 270,90);  
 }  
 }
