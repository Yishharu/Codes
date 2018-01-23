MODULE XPikSrt; (* driver for routine PikSrt *) 

   FROM PikShell IMPORT PikSrt;
   FROM NRIO     IMPORT File, Open, Close, GetEOL, GetReal, ReadLn, WriteLn, 
                        WriteReal, WriteString, Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,
                        NilVector, VectorPtr;

   CONST
      np = 100;
   VAR 
      i, j: INTEGER; 
      A: Vector;
      a: PtrToReals; 
      dataFile: File; 
       
BEGIN 
   CreateVector(np, A, a);
   IF (A # NilVector) THEN
      Open('tarray.dat', dataFile); 
      GetEOL(dataFile); 
	   FOR i := 0 TO np-1 DO 
	      GetReal(dataFile, a^[i])
	   END; 
	   Close(dataFile); (* write original array *) 
	   WriteString('original array:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END; (* write sorted array *) 
	   PikSrt(A); 
	   WriteString('sorted array:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[10*(i)+j], 6, 2)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	   DisposeVector(A);
	ELSE
	   Error('XPikSrt', 'Not enough memory.');
	END;
END XPikSrt.
