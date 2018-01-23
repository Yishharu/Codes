MODULE XMedFit; (* driver for routine MedFit *) 
 
   FROM MedFitM  IMPORT MedFit;
   FROM FitM     IMPORT Fit;
   FROM Transf   IMPORT GasDev;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      ndata = 100; 
      spread = 0.1; 
   VAR 
      GasdevIset: INTEGER; 
      GasdevGset: REAL; 
      a, abdev, b, chi2, q, siga, sigb: REAL; 
      i, idum, mwt: INTEGER; 
      SIG, X, Y: Vector;
      sig, x, y: PtrToReals; 
       
BEGIN 
   CreateVector(ndata, X, x);
   CreateVector(ndata, Y, y);
   CreateVector(ndata, SIG, sig);
   IF (X # NilVector) AND (Y # NilVector) AND (SIG # NilVector) THEN
	   GasdevIset := 0; 
	   idum := -1984; 
	   FOR i := 0 TO ndata-1 DO 
	      x^[i] := 0.1*Float(i); 
	      y^[i] := -2.0*x^[i]+1.0+spread*GasDev(idum); 
	      sig^[i] := spread
	   END; 
	   mwt := 1; 
	   WriteLn; 
	   Fit(X, Y, SIG, mwt, a, b, siga, sigb, chi2, q); 
	   WriteString('According to routine FIT the result is:'); WriteLn; 
	   WriteString('   a = '); 
	   WriteReal(a, 8, 4); 
	   WriteString('  uncertainty: '); 
	   WriteReal(siga, 8, 4); 
	   WriteLn; 
	   WriteString('   b = '); 
	   WriteReal(b, 8, 4); 
	   WriteString('  uncertainty: '); 
	   WriteReal(sigb, 8, 4); 
	   WriteLn; 
	   WriteString('   chi-squared: '); 
	   WriteReal(chi2, 8, 4); 
	   WriteString(' for '); 
	   WriteInt(ndata, 4); 
	   WriteString(' points'); 
	   WriteLn; 
	   WriteString('   goodness-of-fit: '); 
	   WriteReal(q, 8, 4); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('According to routine MedFit the result is:'); 
	   WriteLn; 
	   MedFit(X, Y, a, b, abdev); 
	   WriteString('   a = '); 
	   WriteReal(a, 8, 4); 
	   WriteLn; 
	   WriteString('   b = '); 
	   WriteReal(b, 8, 4); 
	   WriteLn; 
	   WriteString('   '); 
	   WriteString('absolute deviation (per data point): '); 
	   WriteReal(abdev, 8, 4); 
	   WriteLn; 
	   WriteString('   '); 
	   WriteString('note: gaussian spread is'); 
	   WriteReal(spread, 8, 4); 
	   WriteString(')'); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XMedFit', 'Not enough memory.');
	END;
	IF X # NilVector THEN DisposeVector(X) END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF SIG # NilVector THEN DisposeVector(SIG) END;
END XMedFit.
