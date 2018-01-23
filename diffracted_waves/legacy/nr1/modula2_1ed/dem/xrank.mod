MODULE XRank; (* driver for routine Rank *) 
 
   FROM IxRank  IMPORT Indexx, Rank;
   FROM NRIO    IMPORT File, Open, Close, GetEOL, GetReal, ReadLn, WriteLn, WriteInt,
                       WriteReal, WriteString, Error;
   FROM NRIVect IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector, 
                       NilIVector;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector,
                       NilVector, VectorPtr;

   CONST
      np = 100;
   VAR 
      i, j, k, l: INTEGER; 
      A, B: Vector; 
      a, b: PtrToReals; 
      INDX, IRANK: IVector;
      indx, irank: PtrToIntegers; 
      dataFile: File; 
       
       
BEGIN 
   CreateVector(np, A, a);
   CreateVector(10, B, b);
   CreateIVector(np, INDX, indx);
   CreateIVector(np, IRANK, irank);
   IF (A # NilVector) AND (B # NilVector) AND
      (INDX # NilIVector) AND (IRANK # NilIVector) THEN
	   Open('tarray.dat', dataFile); 
	   GetEOL(dataFile); 
	   FOR i := 0 TO np-1 DO 
	      GetReal(dataFile, a^[i])
	   END; 
	   Close(dataFile); 
	   Indexx(A, INDX); 
	   Rank(INDX, IRANK); 
	   WriteString('original array is:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END; 
	   WriteString('table of ranks is:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteInt(irank^[10*i+j], 6)
	      END; 
	      WriteLn
	   END; 
	   WriteString('press return to continue...'); 
	   WriteLn; 
	   ReadLn; 
	   WriteString('array sorted according to rank table:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         k := 10*i+j; 
	         FOR l := 0 TO 99 DO 
	            IF irank^[l] = k+1 THEN 
	               b^[j] := a^[l]
	            END
	         END
	      END; 
	      FOR j := 0 TO 9 DO 
	         WriteReal(b^[j], 6, 2)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XPikSrt', 'Not enough memory.');
	END;
	IF (A # NilVector) THEN DisposeVector(A); END;
	IF (B # NilVector) THEN DisposeVector(B); END;
	IF (INDX # NilIVector) THEN DisposeIVector(INDX); END;
   IF (IRANK # NilIVector) THEN DisposeIVector(IRANK); END;
END XRank.
