MODULE XSVDCMP; (* driver for routine SVDCMP *)
 
   FROM SVD    IMPORT SVDCMP;
   FROM NRIO   IMPORT File, Open, Close, GetEOL, GetInt, GetReal, EOF,
                      ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr IMPORT Matrix, DisposeMatrix, CreateMatrix, 
                      MatrixPtr, NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                      NilVector, VectorPtr;

   VAR 
      j, k, l, m, n: INTEGER; 
      A, U, V: Matrix; 
      a, u, v: PtrToLines;
      W: Vector;
      w: PtrToReals;
      dataFile: File; 
       
BEGIN 
(* read input matrices *) 
   Open('Matrx3.DAT', dataFile); 
   GetEOL(dataFile); 
   WHILE NOT EOF(dataFile) DO 
      GetEOL(dataFile); 
      GetInt(dataFile, m); 
      GetInt(dataFile, n); 
	   GetEOL(dataFile); 
	   GetEOL(dataFile); (* copy original matrix into u *) 
	   CreateMatrix(m, n, A, a);
	   CreateMatrix(m, n, U, u); 
	   CreateMatrix(n, n, V, v);
	   CreateVector(n, W, w);
	   IF ((A # NilMatrix) AND (U # NilMatrix) AND (V # NilMatrix) AND 
	       (W # NilVector)) THEN
	      FOR k := 0 TO m-1 DO 
	         FOR l := 0 TO n-1 DO 
	            GetReal(dataFile, a^[k]^[l]); 
	            u^[k]^[l] := a^[k]^[l]
	         END; 
	         GetEOL(dataFile)
	      END; (* perform decomposition *) 
	      SVDCMP(U, W, V); (* write results *) 
	      WriteString('Decomposition matrices:'); 
	      WriteLn; 
	      WriteString('Matrix u'); 
	      WriteLn; 
	      FOR k := 0 TO m-1 DO 
	         FOR l := 0 TO n-1 DO 
	            WriteReal(u^[k]^[l], 12, 6)
	         END; 
	         WriteLn
	      END; 
	      WriteString('Diagonal of matrix w'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         WriteReal(w^[k], 12, 6)
	      END; 
	      WriteLn; 
	      WriteString('Matrix v-transpose'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-1 DO 
	            WriteReal(v^[l]^[k], 12, 6)
	         END; 
	         WriteLn
	      END; 
	      WriteLn; 
	      WriteString('Check product against original matrix:'); 
	      WriteLn; 
	      WriteString('Original matrix:'); 
	      WriteLn; 
	      FOR k := 0 TO m-1 DO 
	         FOR l := 0 TO n-1 DO 
	            WriteReal(a^[k]^[l], 12, 6)
	         END; 
	         WriteLn
	      END; 
	      WriteString('Product u*w*(v-transpose):'); 
	      WriteLn; 
	      FOR k := 0 TO m-1 DO 
	         FOR l := 0 TO n-1 DO 
	            a^[k]^[l] := 0.0; 
	            FOR j := 0 TO n-1 DO 
	               a^[k]^[l] := a^[k]^[l]+u^[k]^[j]*w^[j]*v^[l]^[j]
	            END
	         END; 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(a^[k]^[l], 12, 6)
	         END; 
	         WriteReal(a^[k]^[n-1], 12, 6); 
	         WriteLn; 
	      END; 
	      WriteString('***********************************'); 
	      WriteLn; 
	      WriteString('press RETURN for next problem'); 
	      WriteLn; 
	      ReadLn;
	   ELSE
	      Error('XSVDCMP', 'Not enough memory');
	      FOR k := 0 TO m-1 DO GetEOL(dataFile) END; 
	   END;
	   IF A # NilMatrix THEN DisposeMatrix(A) END;
	   IF U # NilMatrix THEN DisposeMatrix(U) END;
	   IF V # NilMatrix THEN DisposeMatrix(V) END;
	   IF W # NilVector THEN DisposeVector(W) END;
      GetEOL(dataFile); 
   END; 
   Close(dataFile)
END XSVDCMP.
