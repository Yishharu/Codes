MODULE XFLeg; (* driver for routine FLeg *) 
 
   FROM SpherHar IMPORT PLgndr;
   FROM LLSs     IMPORT FLeg;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      nValue = 5; 
      dx = 0.2; 
      npoly = 5; 
   TYPE 
      RealArrayNL = ARRAY [1..npoly] OF REAL; 
   VAR 
      i, j: INTEGER; 
      x: REAL; 
      AFUNC: Vector;
      afunc: PtrToReals; 
       
BEGIN 
   CreateVector(npoly, AFUNC, afunc);
   IF AFUNC # NilVector THEN
	   WriteLn; 
	   WriteString('                      legendre polynomials'); WriteLn; 
	   WriteString('      n=1       n=2       n=3       n=4       n=5'); 
	   WriteLn; 
	   FOR i := 1 TO nValue DO 
	      x := Float(i)*dx; 
	      FLeg(x, AFUNC); 
	      WriteString('x  := '); 
	      WriteReal(x, 6, 2); 
	      WriteLn; 
	      FOR j := 0 TO npoly-1 DO 
	         WriteReal(afunc^[j], 10, 4)
	      END; 
	      WriteString('  routine FLEG'); WriteLn; 
	      FOR j := 1 TO npoly DO 
	         WriteReal(PLgndr(j-1, 0, x), 10, 4);
	      END;
	      WriteString('  routine PLgndr');
	      WriteLn;
	   END;
	   ReadLn;
	   DisposeVector(AFUNC);
   ELSE
      Error('XFLeg' , 'Not enough memory.');
   END;
END XFLeg.
