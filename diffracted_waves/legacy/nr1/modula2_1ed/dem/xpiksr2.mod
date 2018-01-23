MODULE XPikSr2; (* driver for routine PIKSR2 *) 
 
   FROM PikShell IMPORT PikSr2;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT File, Open, Close, GetEOL, GetReal, ReadLn, 
                        WriteLn, WriteReal, WriteString, Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector, VectorPtr;

   CONST
      np = 100;
   VAR 
      i, j: INTEGER; 
      A, B: Vector; 
      a, b: PtrToReals; 
      dataFile: File; 
       
BEGIN 
   CreateVector(np, A, a);
   CreateVector(np, B, b);
   IF (A # NilVector) AND (B # NilVector)THEN
	   Open('tarray.dat', dataFile); 
	   GetEOL(dataFile); 
	   FOR i := 0 TO np-1 DO 
	      GetReal(dataFile, a^[i])
	   END; 
	   Close(dataFile); (* generate b-array *) 
	   FOR i := 0 TO np-1 DO 
	      b^[i] := Float(i);
	   END; (* sort a and mix b *) 
	   PikSr2(A, B); 
	   WriteString('after sorting a and mixing b, array a is:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END; 
	   WriteString('... and array b is:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(b^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END; 
	   WriteString('press return to continue ...'); 
	   WriteLn; 
	   ReadLn; (* sort b and mix a *) 
	   PikSr2(B, A); 
	   WriteString('after sorting b and mixing a, array a is:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(a^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END; 
	   WriteString('... and array b is:'); 
	   WriteLn; 
	   FOR i := 0 TO 9 DO 
	      FOR j := 0 TO 9 DO 
	         WriteReal(b^[10*i+j], 6, 2)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XPikSrt', 'Not enough memory.');
	END;
   IF (A # NilVector) THEN DisposeVector(A); END;
   IF (B # NilVector) THEN DisposeVector(B); END;
END XPikSr2.
