MODULE XTTest; (* driver for routine TTest *) 
               (* generate gaussian distributed data *) 

   FROM Tests1   IMPORT TTest;
   FROM Transf   IMPORT GasDev;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      npts = 1024; 
      mpts = 512; 
      eps = 0.03; 
      nshft = 10; 
   VAR 
      DATA1, DATA2: Vector;
      data1, data2: PtrToReals; 
      i, idum, j: INTEGER; 
      prob, t: REAL; 
       
BEGIN 
   CreateVector(npts, DATA1, data1);
   CreateVector(mpts, DATA2, data2);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) THEN
	   idum := -11; 
	   FOR i := 0 TO npts-1 DO 
	      data1^[i] := GasDev(idum)
	   END; 
	   FOR i := 0 TO mpts-1 DO 
	      data2^[i] := Float(nshft DIV 2)*eps+GasDev(idum)
	   END; 
	   WriteString(' shift       t     probability'); WriteLn; 
	   FOR i := 1 TO nshft+1 DO 
	      TTest(DATA1, DATA2, t, prob); 
	      WriteReal(Float(i-1)*eps, 6, 2); 
	      WriteReal(t, 10, 2); 
	      WriteReal(prob, 10, 2); 
	      WriteLn; 
	      FOR j := 0 TO npts-1 DO 
	         data1^[j] := data1^[j]+eps
	      END
	   END;
	   ReadLn;
	ELSE
	   Error("XTTest", "Not enough memory.");
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1) END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2) END;
END XTTest.
