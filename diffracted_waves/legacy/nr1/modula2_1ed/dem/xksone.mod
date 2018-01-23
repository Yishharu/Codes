MODULE XKSOne; (* driver for routine KSOne *) 
 
   FROM Tests2   IMPORT KSOne;
   FROM IncGamma IMPORT ErFCC;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      npts = 1000; 
      eps = 0.1; 
   VAR 
      GasdevIset: INTEGER; 
      GasdevGset: REAL; 
      i, idum, j: INTEGER; 
      d, factr, prob, varnce: REAL; 
      DATA: Vector;
      data: PtrToReals;
       
   PROCEDURE func(x: REAL): REAL; 
      VAR 
         y: REAL; 
   BEGIN 
      y := x/Sqrt(2.0); 
      RETURN 1.0-ErFCC(y); 
   END func; 
    
BEGIN 
   CreateVector(npts, DATA, data);
   IF DATA # NilVector THEN
	   GasdevIset := 0; 
	   idum := -5; 
	   WriteString('     variance ratio   k-s statistic'); 
	   WriteString('    probability'); 
	   WriteLn; 
	   WriteLn; 
	   FOR i := 1 TO 11 DO 
	      varnce := 1.0+Float(i-1)*eps; 
	      factr := Sqrt(varnce); 
	      FOR j := 0 TO npts-1 DO 
	         data^[j] := factr*ABS(GasDev(idum))
	      END; 
	      KSOne(DATA, func, d, prob); 
	      WriteReal(varnce, 16, 6); 
	      WriteReal(d, 16, 6); 
	      WriteReal(prob, 16, 6); 
	      WriteLn
	   END;
	   ReadLn;
	   DisposeVector(DATA);
	ELSE
	   Error('XKSOne', 'Not enough memory.');
	END;
END XKSOne.
