MODULE XQuad3D; (* driver for routine Quad3D *) 
 
   FROM IntMult  IMPORT Quad3D;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT LongReal, Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString;

   CONST 
      pi = 3.1415926; 
      nValue = 10; 
   VAR 
      i: INTEGER; 
      s, xmax, xmin, xmax5: REAL; 
      Quad3dX, Quad3dY: REAL; 

   PROCEDURE func(x, y, z: REAL): REAL; 
   BEGIN 
      RETURN x*x+y*y+z*z; 
   END func; 

   PROCEDURE z1(x, y: REAL): REAL; 
   BEGIN 
      RETURN -Sqrt(xmax*xmax-x*x-y*y); 
   END z1; 

   PROCEDURE z2(x, y: REAL): REAL; 
   BEGIN 
      RETURN Sqrt(xmax*xmax-x*x-y*y); 
   END z2; 

   PROCEDURE y1(x: REAL): REAL; 
   BEGIN 
      RETURN -Sqrt(xmax*xmax-x*x); 
   END y1; 

   PROCEDURE y2(x: REAL): REAL; 
   BEGIN 
      RETURN Sqrt(xmax*xmax-x*x); 
   END y2; 
    
BEGIN 
   WriteString('Integral of r^2 over a spherical volume'); 
   WriteLn; 
   WriteLn; 
   WriteString('       radius'); 
   WriteString('   Quad3D'); 
   WriteString('    Actual'); 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      xmax := 0.1*Float(i); 
      xmin := -xmax; 
      Quad3D(xmin, xmax, func, y1, y2, z1, z2, s); 
      xmax5 := xmax*xmax*xmax*xmax*xmax; 
      WriteReal(xmax, 12, 2); 
      WriteReal(s, 10, 4); 
      WriteReal(4.0*pi*(xmax5)/5.0, 10, 4); 
      WriteLn
   END;
   ReadLn;
END XQuad3D.
