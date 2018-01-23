MODULE XChebPC; (* driver for routine ChebPc *) 
 
   FROM ChebPol  IMPORT ChebPC;
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
      a, b, poly, x, y: REAL; 
      i, j, mval: INTEGER; 
      C, CPC, CShort: Vector; 
      c, cpc: PtrToReals;

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
            CreateVector(mval, CPC, cpc);
	         IF (CShort # NilVector) AND (CPC # NilVector) THEN
			      ChebPC(CShort, CPC); (* test polynomial *) 
			      WriteLn; 
			      WriteString('        x'); 
			      WriteString('        actual'); 
			      WriteString('    polynomial'); 
			      WriteLn; 
			      FOR i := -8 TO 8 DO 
			         x := Float(i)*pio2/10.0; 
			         y := (x-(0.5*(b+a)))/(0.5*(b-a)); 
			         poly := cpc^[mval-1]; 
			         FOR j := mval-2 TO 0 BY -1 DO 
			            poly := poly*y+cpc^[j]
			         END; 
			         WriteReal(x, 12, 6); 
			         WriteReal(func(x), 12, 6); 
			         WriteReal(poly, 12, 6); 
			         WriteLn
			      END;
	            DisposeVector(CShort);
	            DisposeVector(CPC);
			   ELSE
	            Error('XChebPC', 'Not enough memory.');
			   END;
			END;
	   END; 
	   IF (C # NilVector) THEN DisposeVector(C); END;
	ELSE
	   Error('XChebPC', 'Not enough memory.');
	END;
END XChebPC.
