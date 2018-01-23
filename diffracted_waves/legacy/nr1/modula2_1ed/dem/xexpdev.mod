MODULE XExpDev; (* driver for routine ExpDev *) 

   FROM Transf   IMPORT ExpDev;
   FROM NRMath   IMPORT Exp;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRVect   IMPORT Vector, NilVector, CreateVector, DisposeVector, PtrToReals;

   CONST 
      npts = 1000; 
      ee = 2.718281828; 
   VAR 
      i, idum, j: INTEGER; 
      expect, total, y: REAL; 
      Ran3Inext, Ran3Inextp: INTEGER; 
      Ran3Ma, TRIG, X: Vector; 
      ran3Ma, trig, x: PtrToReals;
       
BEGIN 
   CreateVector(55, Ran3Ma, ran3Ma);
   CreateVector(21, TRIG, trig);
   CreateVector(21, X, x);
   IF (Ran3Ma # NilVector) AND (TRIG # NilVector) AND (X # NilVector) THEN
	   FOR i := 0 TO 20 DO 
	      trig^[i] := Float(i)/20.0; 
	      x^[i] := 0.0
	   END; 
	   idum := -1; 
	   FOR i := 1 TO npts DO 
	      y := ExpDev(idum); 
	      FOR j := 1 TO 20 DO 
	         IF (y < trig^[j]) AND (y > trig^[j-1]) THEN 
	            x^[j] := x^[j]+1.0
	         END
	      END
	   END; 
	   total := 0.0; 
	   FOR i := 1 TO 20 DO total := total+x^[i] END; 
	   WriteLn; 
	   WriteString('exponential distribution with'); 
	   WriteInt(npts, 7); 
	   WriteString(' points'); 
	   WriteLn; 
	   WriteString('   interval     observed    expected'); 
	   WriteLn; 
	   WriteLn; 
	   FOR i := 1 TO 20 DO 
	      x^[i] := x^[i]/total; 
	      expect := Exp((-(trig^[i-1]+trig^[i]))/2.0); 
	      expect := expect*0.05*ee/(ee-Float(1)); 
	      WriteReal(trig^[i-1], 6, 2); 
	      WriteReal(trig^[i], 6, 2); 
	      WriteReal(x^[i], 12, 6); 
	      WriteReal(expect, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XExpDev', 'Not enough memory.');
	END;
	IF Ran3Ma # NilVector THEN DisposeVector(Ran3Ma) END;
	IF TRIG # NilVector THEN DisposeVector(TRIG) END;
	IF X # NilVector THEN DisposeVector(X) END;
END XExpDev.
