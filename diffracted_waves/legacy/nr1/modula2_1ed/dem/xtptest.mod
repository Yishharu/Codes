MODULE XTPTest; (* driver for routine TPTest *) 
                (* compare two correlated distributions vs. two *) 

   FROM Tests1   IMPORT AveVar, TPTest;
   FROM Transf   IMPORT GasDev;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

(* uncorrelated distributions *) 
 
   CONST 
      npts = 500; 
      eps = 0.01; 
      nshft = 10; 
      anoise = 0.3; 
   VAR 
      ave1, ave2, ave3, gauss: REAL; 
      offset, prob1, prob2, shift, t1, t2: REAL; 
      var1, var2, var3: REAL; 
      i, idum, j: INTEGER; 
      DATA1, DATA2, DATA3: Vector;
      data1, data2, data3: PtrToReals; 
       
BEGIN 
   CreateVector(npts, DATA1, data1);
   CreateVector(npts, DATA2, data2);
   CreateVector(npts, DATA3, data3);
   IF (DATA1 # NilVector) AND (DATA2 # NilVector) AND 
      (DATA3 # NilVector) THEN
	   idum := -5; 
	   WriteString('                  Correlated:'); 
	   WriteString('                 Uncorrelated:'); 
	   WriteLn; 
	   WriteString('  Shift          t     Probability'); 
	   WriteString('          t     Probability'); 
	   WriteLn; 
	   offset := Float(nshft DIV 2)*eps; 
	   FOR j := 0 TO npts-1 DO 
	      gauss := GasDev(idum); 
	      data1^[j] := gauss; 
	      data2^[j] := gauss+anoise*GasDev(idum); 
	      data3^[j] := GasDev(idum)+anoise*GasDev(idum)
	   END; 
	   AveVar(DATA1, ave1, var1); 
	   AveVar(DATA2, ave2, var2); 
	   AveVar(DATA3, ave3, var3); 
	   FOR j := 0 TO npts-1 DO 
	      data1^[j] := data1^[j]-ave1+offset; 
	      data2^[j] := data2^[j]-ave2; 
	      data3^[j] := data3^[j]-ave3
	   END; 
	   FOR i := 1 TO nshft DO 
	      shift := Float(i)*eps; 
	      FOR j := 0 TO npts-1 DO 
	         data2^[j] := data2^[j]+eps; 
	         data3^[j] := data3^[j]+eps
	      END; 
	      TPTest(DATA1, DATA2, t1, prob1); 
	      TPTest(DATA1, DATA3, t2, prob2); 
	      WriteReal(shift, 6, 2); 
	      WriteReal(t1, 14, 4); 
	      WriteReal(prob1, 12, 4); 
	      WriteReal(t2, 16, 4); 
	      WriteReal(prob2, 12, 4); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error("XTTest", "Not enough memory.");
	END;
	IF DATA1 # NilVector THEN DisposeVector(DATA1) END;
	IF DATA2 # NilVector THEN DisposeVector(DATA2) END;
	IF DATA3 # NilVector THEN DisposeVector(DATA3) END;
END XTPTest.
