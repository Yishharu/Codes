MODULE XLUBKSB; (* driver for routine LUBKSB *) 

   FROM LUDecomp IMPORT LUBKSB, LUDCMP;
   FROM NRIO     IMPORT File, Open, Close, GetEOL, GetInt, GetReal, EOF,
                        ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, MatrixPtr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, DisposeIVector, IVectorPtr, PtrToIntegers, 
                        CreateIVector, NilIVector;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,  
                        NilVector, VectorPtr;
 
   VAR 
      j, k, l, m, n: INTEGER; 
      p: REAL; 
      A, B, C: Matrix;
      a, b, c: PtrToLines; 
      INDX: IVector;
      indx: PtrToIntegers;
      X: Vector; 
      x: PtrToReals;
      dataFile: File; 
       
BEGIN 
   Open('Matrx1.DAT', dataFile); 
   GetEOL(dataFile); 
   WHILE NOT EOF(dataFile) DO 
      GetEOL(dataFile); 
      GetInt(dataFile, n); 
      GetInt(dataFile, m); 
      GetEOL(dataFile); 
      GetEOL(dataFile); 
	   CreateMatrix(n, n, A, a);
	   CreateMatrix(n, m, B, b);
	   CreateMatrix(n, n, C, c);
	   CreateIVector(n, INDX, indx);
	   CreateVector(n, X, x);
	   IF ((A # NilMatrix) AND (B # NilMatrix) AND (C # NilMatrix) AND 
	        (INDX # NilIVector) AND (X # NilVector)) THEN 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-2 DO 
	            GetReal(dataFile, a^[k]^[l])
	         END; 
	         GetReal(dataFile, a^[k]^[n-1]); 
	         GetEOL(dataFile)
	      END; 
	      GetEOL(dataFile); 
	      FOR l := 0 TO m-1 DO 
	         FOR k := 0 TO n-2 DO 
	            GetReal(dataFile, b^[k]^[l])
	         END; 
	         GetReal(dataFile, b^[n-1]^[l]); 
	         GetEOL(dataFile)
	      END; (* save matrix A for later testing *) 
	      FOR l := 0 TO n-1 DO 
	         FOR k := 0 TO n-1 DO 
	            c^[k]^[l] := a^[k]^[l]
	         END
	      END; (* do LU decomposition *) 
	      LUDCMP(C, INDX, p); (* solve equations for each right-hand vector *) 
	      FOR k := 0 TO m-1 DO 
	         FOR l := 0 TO n-1 DO 
	            x^[l] := b^[l]^[k]
	         END; 
	         LUBKSB(C, INDX, X); (* test results with original matrix *) 
	         WriteString('right-hand side vector:'); 
	         WriteLn; 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(b^[l]^[k], 12, 6)
	         END; 
	         WriteReal(b^[n-1]^[k], 12, 6); 
	         WriteLn; 
	         WriteString("result of matrix applied to sol'n vector"); 
	         WriteLn; 
	         FOR l := 0 TO n-1 DO 
	            b^[l]^[k] := 0.0; 
	            FOR j := 0 TO n-1 DO 
	               b^[l]^[k] := b^[l]^[k]+a^[l]^[j]*x^[j]
	            END
	         END; 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(b^[l]^[k], 12, 6)
	         END; 
	         WriteReal(b^[n-1]^[k], 12, 6); 
	         WriteLn; 
	         WriteString('***********************************'); 
	         WriteLn
	      END; 
	      WriteString('press RETURN for next problem:'); 
	      WriteLn; 
	      ReadLn;
	   ELSE
         Error('XLUBKSB', 'Not enough memory');
	      FOR k := 0 TO n DO GetEOL(dataFile) END; 
	      FOR l := 0 TO m-1 DO GetEOL(dataFile) END; 
	   END;
	   IF A # NilMatrix THEN DisposeMatrix(A) END;
	   IF B # NilMatrix THEN DisposeMatrix(B) END;
	   IF C # NilMatrix THEN DisposeMatrix(C) END;
	   IF INDX # NilIVector THEN DisposeIVector(INDX) END;
	   IF X # NilVector THEN DisposeVector(X) END;
      GetEOL(dataFile); 
   END; 
   Close(dataFile)
END XLUBKSB.
