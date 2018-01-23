MODULE XChSOne; (* driver for routine ChSOne *) 

   FROM Tests2   IMPORT ChSOne;
   FROM Transf   IMPORT ExpDev;
   FROM NRSystem IMPORT Float, Trunc;
   FROM NRMath   IMPORT Exp;
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
      bins, ebins: PtrToReals; 
      BINS, EBINS: Vector;
       
BEGIN 
   CreateVector(nbins, BINS, bins);
   CreateVector(nbins, EBINS, ebins);
   IF (BINS # NilVector) AND (EBINS # NilVector) THEN
	   idum := -15; 
	   FOR j := 0 TO nbins-1 DO 
	      bins^[j] := 0.0
	   END; 
	   FOR i := 1 TO npts DO 
	      x := ExpDev(idum); 
	      ibin := Trunc(x*Float(nbins)/3.0)+1; 
	      IF ibin <= nbins THEN 
	         bins^[ibin-1] := bins^[ibin-1]+1.0
	      END
	   END; 
	   FOR i := 1 TO nbins DO 
	      ebins^[i-1] := 3.0*Float(npts)/Float(nbins)*
	                   Exp((-3.0)*(Float(i)-0.5)/Float(nbins))
	   END; 
	   ChSOne(BINS, EBINS, -1, df, chsq, prob); 
	   WriteString('       expected       observed'); WriteLn; 
	   FOR i := 0 TO nbins-1 DO 
	      WriteReal(ebins^[i], 14, 2); 
	      WriteReal(bins^[i], 15, 2); 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('       chi-squared:'); 
	   WriteReal(chsq, 10, 4); 
	   WriteLn; 
	   WriteString('       probability:'); 
	   WriteReal(prob, 10, 4); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XChSOne', 'Not enough memory');
	END;
	IF BINS # NilVector THEN DisposeVector(BINS); END;
	IF EBINS # NilVector THEN DisposeVector(EBINS); END;
END XChSOne.
