MODULE XBCuInt; (* driver for routine BCUINT *) 

   FROM Inter2   IMPORT RealArray4, RealArray4by4, BCuInt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString;

   VAR 
      ansy, ansy1, ansy2, ey, ey1, ey2: REAL; 
      x1, x1l, x1u, x1x2, x2, x2l, x2u, xxyy: REAL; 
      i: INTEGER; 
      xx, y, y1, y12, y2, yy: RealArray4; 
      BcucofFlag: BOOLEAN; 
       
BEGIN 
   BcucofFlag := TRUE; 
   xx[0] := 0.0; 
   xx[1] := 2.0; 
   xx[2] := 2.0; 
   xx[3] := 0.0; 
   yy[0] := 0.0; 
   yy[1] := 0.0; 
   yy[2] := 2.0; 
   yy[3] := 2.0; 
   x1l := xx[0]; 
   x1u := xx[1]; 
   x2l := yy[0]; 
   x2u := yy[3]; 
   FOR i := 0 TO 3 DO 
      xxyy := xx[i]*yy[i]; 
      y[i] := (xxyy*xxyy); 
      y1[i] := 2.0*yy[i]*xxyy; 
      y2[i] := 2.0*xx[i]*xxyy; 
      y12[i] := 4.0*xxyy
   END; 
   WriteLn; 
   WriteString('    x1'); 
   WriteString('      x2'); 
   WriteString('      y'); 
   WriteString('     expect'); 
   WriteString('    y1'); 
   WriteString('    expect'); 
   WriteString('    y2'); 
   WriteString('    expect'); 
   WriteLn; 
   WriteLn; 
   FOR i := 1 TO 10 DO 
      x1 := 0.2*Float(i); 
      x2 := x1; 
      BCuInt(y, y1, y2, y12, x1l, x1u, x2l, x2u, x1, x2, ansy, ansy1, ansy2); 
      x1x2 := x1*x2; 
      ey := (x1x2*x1x2); 
      ey1 := 2.0*x2*x1x2; 
      ey2 := 2.0*x1*x1x2; 
      WriteReal(x1, 8, 4); 
      WriteReal(x2, 8, 4); 
      WriteReal(ansy, 8, 4); 
      WriteReal(ey, 8, 4); 
      WriteReal(ansy1, 8, 4); 
      WriteReal(ey1, 8, 4); 
      WriteReal(ansy2, 8, 4); 
      WriteReal(ey2, 8, 4); 
      WriteLn
   END;
   ReadLn;
END XBCuInt.
