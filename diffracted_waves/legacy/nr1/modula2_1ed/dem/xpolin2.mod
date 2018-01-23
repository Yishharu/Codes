MODULE XPolIn2; (* driver for routine PolIn2 *) 

   FROM Inter2   IMPORT PolIn2;
   FROM NRMath   IMPORT Exp, Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, MatrixPtr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,  
                        NilVector;

   CONST 
      n = 5; 
      pi = 3.1415926; 
   VAR 
      i, j: INTEGER; 
      dy, f, x1, x2, y: REAL; 
      X1A, X2A: Vector; 
      x1a, x2a: PtrToReals; 
      YA: Matrix; 
      ya: PtrToLines; 
       
BEGIN 
   CreateVector(n, X1A, x1a);
   CreateVector(n, X2A, x2a);
   CreateMatrix(n, n, YA, ya);
   IF (X1A # NilVector) AND (X2A # NilVector) AND (YA # NilMatrix) THEN
	   FOR i := 0 TO n-1 DO 
	      x1a^[i] := Float(i+1)*pi/Float(n); 
	      FOR j := 0 TO n-1 DO 
	         x2a^[j] := 1.0*Float(j+1)/Float(n); 
	         ya^[i]^[j] := Sin(x1a^[i])*Exp(x2a^[j])
	      END
	   END; (* test 2-dimensional interpolation *) 
	   WriteLn; 
	   WriteString('Two dimensional interpolation of Sin(x1)Exp(x2)'); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('       x1          x2         f(x)    interpolated      error'); 
	   WriteLn; 
	   FOR i := 1 TO 4 DO 
	      x1 := (-0.1+Float(i)/5.0)*pi; 
	      FOR j := 1 TO 4 DO 
	         x2 := -0.1+Float(j)/5.0; 
	         f := Sin(x1)*Exp(x2); 
	         PolIn2(X1A, X2A, YA, x1, x2, y, dy); 
	         WriteReal(x1, 12, 6); 
	         WriteReal(x2, 12, 6); 
	         WriteReal(f, 12, 6); 
	         WriteReal(y, 12, 6); 
	         WriteReal(dy, 15, 6); 
	         WriteLn
	      END; 
	      WriteString('***********************************'); 
	      WriteLn; 
	   END;
	   ReadLn;
	ELSE
	   Error('XPolIn2','Not enough memory.');
	END;
	IF (X1A # NilVector) THEN DisposeVector(X1A) END;
	IF (X2A # NilVector) THEN DisposeVector(X2A) END;
	IF (YA # NilMatrix) THEN DisposeMatrix(YA) END;
END XPolIn2.
