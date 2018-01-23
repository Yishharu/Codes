MODULE XChInt; (* driver for routine ChInt *) 

   FROM ChDerInt IMPORT ChInt;
   FROM ChebAppr IMPORT ChebFt, ChebEv;
   FROM NRMath   IMPORT Sin, Cos;
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
      C, CINT, CShort: Vector; 
      c, cint, cShort: PtrToReals; 

   PROCEDURE func(x: REAL): REAL; 
   BEGIN 
      RETURN (x*x)*(x*x-2.0)*Sin(x); 
   END func; 

   PROCEDURE fint(x: REAL): REAL; 
   BEGIN 
      RETURN 4.0*x*(x*x-7.0)*Sin(x)-(x*x*x*x-14.0*x*x+28.0)*Cos(x); 
   END fint; 
    
BEGIN 
   CreateVector(nValue, C, c);
   IF (C # NilVector) THEN 
	   a := -pio2; 
	   b := pio2; 
	   ChebFt(func, a, b, C); (* test integral *) 
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
            CreateVector(mval, CINT, cint);
	         IF (CShort # NilVector) AND (CINT # NilVector) THEN
			      ChInt(a, b, CShort, CINT); 
			      WriteLn; 
			      WriteString('        x'); 
			      WriteString('        actual'); 
			      WriteString('  Cheby. integ.'); 
			      WriteLn; 
			      FOR i := -8 TO 8 DO 
			         x := Float(i)*pio2/10.0; 
			         WriteReal(x, 12, 6); 
			         WriteReal(fint(x)-fint(-pio2), 12, 6); 
			         WriteReal(ChebEv(a, b, CINT, x), 12, 6);
			         WriteLn
			      END;
	            DisposeVector(CShort);
	            DisposeVector(CINT);
			   ELSE
	            Error('XChInt', 'Not enough memory.');
			   END;
	      END; 
	   END;
	   IF (C # NilVector) THEN DisposeVector(C); END;
	ELSE
	   Error('XChInt', 'Not enough memory.');
	END;
END XChInt.
