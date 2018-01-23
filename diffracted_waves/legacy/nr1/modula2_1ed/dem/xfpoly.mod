MODULE XFPoly; (* driver for routine FPoly *) 
 
   FROM LLSs     IMPORT FPoly;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      nValue = 15; 
      dx = 0.1; 
      npoly = 5; 
   VAR 
      i, j: INTEGER; 
      x: REAL; 
      AFUNC: Vector;
      afunc: PtrToReals; 
       
BEGIN 
   CreateVector(npoly, AFUNC, afunc);
   IF AFUNC # NilVector THEN 
	   WriteLn; 
	   WriteString('                           powers of x'); WriteLn; 
	   WriteString('       x       x**0      x**1      x**2'); 
	   WriteString('      x**3      x**4'); WriteLn; 
	   FOR i := 1 TO nValue DO 
	      x := Float(i)*dx; 
	      FPoly(x, AFUNC); 
	      WriteReal(x, 10, 4); 
	      FOR j := 0 TO npoly-1 DO 
	         WriteReal(afunc^[j], 10, 4)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	   DisposeVector(AFUNC);
	ELSE
	   Error('XFPoly', 'Not enough memory.');
	END;
END XFPoly.
