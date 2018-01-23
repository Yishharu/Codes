MODULE XRatInt; (* driver for routine RatInt *) 

   FROM RatIntM  IMPORT RatInt;
   FROM NRMath   IMPORT Exp, Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString;
  FROM NRVect    IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector;

   CONST 
      npt = 6; 
      eps = 1.0; 
   VAR 
      dyy, xx, yexp, yy: REAL; 
      i: INTEGER; 
      X, Y: Vector;
      x, y: PtrToReals;

   PROCEDURE f(x, eps: REAL): REAL; 
   BEGIN 
      RETURN x*Exp(-x)/(((x-1.0)*(x-1.0))+eps*eps); 
   END f; 
    
BEGIN 
   CreateVector(npt, X, x);
   CreateVector(npt, Y, y);
   FOR i := 0 TO npt-1 DO 
      x^[i] := Float(i)*2.0/Float(npt); 
      y^[i] := f(x^[i], eps)
   END; 
   WriteString('Diagonal rational function interpolation'); 
   WriteLn; 
   WriteLn; 
   WriteString('    x'); 
   WriteString('      interp.'); 
   WriteString('      accuracy'); 
   WriteString('      actual'); 
   WriteLn; 
   FOR i := 1 TO 10 DO 
      xx := 0.2*Float(i); 
      RatInt(X, Y, xx, yy, dyy); 
      yexp := f(xx, eps); 
      WriteReal(xx, 6, 2); 
      WriteReal(yy, 12, 6); 
      WriteString('    '); 
      WriteReal(dyy, 11, -10); 
      WriteReal(yexp, 12, 6); 
      WriteLn;
   END;
   ReadLn;
   IF (X # NilVector) THEN DisposeVector(X); END;
   IF (Y # NilVector) THEN DisposeVector(Y); END;
END XRatInt.
