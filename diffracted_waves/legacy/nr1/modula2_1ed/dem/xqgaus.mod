MODULE XQGaus; (* driver for routine QGaus *) 

   FROM GaussQdr IMPORT QGaus;
   FROM NRMath   IMPORT Exp;
   FROM NRSystem IMPORT LongReal, Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString;

   CONST 
      x1 = 0.0; 
      x2 = 5.0; 
      nValue = 10; 
   VAR 
      dx, ss, x: REAL; 
      i: INTEGER; 

   PROCEDURE func(x: REAL): REAL; 
   BEGIN 
      RETURN x*Exp(-x); 
   END func; 
    
BEGIN 
   dx := (x2-x1)/Float(nValue); 
   WriteLn; 
   WriteString('0.0 to'); 
   WriteString('     qgaus'); 
   WriteString('     expected'); 
   WriteLn; 
   WriteLn; 
   FOR i := 1 TO nValue DO 
      x := x1+Float(i)*dx; 
      QGaus(func, x1, x, ss); 
      WriteReal(x, 5, 2); 
      WriteReal(ss, 12, 6); 
      WriteReal(-(1.0+x)*Exp(-x)+(1.0+x1)*Exp(-x1), 12, 6); 
      WriteLn;
   END;
   ReadLn;
END XQGaus.
