MODULE XKSTwo; (* driver for routine KSTwo *) 
 
   FROM Tests2   IMPORT KSTwo;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      n1 = 500; 
      n2 = 100; 
      eps = 0.2; 
   VAR 
      GasdevIset: INTEGER; 
      GasdevGset: REAL; 
      i, idum, j: INTEGER; 
      d, factr, prob, varnce: REAL; 
      DATA1, DATA2: Vector;
      data1, data2: PtrToReals; 
       
BEGIN 
   CreateVector(n1, DATA1, data1);
   CreateVector(n2, DATA2, data2);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) THEN
	   GasdevIset := 0; 
	   idum := -1357; 
	   FOR i := 0 TO n1-1 DO 
	      data1^[i] := GasDev(idum)
	   END; 
	   WriteString('    variance ratio  k-s statistic   probability'); 
	   WriteLn; 
	   idum := -2468; 
	   FOR i := 1 TO 11 DO 
	      varnce := 1.0+Float(i-1)*eps; 
	      factr := Sqrt(varnce); 
	      FOR j := 0 TO n2-1 DO 
	         data2^[j] := factr*GasDev(idum)
	      END; 
	      KSTwo(DATA1, DATA2, d, prob); 
	      WriteReal(varnce, 15, 6); 
	      WriteReal(d, 15, 6); 
	      WriteReal(prob, 15, 6); 
	      WriteLn;
	   END;
	   ReadLn;
	ELSE
	   Error('XKSTwo', 'Not enough memory.');
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1) END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2) END;
END XKSTwo.
