MODULE XPolCoe; (* driver for routine PolCoe *) 
 
   FROM PolCoffs IMPORT PolCoe;
   FROM NRMath   IMPORT Exp, Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,  
                        NilVector;

   CONST 
      np = 5; 
      pi = 3.1415926; 
   VAR 
      i, j, nfunc: INTEGER; 
      f, sum, x: REAL; 
      COEFF, XA, YA: Vector; 
      coeff, xa, ya: PtrToReals; 
       
BEGIN 
   CreateVector(np, XA, xa);
   CreateVector(np, YA, ya);
   CreateVector(np, COEFF, coeff);
   IF (XA # NilVector) AND (YA # NilVector) AND (COEFF # NilVector) THEN
	   FOR nfunc := 1 TO 2 DO 
	      IF nfunc = 1 THEN 
	         WriteString('sine function from 0 to pi'); WriteLn; WriteLn; 
	         FOR i := 0 TO np-1 DO 
	            xa^[i] := Float(i+1)*pi/Float(np); 
	            ya^[i] := Sin(xa^[i])
	         END
	      ELSIF nfunc = 2 THEN 
	         WriteString('exponential function from 0 to 1'); WriteLn; WriteLn; 
	         FOR i := 0 TO np-1 DO 
	            xa^[i] := 1.0*Float(i+1)/Float(np); 
	            ya^[i] := Exp(xa^[i])
	         END
	      END; 
	      PolCoe(XA, YA, COEFF); 
	      WriteString('  '); 
	      WriteString('coefficients'); 
	      WriteLn; 
	      FOR i := 0 TO np-1 DO 
	         WriteReal(coeff^[i], 12, 6); 
	         WriteLn
	      END; 
	      WriteLn; 
	      WriteString('        x'); 
	      WriteString('         f(x)'); 
	      WriteString('     polynomial'); 
	      WriteLn; 
	      FOR i := 1 TO 10 DO 
	         IF nfunc = 1 THEN 
	            x := (-0.05+Float(i)/10.0)*pi; 
	            f := Sin(x)
	         ELSIF nfunc = 2 THEN 
	            x := -0.05+Float(i)/10.0; 
	            f := Exp(x)
	         END; 
	         sum := coeff^[np-1]; 
	         FOR j := np-2 TO 0 BY -1 DO 
	            sum := coeff^[j]+sum*x
	         END; 
	         WriteReal(x, 12, 6); 
	         WriteReal(f, 12, 6); 
	         WriteReal(sum, 12, 6); 
	         WriteLn
	      END; 
	      WriteLn; 
	      WriteString('************************************'); 
	      WriteLn; 
	      WriteString('press RETURN'); 
	      WriteLn; 
	      ReadLn;
	   END;
	ELSE
	   Error('XPolCoe', 'Not enough memory.');
	END;
   IF (XA # NilVector) THEN DisposeVector(XA); END;
   IF (YA # NilVector) THEN DisposeVector(YA); END;
   IF (COEFF # NilVector) THEN DisposeVector(COEFF); END;
END XPolCoe.
