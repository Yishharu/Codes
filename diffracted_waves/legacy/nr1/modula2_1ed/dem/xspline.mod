MODULE XSpline; (* driver for routine Spline *) 
 
   FROM Splines  IMPORT Spline;
   FROM NRMath   IMPORT Sin, Cos;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,   
                        NilVector;

   CONST 
      n = 20; 
      pi = 3.1415926; 
   VAR 
      i: INTEGER; 
      yp1, ypn: REAL; 
      X, Y, Y2: Vector; 
      x, y, y2: PtrToReals; 
       
BEGIN 
   WriteString('second-derivatives for Sin(x) from 0 to pi'); 
   WriteLn; (* generate array for interpolation *) 
   CreateVector(n, X, x);
   CreateVector(n, Y, y);
   CreateVector(n, Y2, y2);
   FOR i := 0 TO n-1 DO 
      x^[i] := Float(i+1)*pi/Float(n); 
      y^[i] := Sin(x^[i])
   END; (* calculate 2nd derivative with spline *) 
   yp1 := Cos(x^[0]); 
   ypn := Cos(x^[n-1]); 
   Spline(X, Y, yp1, ypn, Y2); (* test result *) 
   WriteString('                 spline'); 
   WriteString('          actual'); 
   WriteLn; 
   WriteString('     number'); 
   WriteString('     2nd deriv'); 
   WriteString('       2nd deriv'); 
   WriteLn; 
   FOR i := 0 TO n-1 DO 
      WriteInt(i+1, 8); 
      WriteReal(y2^[i], 16, 6); 
      WriteReal(-Sin(x^[i]), 16, 6); 
      WriteLn
   END;
   ReadLn;
   IF (X # NilVector) THEN DisposeVector(X) END;
   IF (Y # NilVector) THEN DisposeVector(Y) END;
   IF (Y2 # NilVector) THEN DisposeVector(Y2) END;
END XSpline.
