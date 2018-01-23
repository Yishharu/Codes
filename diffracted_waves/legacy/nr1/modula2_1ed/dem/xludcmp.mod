MODULE XLUDCMP; (* driver for routine LUDCMP *) 

   FROM LUDecomp IMPORT LUDCMP;
   FROM NRIO     IMPORT File,  Open, Close, GetEOL, GetInt, GetReal, EOF,
                        ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr   IMPORT Matrix, MatrixPtr, DisposeMatrix, CreateMatrix,
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, DisposeIVector, IVectorPtr, PtrToIntegers, 
                        CreateIVector, NilIVector;

   CONST 
      np = 20; 

   VAR 
      j, k, l, m, n, dum: INTEGER; 
      d: REAL; 
      A, XL, XU, X: Matrix; 
      a, xl, xu, x: PtrToLines;
      INDX, JNDX: IVector; 
      indx, jndx: PtrToIntegers; 
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
      CreateMatrix(n, n, XL, xl);
      CreateMatrix(n, n, XU, xu);
      CreateMatrix(n, n, X, x);
      CreateIVector(n, INDX, indx);
      CreateIVector(n, JNDX, jndx);
      IF ((A # NilMatrix) AND (XL # NilMatrix) AND (XU # NilMatrix) AND 
          (X # NilMatrix) AND (INDX # NilIVector) AND (JNDX # NilIVector)) THEN
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
	            GetReal(dataFile, x^[k]^[l])
	         END; 
	         GetReal(dataFile, x^[n-1]^[l]); 
	         GetEOL(dataFile)
	      END; (* print out A-matrix for comparison with product of lower *) 
	      (* and upper decomposition matrices *) 
	      WriteLn; 
	      WriteString('original matrix:'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(a^[k]^[l], 12, 6)
	         END; 
	         WriteReal(a^[k]^[n-1], 12, 6); 
	         WriteLn
	      END; (* perform the decomposition *) 
	      LUDCMP(A, INDX, d); (* compose separately the lower and upper matrices *) 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-1 DO 
	            IF l > k THEN 
	               xu^[k]^[l] := a^[k]^[l]; 
	               xl^[k]^[l] := 0.0
	            ELSIF l < k THEN 
	               xu^[k]^[l] := 0.0; 
	               xl^[k]^[l] := a^[k]^[l]
	            ELSE 
	               xu^[k]^[l] := a^[k]^[l]; 
	               xl^[k]^[l] := 1.0
	            END
	         END
	      END; (* compute product of lower and upper matrices for *) 
	      (* comparison with original matrix *) 
	      FOR k := 0 TO n-1 DO 
	         jndx^[k] := k; 
	         FOR l := 0 TO n-1 DO 
	            x^[k]^[l] := 0.0; 
	            FOR j := 0 TO n-1 DO 
	               x^[k]^[l] := x^[k]^[l]+xl^[k]^[j]*xu^[j]^[l]
	            END
	         END
	      END; 
	      WriteString('product of lower and upper matrices (rows unscrambled):'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         dum := jndx^[indx^[k]]; 
	         jndx^[indx^[k]] := jndx^[k]; 
	         jndx^[k] := dum
	      END; 
	      FOR k := 0 TO n-1 DO 
	         FOR j := 0 TO n-1 DO 
	            IF jndx^[j] = k THEN 
	               FOR l := 0 TO n-2 DO 
	                  WriteReal(x^[j]^[l], 12, 6)
	               END; 
	               WriteReal(x^[j]^[n-1], 12, 6); 
	               WriteLn
	            END
	         END
	      END; 
	      WriteString('lower matrix of the decomposition:'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(xl^[k]^[l], 12, 6)
	         END; 
	         WriteReal(xl^[k]^[n-1], 12, 6); 
	         WriteLn
	      END; 
	      WriteString('upper matrix of the decomposition:'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         FOR l := 0 TO n-2 DO 
	            WriteReal(xu^[k]^[l], 12, 6)
	         END; 
	         WriteReal(xu^[k]^[n-1], 12, 6); 
	         WriteLn
	      END; 
	      WriteString('***********************************'); 
	      WriteLn; 
	      WriteString('press RETURN for next problem:'); 
	      WriteLn; 
	      ReadLn;
	   ELSE
	      Error('XLUDCMP', 'Not enough memory');
	      FOR k := 0 TO n DO GetEOL(dataFile) END; 
	      FOR l := 0 TO m-1 DO GetEOL(dataFile) END; 
	   END;
      IF (A # NilMatrix) THEN DisposeMatrix(A); END;
      IF (XL # NilMatrix) THEN DisposeMatrix(XL); END;
      IF (XU # NilMatrix) THEN DisposeMatrix(XU); END;
      IF (X # NilMatrix) THEN DisposeMatrix(X); END;
      IF (INDX # NilIVector) THEN DisposeIVector(INDX); END;
      IF (JNDX # NilIVector) THEN DisposeIVector(JNDX); END;
	   GetEOL(dataFile); 
   END; 
   Close(dataFile)
END XLUDCMP.
