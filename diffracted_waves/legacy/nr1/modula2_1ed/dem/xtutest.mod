MODULE XTUTest; (* driver for routine TUTest *) 
 
   FROM Tests1   IMPORT TUTest;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      npts = 2000; 
      mpts = 600; 
      eps = 0.03; 
      var1 = 1.0; 
      var2 = 4.0; 
      nshft = 10; 
   VAR 
      fctr1, fctr2, prob, t: REAL; 
      i, idum, j: INTEGER; 
      DATA1, DATA2: Vector;
      data1, data2: PtrToReals; 
       
BEGIN 
(* generate two gaussian distributions of different variance *) 
   CreateVector(npts, DATA1, data1);
   CreateVector(mpts, DATA2, data2);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) THEN
	   idum := -1773; 
	   fctr1 := Sqrt(var1); 
	   FOR i := 0 TO npts-1 DO 
	      data1^[i] := fctr1*GasDev(idum)
	   END; 
	   fctr2 := Sqrt(var2); 
	   FOR i := 0 TO mpts-1 DO 
	      data2^[i] := Float(nshft DIV 2)*eps+fctr2*GasDev(idum)
	   END; 
	   WriteLn; 
	   WriteString('Distribution #1 : variance = '); 
	   WriteReal(var1, 6, 2); WriteLn; 
	   WriteString('Distribution #2 : variance = '); 
	   WriteReal(var2, 6, 2); WriteLn; 
	   WriteLn; 
	   WriteString(' shift       t     probability'); WriteLn; 
	   FOR i := 1 TO nshft+1 DO 
	      TUTest(DATA1, DATA2, t, prob); 
	      WriteReal(Float(i-1)*eps, 6, 2); 
	      WriteReal(t, 10, 2); 
	      WriteReal(prob, 11, 2); 
	      WriteLn; 
	      FOR j := 0 TO npts-1 DO 
	         data1^[j] := data1^[j]+eps
	      END
	   END;
	   ReadLn;
	ELSE
	   Error("XTUTest", "Not enough memory.");
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1) END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2) END;
END XTUTest.
