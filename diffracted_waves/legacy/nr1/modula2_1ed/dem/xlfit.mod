MODULE XLFit; (* driver for routine LFit *) 
 
   FROM LLSs     IMPORT LFit, Function;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      npt = 100; 
      spread = 0.1; 
      nterm = 3; 
   VAR 
      GasdevIset: INTEGER; 
      GasdevGset: REAL;       
      chisq: REAL; 
      i, ii, idum, j, mfit: INTEGER; 
      LISTA: IVector;
      lista: PtrToIntegers; 
      COVAR: Matrix;
      covar: PtrToLines;
      A, X, Y, SIG: Vector; 
      a, x, y, sig: PtrToReals;  

   PROCEDURE funcs(x: REAL; 
                   AFUNC: Vector); 
      VAR 
         i, ma: INTEGER; 
         afunc: PtrToReals;
   BEGIN 
      GetVectorAttr(AFUNC, ma, afunc);
      afunc^[0] := 1.0; 
      FOR i := 2 TO ma DO 
         afunc^[i-1] := x*afunc^[i-2]
      END
   END funcs; 
    
BEGIN 
   CreateVector(npt, X, x);
   CreateVector(npt, Y, y);
   CreateVector(npt, SIG, sig);
   CreateVector(nterm, A, a);
   CreateIVector(nterm, LISTA, lista);
   CreateMatrix(nterm, nterm, COVAR, covar);
   IF (X # NilVector) AND (Y # NilVector) AND (SIG # NilVector) AND
      (A # NilVector) AND (LISTA # NilIVector) AND (COVAR # NilMatrix) THEN
	   GasdevIset := 0; 
	   idum := -911; 
	   FOR i := 1 TO npt DO 
	      x^[i-1] := 0.1*Float(i); 
	      y^[i-1] := Float(nterm); 
	      FOR j := nterm-1 TO 1 BY -1 DO 
	         y^[i-1] := Float(j)+y^[i-1]*x^[i-1]
	      END; 
	      y^[i-1] := y^[i-1]+spread*GasDev(idum); 
	      sig^[i-1] := spread
	   END; 
	   mfit := nterm; 
	   FOR i := 1 TO mfit DO 
	      lista^[i-1] := i
	   END; 
	   LFit(X, Y, SIG, A, LISTA, mfit, COVAR, funcs, chisq); 
	   WriteLn; 
	   WriteString('parameter'); 
	   WriteString('            uncertainty'); 
	   WriteLn; 
	   FOR i := 1 TO nterm DO 
	      WriteString('  a^['); 
	      WriteInt(i, 1); 
	      WriteString('] = '); 
	      WriteReal(a^[i-1], 8, 6); 
	      WriteReal(Sqrt(covar^[i-1]^[i-1]), 12, 6); 
	      WriteLn
	   END; 
	   WriteString('chi-squared = '); 
	   WriteReal(chisq, 12, -10); 
	   WriteLn; 
	   WriteString('full covariance matrix'); 
	   WriteLn; 
	   FOR i := 1 TO nterm DO 
	      FOR j := 1 TO nterm DO 
	         WriteReal(covar^[i-1]^[j-1], 12, 0)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('press RETURN to continue...'); 
	   WriteLn; 
	   ReadLn; (* now test the LISTA feature *) 
	   FOR i := 1 TO nterm DO 
	      lista^[i-1] := nterm+1-i
	   END; 
	   LFit(X, Y, SIG, A, LISTA, mfit, COVAR, funcs, chisq); 
	   WriteString('parameter            uncertainty'); WriteLn; 
	   FOR i := 1 TO nterm DO 
	      WriteString('  a^['); 
	      WriteInt(i, 1); 
	      WriteString('] = '); 
	      WriteReal(a^[i-1], 8, 6); 
	      WriteReal(Sqrt(covar^[i-1]^[i-1]), 12, 6); 
	      WriteLn
	   END; 
	   WriteString('chi-squared = '); 
	   WriteReal(chisq, 12, -10); 
	   WriteLn; 
	   WriteString('full covariance matrix'); 
	   WriteLn; 
	   FOR i := 1 TO nterm DO 
	      FOR j := 1 TO nterm DO 
	         WriteReal(covar^[i-1]^[j-1], 12, 0)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('press RETURN to continue...'); WriteLn; 
	   ReadLn; (* now check results of restricting fit parameters *) 
	   ii := 1; 
	   FOR i := 1 TO nterm DO 
	      IF ODD(i) THEN 
	         lista^[ii-1] := i; 
	         INC(ii, 1)
	      END
	   END; 
	   mfit := ii-1; 
	   LFit(X, Y, SIG, A, LISTA, mfit, COVAR, funcs, chisq); 
	   WriteString('parameter            uncertainty'); WriteLn; 
	   FOR i := 1 TO nterm DO 
	      WriteString('  a^['); 
	      WriteInt(i, 1); 
	      WriteString('] = '); 
	      WriteReal(a^[i-1], 8, 6); 
	      WriteReal(Sqrt(covar^[i-1]^[i-1]), 12, 6); 
	      WriteLn
	   END; 
	   WriteString('chi-squared = '); 
	   WriteReal(chisq, 12, -10); 
	   WriteLn; 
	   WriteString('full covariance matrix'); WriteLn; 
	   FOR i := 1 TO nterm DO 
	      FOR j := 1 TO nterm DO 
	         WriteReal(covar^[i-1]^[j-1], 13, 0)
	      END; 
	      WriteLn
	   END; 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XLFit', 'Not enough memory.');
	END;
	IF X # NilVector THEN DisposeVector(X) END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF SIG # NilVector THEN DisposeVector(SIG) END;
	IF A # NilVector THEN DisposeVector(A) END;
	IF LISTA # NilIVector THEN DisposeIVector(LISTA) END;
	IF COVAR # NilMatrix THEN DisposeMatrix(COVAR) END;
END XLFit.
