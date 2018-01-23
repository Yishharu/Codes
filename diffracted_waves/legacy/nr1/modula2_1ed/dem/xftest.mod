MODULE XFTest; (* driver for routine FTest *) 
 
   FROM Tests1   IMPORT FTest;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      npts = 1000; 
      mpts = 500; 
      eps = 0.04; 
      nValue = 10; 
   VAR 
      f, factor, prob, vrnce: REAL; 
      i, idum, j: INTEGER; 
      DATA1, DATA2: Vector;
      data1, data2: PtrToReals; 
       
BEGIN 
(* generate two gaussian distributions with 
different variances *) 
   CreateVector(npts, DATA1, data1);
   CreateVector(mpts, DATA2, data2);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) THEN
	   idum := -144; 
	   WriteLn; 
	   WriteString('   Variance 1 = '); 
	   WriteReal(1.0, 5, 2); 
	   WriteLn; 
	   WriteString('   Variance 2'); 
	   WriteString('      Ratio'); 
	   WriteString('     Probability'); 
	   WriteLn; 
	   FOR i := 1 TO nValue+1 DO 
	      FOR j := 0 TO npts-1 DO 
	         data1^[j] := GasDev(idum)
	      END; 
	      vrnce := 1.0+Float(i-1)*eps; 
	      factor := Sqrt(vrnce); 
	      FOR j := 0 TO mpts-1 DO 
	         data2^[j] := factor*GasDev(idum)
	      END; 
	      FTest(DATA1, DATA2, f, prob); 
	      WriteReal(vrnce, 11, 4); 
	      WriteReal(f, 13, 4); 
	      WriteReal(prob, 13, 4); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error("XTTest", "Not enough memory.");
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1) END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2) END;
END XFTest.
