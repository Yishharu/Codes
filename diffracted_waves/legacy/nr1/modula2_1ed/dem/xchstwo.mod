MODULE XCHSTwo; (* driver for routine ChSTwo *) 
 
   FROM Tests2   IMPORT ChSTwo;
   FROM Transf   IMPORT ExpDev;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString,
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals,
                        NilVector;

   CONST 
      nbins = 10; 
      npts = 2000; 
   VAR 
      chsq, df, prob, x: REAL; 
      i, ibin, idum, j: INTEGER; 
      bins1, bins2: PtrToReals; 
      BINS1, BINS2: Vector;
       
BEGIN 
   CreateVector(nbins, BINS1, bins1);
   CreateVector(nbins, BINS2, bins2);
   IF (BINS1 # NilVector) AND (BINS2 # NilVector) THEN
	   idum := -18; 
	   FOR j := 0 TO nbins-1 DO 
	      bins1^[j] := 0.0; 
	      bins2^[j] := 0.0
	   END; 
	   FOR i := 1 TO npts DO 
	      x := ExpDev(idum); 
	      ibin := Trunc(x*Float(nbins)/3.0)+1; 
	      IF ibin <= nbins THEN 
	         bins1^[ibin-1] := bins1^[ibin-1]+1.0
	      END; 
	      x := ExpDev(idum); 
	      ibin := Trunc(x*Float(nbins)/3.0)+1; 
	      IF ibin <= nbins THEN 
	         bins2^[ibin-1] := bins2^[ibin-1]+1.0
	      END
	   END; 
	   ChSTwo(BINS1, BINS2, -1, df, chsq, prob); 
	   WriteLn; 
	   WriteString('      dataset 1      dataset 2'); 
	   WriteLn; 
	   FOR i := 0 TO nbins-1 DO 
	      WriteReal(bins1^[i], 13, 2); 
	      WriteReal(bins2^[i], 15, 2); 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('      chi-squared:'); 
	   WriteReal(chsq, 12, 4); 
	   WriteLn; 
	   WriteString('      probability:'); 
	   WriteReal(prob, 12, 4); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XChSTwo', 'Not enough memory');
	END;
	IF BINS1 # NilVector THEN DisposeVector(BINS1); END;
	IF BINS2 # NilVector THEN DisposeVector(BINS2); END;
END XCHSTwo.
