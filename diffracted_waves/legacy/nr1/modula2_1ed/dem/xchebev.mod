MODULE XChebEv; (* driver for routine ChebEv *) 
 
   FROM ChebAppr IMPORT ChebFt, ChebEv;
   FROM NRMath   IMPORT Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn,  ReadInt, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CopyVector, CreateVector, 
                        NilVector;

   CONST 
      nValue = 40; 
      pio2 = 1.5707963; 
   VAR 
      a, b, x: REAL; 
      i, mval: INTEGER; 
      C, CShort: Vector; 
      c, d: PtrToReals; 

   PROCEDURE func(x: REAL): REAL; 
   BEGIN 
      RETURN (x*x)*(x*x-2.0)*Sin(x); 
   END func; 
    
BEGIN 
   CreateVector(nValue, C, c);
   IF (C # NilVector) THEN 
	   a := -pio2; 
	   b := pio2; 
	   ChebFt(func, a, b, C); (* test chebyshev evaluation routine *) 
	   LOOP 
	      WriteLn; 
	      WriteString('How many terms in Chebyshev evaluation'); 
	      WriteLn; 
	      WriteString('Enter n between 6 and '); 
	      WriteInt(nValue, 2); 
	      ReadInt('. (n := 0 to END)', mval); 
	      IF (mval <= 0) OR (mval > nValue) THEN 
	         EXIT 
	      ELSE 
	         CopyVector(C, mval, CShort);
	         IF (CShort # NilVector) THEN
			      WriteLn; 
			      WriteString('        x        actual   chebyshev fit'); 
			      WriteLn; 
			      FOR i := -8 TO 8 DO 
			         x := Float(i)*pio2/10.0; 
			         WriteReal(x, 12, 6); 
			         WriteReal(func(x), 12, 6); 
			         WriteReal(ChebEv(a, b, CShort, x), 12, 6);
			         WriteLn;
			      END;
	            DisposeVector(CShort);
			   ELSE
	            Error('XChebEv', 'Not enough memory.');
			   END;
	      END; 
	   END;
	   DisposeVector(C);
	ELSE
	   Error('XChebEv', 'Not enough memory.');
	END;
END XChebEv.
