MODULE XTridag; (* driver for routine TRIDAG *) 
 
   FROM TridagS IMPORT Tridag;
   FROM NRIO    IMPORT File, Open, Close, GetEOL, GetInt,  GetReal, EOF,
                       ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                       NilVector, VectorPtr;

   VAR 
      k, n: INTEGER; 
      DIAG, SUPERD, SUBD, RHS, U: Vector;
      diag, superd, subd, rhs, u: PtrToReals; 
      dataFile: File; 

BEGIN 
   Open('Matrx2.dat', dataFile); 
   GetEOL(dataFile); 
   WHILE NOT EOF(dataFile) DO 
      GetEOL(dataFile); 
      GetInt(dataFile, n); 
      GetEOL(dataFile); 
      GetEOL(dataFile); 
	   CreateVector(n, DIAG, diag);
	   CreateVector(n, SUPERD, superd);
	   CreateVector(n, SUBD, subd);
	   CreateVector(n, RHS, rhs);
	   CreateVector(n, U, u);
      IF ((DIAG # NilVector) AND (SUPERD # NilVector) AND (SUBD # NilVector) AND 
          (RHS # NilVector) AND (U # NilVector)) THEN
	      FOR k := 0 TO n-2 DO 
	         GetReal(dataFile, diag^[k])
	      END; 
	      GetReal(dataFile, diag^[n-1]); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      FOR k := 0 TO n-3 DO 
	         GetReal(dataFile, superd^[k])
	      END; 
	      GetReal(dataFile, superd^[n-2]); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      FOR k := 1 TO n-2 DO 
	         GetReal(dataFile, subd^[k])
	      END; 
	      GetReal(dataFile, subd^[n-1]); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      FOR k := 0 TO n-2 DO 
	         GetReal(dataFile, rhs^[k])
	      END; 
	      GetReal(dataFile, rhs^[n-1]); 
	      GetEOL(dataFile); (* carry out solution *) 
	      Tridag(SUBD, DIAG, SUPERD, RHS, U); 
	      WriteString('the solution vector is:'); 
	      WriteLn; 
	      FOR k := 0 TO n-2 DO 
	         WriteReal(u^[k], 12, 6)
	      END; 
	      WriteReal(u^[n-1], 12, 6); 
	      WriteLn; (* test solution *) 
	      WriteString("(matrix)*(sol'n vector) should be:"); 
	      WriteLn; 
	      FOR k := 0 TO n-2 DO 
	         WriteReal(rhs^[k], 12, 6)
	      END; 
	      WriteReal(rhs^[n-1], 12, 6); 
	      WriteLn; 
	      WriteString('actual result is:'); 
	      WriteLn; 
	      FOR k := 0 TO n-1 DO 
	         IF k = 0 THEN 
	            rhs^[k] := diag^[0]*u^[0]+superd^[0]*u^[1]
	         ELSIF k = n-1 THEN 
	            rhs^[k] := subd^[n-1]*u^[n-2]+diag^[n-1]*u^[n-1]
	         ELSE 
	            rhs^[k] := subd^[k]*u^[k-1]+diag^[k]*u^[k]+superd^[k]*u^[k+1]
	         END
	      END; 
	      FOR k := 0 TO n-2 DO 
	         WriteReal(rhs^[k], 12, 6)
	      END; 
	      WriteReal(rhs^[n-1], 12, 6); 
	      WriteLn; 
	      WriteString('***********************************'); 
	      WriteLn; 
	      WriteString('press RETURN for next problem:'); 
	      WriteLn; 
	      ReadLn;
	   ELSE
	      Error('XTridag', 'Not enough memory');
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
	      GetEOL(dataFile); 
      END;
      IF DIAG # NilVector THEN DisposeVector(DIAG) END;
      IF SUPERD # NilVector THEN DisposeVector(SUPERD) END;
      IF SUBD # NilVector THEN DisposeVector(SUBD) END;
      IF RHS # NilVector THEN DisposeVector(RHS) END;
      IF U # NilVector THEN DisposeVector(U) END;
      GetEOL(dataFile); 
   END; 
   Close(dataFile)
END XTridag.
