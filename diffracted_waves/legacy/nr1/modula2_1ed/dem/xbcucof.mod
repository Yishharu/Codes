MODULE XBCuCof; (* driver for routine BCuCof *) 
 
   FROM NRMath IMPORT Exp; 
   FROM Inter2 IMPORT RealArray4, RealArray4by4, BCuCof;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteReal, WriteString;

   VAR 
      d1, d2, ee, x1x2: REAL; 
      i, j: INTEGER; 
      y, y1, y2, y12, x1, x2: RealArray4; 
      c: RealArray4by4; 
      BcucofFlag: BOOLEAN; 
       
BEGIN 
   BcucofFlag := TRUE; 
   x1[0] := 0.0; 
   x1[1] := 2.0; 
   x1[2] := 2.0; 
   x1[3] := 0.0; 
   x2[0] := 0.0; 
   x2[1] := 0.0; 
   x2[2] := 2.0; 
   x2[3] := 2.0; 
   d1 := x1[1]-x1[0]; 
   d2 := x2[3]-x2[0]; 
   FOR i := 0 TO 3 DO 
      x1x2 := x1[i]*x2[i]; 
      ee := Exp(-x1x2); 
      y[i] := x1x2*ee; 
      y1[i] := x2[i]*(1.0-x1x2)*ee; 
      y2[i] := x1[i]*(1.0-x1x2)*ee; 
      y12[i] := (1.0-3.0*x1x2+(x1x2*x1x2))*ee
   END; 
   BCuCof(y, y1, y2, y12, d1, d2, c); 
   WriteLn; 
   WriteString('Coefficients for bicubic interpolation:'); 
   WriteLn; 
   WriteLn; 
   FOR i := 0 TO 3 DO 
      FOR j := 0 TO 3 DO 
         WriteReal(c[i, j], 12, 6)
      END; 
      WriteLn
   END;
   ReadLn;
END XBCuCof.
