MODULE XSVBKSB; (* driver for routine SVBKSB *) 
 
   FROM SVD    IMPORT SVBKSB, SVDCMP;
   FROM NRIO   IMPORT File, Open, Close, GetEOL, GetInt, GetReal, EOF,
                      ReadLn, WriteLn, WriteInt, WriteReal, WriteString,  Error;
   FROM NRMatr IMPORT Matrix, DisposeMatrix, CreateMatrix, NilMatrix,
                      MatrixPtr, PtrToLines;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                      NilVector, VectorPtr;

   VAR 
      j, k, l, m, n: INTEGER; 
      wMax, wMin: REAL; 
      A, B, U, V: Matrix;
      a, b, u, v: PtrToLines;  
      W, X, C: Vector;
      w, x, c: PtrToReals;
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
	   CreateMatrix(n, n, U, u);
	   CreateMatrix(n, n, V, v); 
	   CreateVector(n, W, w);
	   CreateVector(n, X, x);
	   CreateVector(n, C, c);
      IF ((A # NilMatrix) AND (B # NilMatrix) AND (U # NilMatrix) AND 
          (V # NilMatrix) AND (W # NilVector) AND (X # NilVector) AND
          (C # NilVector)) THEN
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
	      END; (* copy a into u *) 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-1 DO 
	            u^[k]^[l] := a^[k]^[l]
	         END
	      END; (* decompose matrix a *) 
	      SVDCMP(U, W, V); (* find maximum singular value *) 
	      wMax := 0.0; 
	      FOR k := 0 TO n-1 DO 
	         IF w^[k] > wMax THEN 
	            wMax := w^[k]
	         END
	      END; (* define "small" *) 
	      wMin := wMax*(1.0E-6); (* zero the "small" singular values *) 
	      FOR k := 0 TO n-1 DO 
	         IF w^[k] < wMin THEN 
	            w^[k] := 0.0
	         END
	      END; (* backsubstitute for each right-hand side vector *) 
	      FOR l := 0 TO m-1 DO 
	         WriteLn; 
	         WriteString('Vector number '); 
	         WriteInt(l+1, 2); 
	         WriteLn; 
	         FOR k := 0 TO n-1 DO 
	            c^[k] := b^[k]^[l]
	         END; 
	         SVBKSB(U, W, V, C, X); 
	         WriteString('    solution vector is:'); 
	         WriteLn; 
	         FOR k := 0 TO n-2 DO 
	            WriteReal(x^[k], 12, 6)
	         END; 
	         WriteReal(x^[n-1], 12, 6); 
	         WriteLn; 
	         WriteString('    original right-hand side vector:'); 
	         WriteLn; 
	         FOR k := 0 TO n-2 DO 
	            WriteReal(c^[k], 12, 6)
	         END; 
	         WriteReal(c^[n-1], 12, 6); 
	         WriteLn; 
	         WriteString("    result of (matrix)*(sol'n vector):"); 
	         WriteLn; 
	         FOR k := 0 TO n-1 DO 
	            c^[k] := 0.0; 
	            FOR j := 0 TO n-1 DO 
	               c^[k] := c^[k]+a^[k]^[j]*x^[j]
	            END
	         END; 
	         FOR k := 0 TO n-2 DO 
	            WriteReal(c^[k], 12, 6)
	         END; 
	         WriteReal(c^[n-1], 12, 6); 
	         WriteLn
	      END; 
	      WriteString('***********************************'); 
	      WriteLn; 
	      WriteString('press RETURN for next problem'); 
	      WriteLn; 
	      ReadLn;
	   ELSE
	      Error('XSVBKSB', 'Not enough memory');
	      FOR k := 0 TO n DO GetEOL(dataFile) END; 
	      FOR l := 0 TO m-1 DO GetEOL(dataFile) END; 
	   END;
	   IF A # NilMatrix THEN DisposeMatrix(A) END;
	   IF B # NilMatrix THEN DisposeMatrix(B) END;
	   IF U # NilMatrix THEN DisposeMatrix(U) END;
	   IF V # NilMatrix THEN DisposeMatrix(V) END;
	   IF W # NilVector THEN DisposeVector(W) END;
	   IF C # NilVector THEN DisposeVector(C) END;
	   IF X # NilVector THEN DisposeVector(X) END;
      GetEOL(dataFile); 
   END; 
   Close(dataFile)
END XSVBKSB.
