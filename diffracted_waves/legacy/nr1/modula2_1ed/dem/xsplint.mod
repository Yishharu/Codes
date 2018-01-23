MODULE XSplint; (* driver for routine Splint *) 
 
   FROM Splines  IMPORT Spline, Splint;
   FROM NRMath   IMPORT Exp, Sin, Cos;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,   
                        NilVector;

   CONST 
      np = 10; 
      pi = 3.1415926; 
   VAR 
      i, nfunc: INTEGER; 
      f, x, y, yp1, ypn: REAL; 
      XA, YA, Y2: Vector; 
      xa, ya, y2: PtrToReals; 
       
BEGIN 
   CreateVector(np, XA, xa);
   CreateVector(np, YA, ya);
   CreateVector(np, Y2, y2);
   FOR nfunc := 1 TO 2 DO 
      WriteLn; 
      IF nfunc = 1 THEN 
         WriteString('sine function from 0 to pi'); 
         WriteLn; 
         FOR i := 0 TO np-1 DO 
            xa^[i] := Float(i+1)*pi/Float(np); 
            ya^[i] := Sin(xa^[i])
         END; 
         yp1 := Cos(xa^[0]); 
         ypn := Cos(xa^[np-1])
      ELSIF nfunc = 2 THEN 
         WriteString('exponential function from 0 to 1'); 
         WriteLn; 
         FOR i := 0 TO np-1 DO 
            xa^[i] := 1.0*Float(i+1)/Float(np); 
            ya^[i] := Exp(xa^[i])
         END; 
         yp1 := Exp(xa^[0]); 
         ypn := Exp(xa^[np-1])
      END; (* call Spline to get second derivatives *) 
      Spline(XA, YA, yp1, ypn, Y2); (* call splint for interpolations *) 
      WriteLn; 
      WriteString('        x'); 
      WriteString('         f(x)'); 
      WriteString('    interpolation'); 
      WriteLn; 
      FOR i := 1 TO 10 DO 
         IF nfunc = 1 THEN 
            x := (-0.05+Float(i)/10.0)*pi; 
            f := Sin(x)
         ELSIF nfunc = 2 THEN 
            x := (-0.05)+Float(i)/10.0; 
            f := Exp(x)
         END; 
         Splint(XA, YA, Y2, x, y); 
         WriteReal(x, 12, 6); 
         WriteReal(f, 12, 6); 
         WriteReal(y, 12, 6); 
         WriteLn
      END; 
      WriteLn; 
      WriteString('***********************************'); 
      WriteLn; 
      WriteString('press RETURN'); 
      WriteLn; 
      ReadLn
   END;
   IF (XA # NilVector) THEN DisposeVector(XA) END;
   IF (YA # NilVector) THEN DisposeVector(YA) END;
   IF (Y2 # NilVector) THEN DisposeVector(Y2) END;
END XSplint.
