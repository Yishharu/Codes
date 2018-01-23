MODULE XToeplz; (* driver for routine Toeplz *)

   FROM ToeplzM  IMPORT Toeplz;
   FROM NRSystem IMPORT LongReal, D, Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteLongReal,
                        WriteString, Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector, VectorPtr;

   CONST 
      n = 5; 
      twonm1 = 9; (* twonm1=2*n-1 *) 
   VAR 
      i, j: INTEGER; 
      sum: LongReal; 
      R, X, Y: Vector;
      r, x, y: PtrToReals;

BEGIN 
   CreateVector(n, X, x);
   CreateVector(n, Y, y);
   CreateVector(twonm1, R, r);
   IF ((X # NilVector) AND (Y # NilVector) AND (R # NilVector)) THEN
	   FOR i := 0 TO n-1 DO 
	      y^[i] := 0.1*Float(i+1)*Float(i+1)
	   END; 
	   FOR i := 0 TO twonm1-1 DO 
	      r^[i] := 0.1*Float(i+1)*Float(i+1)
	   END; 
	   Toeplz(R, X, Y);
	   WriteString('Solution vector:');
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteString('    x^['); 
	      WriteInt(i, 1); 
	      WriteString('] :='); 
	      WriteReal(x^[i], 13, 0); 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('Test of solution:'); 
	   WriteLn; 
	   WriteString('    mtrx*soln'); 
	   WriteString('    original'); 
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      sum := 0.0; 
	      FOR j := 0 TO n-1 DO 
	         sum := sum+D(r^[n-1+i-j])*D(x^[j]);
	      END; 
	      WriteLongReal(sum, 12, 4);
	      WriteReal(y^[i], 12, 4);
	      WriteLn
	   END;
   ELSE
      Error('XToeplz', 'Not enough memory');
   END;
   ReadLn;
   IF (X # NilVector) THEN DisposeVector(X); END;
   IF (Y # NilVector) THEN DisposeVector(Y); END;
   IF (R # NilVector) THEN DisposeVector(R); END;
END XToeplz.
