MODULE XEulSum; (* driver for routine EulSum *)
 
   FROM EulSumM  IMPORT EulSum;
   FROM NRSystem IMPORT Float;
   FROM NRMath   IMPORT Ln;
   FROM NRIO     IMPORT ReadLn,  ReadInt, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                        NilVector;

   CONST 
      nValue = 40;
   VAR 
      i, j, mval: INTEGER; 
      sum, term, x, xpower: REAL; 
      EULSUMWKSP: Vector;
      EulSumWksp: PtrToReals;
    
BEGIN 
(* evaluate Ln(1+x) := x-x^2/2+x^3/3-x^4/4 ... FOR -1<x<1 *) 
   CreateVector(nValue, EULSUMWKSP, EulSumWksp);
   IF (EULSUMWKSP # NilVector) THEN
	   LOOP
	      WriteLn;
	      WriteString('How many terms in polynomial');
	      WriteLn;
	      WriteString('Enter n between 1 and ');
	      WriteInt(nValue, 2);
	      WriteString('. (n := 0 to END)');
	      WriteLn;
	      ReadInt('', mval);
	      WriteLn; 
	      IF (mval <= 0) OR (mval > nValue) THEN 
	         EXIT 
	      END; 
	      WriteString('        x        actual    polynomial'); 
	      WriteLn; 
	      FOR i := -8 TO 8 DO 
	         x := Float(i)/10.0; 
	         sum := 0.0; 
	         xpower := -1.0; 
	         FOR j := 0 TO mval-1 DO 
	            xpower := -x*xpower; 
	            term := xpower/Float(j+1); 
	            EulSum(sum, term, j, EULSUMWKSP)
	         END; 
	         WriteReal(x, 12, 6); 
	         WriteReal(Ln(1.0+x), 12, 6); 
	         WriteReal(sum, 12, 6); 
	         WriteLn
	      END
	   END; 
      DisposeVector(EULSUMWKSP);
   ELSE
      Error("XEulSum", "Not enough memory.");
   END;
END XEulSum.
