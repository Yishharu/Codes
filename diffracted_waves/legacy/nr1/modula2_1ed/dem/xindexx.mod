MODULE XIndexx; (* driver for routine Indexx *) 
 
   FROM IxRank  IMPORT Indexx;
   FROM NRIO    IMPORT File, Open, Close, GetEOL,  GetReal, ReadLn,  
                       WriteLn, WriteReal, WriteString, Error;
   FROM NRIVect IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector,
                       NilIVector;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                       NilVector, VectorPtr;

   CONST
      np = 100;
   VAR 
      i, j: INTEGER; 
      A: Vector; 
      a: PtrToReals; 
      INDX: IVector;
      indx: PtrToIntegers; 
      dataFile: File; 
       
BEGIN 
   CreateVector(np, A, a);
   CreateIVector(np, INDX, indx);
   IF (A # NilVector) AND (INDX # NilIVector) THEN
	   Open('tarray.dat', dataFile); 
	   GetEOL(dataFile); 
	   FOR i := 0 TO np-1 DO 
	      GetReal(dataFile, a^[i]);
	   END; 
	   Close(dataFile); (* generate index for sorted array *) 
	   Indexx(A, INDX); (* write original array *) 
	   WriteString('original array:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END; (* write sorted array *) 
	   WriteString('sorted array:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[indx^[10*i+j]], 6, 2)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XPikSrt', 'Not enough memory.');
	END;
	IF (A # NilVector) THEN DisposeVector(A); END;
	IF (INDX # NilIVector) THEN DisposeIVector(INDX); END;
END XIndexx.
