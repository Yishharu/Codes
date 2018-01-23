MODULE XPCShft; (* driver for routine PCShft *) 
 
   FROM ChebPol  IMPORT ChebPC, PCShft;
   FROM ChebAppr IMPORT ChebFt;
   FROM NRMath   IMPORT Sin;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn,  ReadInt, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, CopyVector, 
                        NilVector;

   CONST 
      nValue = 40; 
      pio2 = 1.5707963; 
   VAR 
      a, b, poly, x: REAL; 
      i, j, mval: INTEGER; 
      C, CP, CShort: Vector; 
      c, cp: PtrToReals; 

   PROCEDURE func(x: REAL): REAL; 
   BEGIN 
      RETURN (x*x)*(x*x-2.0)*Sin(x); 
   END func; 
    
BEGIN 
   CreateVector(nValue, C, c);
   IF (C # NilVector) THEN 
	   a := -pio2; 
	   b := pio2; 
	   ChebFt(func, a, b, C); 
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
            CreateVector(mval, CP, cp);
	         IF (CShort # NilVector) AND (CP # NilVector) THEN
	         ChebPC(CShort, CP); 
		         PCShft(a, b, CP); (* test shifted polynomial *) 
			      WriteLn; 
			      WriteString('        x'); 
			      WriteString('        actual'); 
			      WriteString('    polynomial'); 
			      WriteLn; 
			      FOR i := -8 TO 8 DO 
			         x := Float(i)*pio2/10.0; 
			         poly := cp^[mval-1]; 
			         FOR j := mval-2 TO 0 BY -1 DO 
			            poly := poly*x+cp^[j]
			         END; 
			         WriteReal(x, 12, 6); 
			         WriteReal(func(x), 12, 6); 
			         WriteReal(poly, 12, 6); 
			         WriteLn
			      END;
	            DisposeVector(CShort);
	            DisposeVector(CP);
			   ELSE
	            Error('XPCShft', 'Not enough memory.');
			   END;
			END;
	   END; 
	   IF (C # NilVector) THEN DisposeVector(C); END;
	ELSE
	   Error('XPCShft', 'Not enough memory.');
	END;
END XPCShft.
