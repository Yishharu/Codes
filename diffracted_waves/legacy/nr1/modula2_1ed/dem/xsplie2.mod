MODULE XSplie2; (* driver for routine Splie2 *) 
 
   FROM Inter2   IMPORT Splie2;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString,  
                        Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,   
                        NilVector;

   CONST 
      m = 10; 
      n = 10; 
   VAR 
      i, j: INTEGER; 
      x1x2: REAL; 
      X1, X2: Vector; 
      x1, x2: PtrToReals; 
      Y, Y2: Matrix; 
      y, y2: PtrToLines; 
       
BEGIN 
   CreateVector(m, X1, x1);
   CreateVector(n, X2, x2);
   CreateMatrix(m, n, Y, y);
   CreateMatrix(m, n, Y2, y2);
   IF (X1 # NilVector) AND (X2 # NilVector) AND 
      (Y # NilMatrix) AND (Y2 # NilMatrix) THEN
	   FOR i := 0 TO m-1 DO 
	      x1^[i] := 0.2*Float(i+1)
	   END; 
	   FOR i := 0 TO n-1 DO 
	      x2^[i] := 0.2*Float(i+1)
	   END; 
	   FOR i := 0 TO m-1 DO 
	      FOR j := 0 TO n-1 DO 
	         x1x2 := x1^[i]*x2^[j]; 
	         y^[i]^[j] := (x1x2*x1x2)
	      END
	   END; 
	   Splie2(X1, X2, Y, Y2); 
	   WriteLn; 
	   WriteString('second derivatives from SPLIE2'); 
	   WriteLn; 
	   WriteString('natural spline assumed'); 
	   WriteLn; 
	   FOR i := 0 TO 4 DO 
	      FOR j := 0 TO 4 DO 
	         WriteReal(y2^[i]^[j], 12, 6)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('actual second derivatives'); 
	   WriteLn; 
	   FOR i := 0 TO 4 DO 
	      FOR j := 0 TO 4 DO 
	         y2^[i]^[j] := 2.0*x1^[i]*x1^[i]
	      END; 
	      FOR j := 0 TO 4 DO 
	         WriteReal(y2^[i]^[j], 12, 6)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XSplie2', 'Not enough memory.');
	END;
   IF (X1 # NilVector) THEN DisposeVector(X1); END;
   IF (X2 # NilVector) THEN DisposeVector(X2); END;
   IF (Y # NilMatrix) THEN DisposeMatrix(Y); END;
   IF (Y2 # NilMatrix) THEN DisposeMatrix(Y2); END;
END XSplie2.
