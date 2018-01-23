MODULE XGaussJ; (* driver program for subroutine GaussJ *)

   FROM GaussJor IMPORT GaussJ;
   FROM NRIO     IMPORT File, Open, Close, GetEOL, GetInt, GetReal, EOF,
                        ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                        Error;
   FROM NRMatr   IMPORT Matrix, GetMatrixAttr, CreateMatrix, DisposeMatrix, 
                        MatrixPtr, NilMatrix, PtrToLines;

   TYPE 
      StrArray27 = ARRAY [0..27-1] OF CHAR;

   VAR 
      j, k, l, m, n: INTEGER; 
      A, AI, U: Matrix; (* n, n *)
      B, X, T: Matrix; (* n, m *)
      a, ai, u, b, x, t: PtrToLines; 
      text: StrArray27; 
      dataFile: File; 
       
BEGIN
   Open('MATRX1.DAT', dataFile);
   GetEOL(dataFile); 
   WHILE NOT EOF(dataFile) DO 
      GetEOL(dataFile); 
      GetInt(dataFile, n); 
      GetInt(dataFile, m); 
      GetEOL(dataFile); 
      GetEOL(dataFile); 
      CreateMatrix(n, n, A, a);
      CreateMatrix(n, n, AI, ai);
      CreateMatrix(n, n, U, u);
      CreateMatrix(n, m, B, b);
      CreateMatrix(n, m, X, x);
      CreateMatrix(n, m, T, t);
      IF ((A # NilMatrix) AND (AI # NilMatrix) AND (U # NilMatrix) AND 
          (B # NilMatrix) AND (X # NilMatrix) AND (T # NilMatrix)) THEN
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
	         GetEOL(dataFile); 
	      END; (* save matrices for later testing of results *)  
	      FOR l := 0 TO n-1 DO 
	         FOR k := 0 TO n-1 DO 
	            ai^[k]^[l] := a^[k]^[l]
	         END; 
	         FOR k := 0 TO m-1 DO 
	            x^[l]^[k] := b^[l]^[k]
	         END
	      END; (* invert matrix *) 
	      GaussJ(AI, n, X, m); 
	      WriteLn; 
	      WriteString('Inverse of matrix a : '); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(ai^[k]^[l], 12, 6)
	         END; 
	         WriteReal(ai^[k]^[n-1], 12, 6); 
	         WriteLn
	      END; (* test results -- check inverse *) 
	      WriteString('a times a-inverse (compare with unit matrix)'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-1 DO 
	            u^[k]^[l] := 0.0; 
	            FOR j := 0 TO n-1 DO 
	               u^[k]^[l] := u^[k]^[l]+a^[k]^[j]*ai^[j]^[l]
	            END
	         END; 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(u^[k]^[l], 12, 6)
	         END; 
	         WriteReal(u^[k]^[n-1], 12, 6); 
	         WriteLn
	      END; (* check vector solutions *) 
	      WriteLn; 
	      WriteString('Check the following vectors for equality:'); 
	      WriteLn; 
	      WriteString('            original'); 
	      WriteString("   matrix*sol'n"); 
	      WriteLn; 
	      FOR l := 0 TO m-1 DO 
	         WriteString('vector '); 
	         WriteInt(l+1, 2); 
	         WriteString(':'); 
	         WriteLn; 
	         FOR k := 0 TO n-1 DO 
	            t^[k]^[l] := 0.0; 
	            FOR j := 0 TO n-1 DO 
	               t^[k]^[l] := t^[k]^[l]+a^[k]^[j]*x^[j]^[l]
	            END; 
	            WriteString('        '); 
	            WriteReal(b^[k]^[l], 12, 6); 
	            WriteReal(t^[k]^[l], 12, 6); 
	            WriteLn; 
	         END
	      END; 
	      WriteString('***********************************'); 
	      WriteLn; 
	      WriteString('press RETURN for next problem:'); 
	      WriteLn; 
	      ReadLn;
	   ELSE
	      Error('', 'Not enough memory');
	      FOR k := 0 TO n DO GetEOL(dataFile) END; 
	      FOR l := 0 TO m-1 DO GetEOL(dataFile); END;
	   END;
	   IF (A # NilMatrix) THEN DisposeMatrix(A) END;
	   IF (AI # NilMatrix) THEN DisposeMatrix(AI) END;
	   IF (U # NilMatrix) THEN DisposeMatrix(U) END;
	   IF (B # NilMatrix) THEN DisposeMatrix(B) END;
	   IF (X # NilMatrix) THEN DisposeMatrix(X) END;
	   IF (T # NilMatrix) THEN DisposeMatrix(T) END;
      GetEOL(dataFile); 
   END;  
   Close(dataFile)
END XGaussJ.
