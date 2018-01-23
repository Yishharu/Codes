MODULE XSplin2; (* driver for routine Splin2 *) 
 
   FROM Inter2   IMPORT Splie2, Splin2;
   FROM NRMath   IMPORT Exp;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,WriteReal, WriteString,  
                        Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,   
                        NilVector;

   CONST 
      m = 10; 
      n = 10; 
   VAR 
      f, ff, x1x2, xx1, xx2: REAL; 
      i, j: INTEGER; 
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
	         y^[i]^[j] := x1x2*Exp(-x1x2);
	      END;
	   END; 
	   Splie2(X1, X2, Y, Y2); 
	   WriteString('         x1'); 
	   WriteString('          x2'); 
	   WriteString('        Splin2'); 
	   WriteString('      actual');  
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      xx1 := 0.1*Float(i+1); 
	      xx2 := xx1*xx1; 
	      Splin2(X1, X2, Y, Y2, xx1, xx2, f); 
	      x1x2 := xx1*xx2; 
	      ff := x1x2*Exp(-x1x2); 
	      WriteReal(xx1, 12, 6); 
	      WriteReal(xx2, 12, 6); 
	      WriteReal(f, 12, 6); 
	      WriteReal(ff, 12, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XSplin2', 'Not enough memory.');
	END;
   IF (X1 # NilVector) THEN DisposeVector(X1); END;
   IF (X2 # NilVector) THEN DisposeVector(X2); END;
   IF (Y # NilMatrix) THEN DisposeMatrix(Y); END;
   IF (Y2 # NilMatrix) THEN DisposeMatrix(Y2); END;
END XSplin2.
