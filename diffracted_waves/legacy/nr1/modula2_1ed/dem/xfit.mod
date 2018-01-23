MODULE XFit; (* driver for routine Fit *) 

   FROM FitM     IMPORT Fit;
   FROM Transf   IMPORT GasDev;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      npt = 100; 
      spread = 0.5; 
   VAR 
      GasdevIset: INTEGER; 
      GasdevGset: REAL; 
      a, b, chi2, q, siga, sigb: REAL; 
      i, idum, mwt: INTEGER; 
      X, Y, SIG: Vector;
      x, y, sig: PtrToReals; 

BEGIN 
   CreateVector(npt, X, x);
   CreateVector(npt, Y, y);
   CreateVector(npt, SIG, sig);
   IF (X # NilVector) AND (Y # NilVector) AND (SIG # NilVector) THEN
	   GasdevIset := 0; 
	   idum := -117; 
	   FOR i := 0 TO npt-1 DO 
	      x^[i] := 0.1*Float(i+1); 
	      y^[i] := -2.0*x^[i]+1.0+spread*GasDev(idum); 
	      sig^[i] := spread
	   END; 
	   FOR mwt := 0 TO 1 DO 
	      Fit(X, Y, SIG, mwt, a, b, siga, sigb, chi2, q); 
	      WriteLn; 
	      IF mwt = 0 THEN 
	         WriteString('ignoring standard deviations'); WriteLn
	      ELSE 
	         WriteString('including standard deviation'); WriteLn
	      END; 
	      WriteString('     '); 
	      WriteString('a  =  '); 
	      WriteReal(a, 9, 6); 
	      WriteString('      '); 
	      WriteString('uncertainty:'); 
	      WriteReal(siga, 9, 6); 
	      WriteLn; 
	      WriteString('     '); 
	      WriteString('b  =  '); 
	      WriteReal(b, 9, 6); 
	      WriteString('      '); 
	      WriteString('uncertainty:'); 
	      WriteReal(sigb, 9, 6); 
	      WriteLn; 
	      WriteString('     '); 
	      WriteString('chi-squared: '); 
	      WriteReal(chi2, 14, 6); 
	      WriteLn; 
	      WriteString('     '); 
	      WriteString('goodness-of-fit: '); 
	      WriteReal(q, 10, 6); 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XFit', 'Not enough memory.');
	END;
	IF X # NilVector THEN DisposeVector(X) END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF SIG # NilVector THEN DisposeVector(SIG) END;
END XFit.
