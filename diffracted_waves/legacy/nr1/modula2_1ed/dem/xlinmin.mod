MODULE XLinMin; (* driver for routine LinMin *) 

   FROM DirSet   IMPORT LinMin;
   FROM NRMath   IMPORT Sqrt, Sin, Cos;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      ndim = 3; 
      pio2 = 1.5707963; 
   VAR 
      fret, sr2, x: REAL; 
      i, j: INTEGER; 
      P, XI: Vector;
      p, xi: PtrToReals; 

   PROCEDURE fnc(X: Vector): REAL; 
      VAR 
         i, n: INTEGER; 
         f: REAL; 
         x: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      f := 0.0; 
      FOR i := 0 TO 2 DO 
         f := f+((x^[i]-1.0)*(x^[i]-1.0))
      END; 
      RETURN f;
   END fnc; 
    
BEGIN 
   CreateVector(ndim, P, p);
   CreateVector(ndim, XI, xi);
   IF (P # NilVector) AND (XI # NilVector) THEN
	   WriteString('Minimum of a 3-d quadratic centered'); WriteLn; 
	   WriteString('at (1.0,1.0,1.0). Minimum is found'); WriteLn; 
	   WriteString('along a series of radials.'); WriteLn; WriteLn; 
	   WriteString('        x           y           z       minimum'); WriteLn; 
	   FOR i := 0 TO 10 DO 
	      x := pio2*Float(i)/10.0; 
	      sr2 := Sqrt(2.0); 
	      xi^[0] := sr2*Cos(x); 
	      xi^[1] := sr2*Sin(x); 
	      xi^[2] := 1.0; 
	      p^[0] := 0.0; 
	      p^[1] := 0.0; 
	      p^[2] := 0.0; 
	      LinMin(P, XI, fret, fnc); 
	      FOR j := 0 TO 2 DO WriteReal(p^[j], 12, 6) END; 
	      WriteReal(fret, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
   ELSE
	   Error('XLinMin', 'Not enough memory.');
	END;
	IF P # NilVector THEN DisposeVector(P); END;
	IF XI # NilVector THEN DisposeVector(XI); END;
END XLinMin.
