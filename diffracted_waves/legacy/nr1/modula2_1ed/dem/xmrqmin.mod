MODULE XMrqMin; (* driver for routine MrqMin *) 
 
   FROM Transf   IMPORT GasDev;
   FROM NonLin   IMPORT MrqFunc, MrqMin;
   FROM NRMath   IMPORT Sqrt, Exp;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   PROCEDURE funcs(    x: REAL; 
                       A: Vector; 
                   VAR y: REAL; 
                       DYDA: Vector); 
      VAR 
         i, ii, ma, ndyda: INTEGER; 
         fac, ex, arg: REAL; 
         a, dyda: PtrToReals;
   BEGIN 
      GetVectorAttr(A, ma, a);
      GetVectorAttr(DYDA, ndyda, dyda);
      y := 0.0; 
      FOR ii := 1 TO ma DIV 3 DO 
         i := 3*ii-2; 
         arg := (x-a^[i])/a^[i+1]; 
         ex := Exp(-arg*arg); 
         fac := a^[i-1]*ex*2.0*arg; 
         y := y+a^[i-1]*ex; 
         dyda^[i-1] := ex; 
         dyda^[i] := fac/a^[i+1]; 
         dyda^[i+1] := fac*arg/a^[i+1]
      END
   END funcs; 
    
   CONST 
      npt = 100; 
      ma = 6; 
      spread = 0.001; 
   VAR 
      GasdevIset, i, idum, itst, j, jj, k, mfit: INTEGER; 
      MrqminOchisq, GasdevGset, alamda, chisq, ochisq: REAL; 
      work1, work2: REAL;
      X, Y, SIG, A, GUES, MRQMINBETA: Vector;
      x, y, sig, a, gues, mrqminbeta: PtrToReals;  
      LISTA: IVector;
      lista: PtrToIntegers; 
      COVAR, ALPHA: Matrix;
      covar, alpha: PtrToLines; 
    
BEGIN 
   CreateVector(ma, A, a);
   CreateVector(ma, GUES, gues);
   CreateVector(ma, MRQMINBETA, mrqminbeta);
   CreateVector(npt, X, x);
   CreateVector(npt, Y, y);
   CreateVector(npt, SIG, sig);
   CreateIVector(ma, LISTA, lista);
   CreateMatrix(ma, ma, COVAR, covar);
   CreateMatrix(ma, ma, ALPHA, alpha);
   IF (A # NilVector) AND (GUES # NilVector) AND (MRQMINBETA # NilVector) AND
      (X # NilVector) AND (Y # NilVector) AND (SIG # NilVector) AND 
      (LISTA # NilIVector) AND  (COVAR # NilMatrix) AND (ALPHA # NilMatrix) THEN
	   GasdevIset := 0; 
	   a^[0] := 5.0;  a^[1] := 2.0;  a^[2] := 3.0;  
	   a^[3] := 2.0;  a^[4] := 5.0;  a^[5] := 3.0; 
	   gues^[0] := 4.5;  gues^[1] := 2.2;  gues^[2] := 2.8; 
	   gues^[3] := 2.5;  gues^[4] := 4.9;  gues^[5] := 2.8; 
	   idum := -911; 
	   FOR i := 1 TO 100 DO 
	      x^[i-1] := 0.1*Float(i); 
	      y^[i-1] := 0.0; 
	      FOR jj := 1 TO 2 DO 
	         j := 3*jj-2; 
	         work1 := ((x^[i-1]-a^[j+1-1])/a^[j+2-1]);
	         work2 := (((x^[i-1]-a^[j+1-1])/a^[j+2-1])*work1);
	         y^[i-1] := y^[i-1]+a^[j-1]*Exp(-work2);
	      END; 
	      y^[i-1] := y^[i-1]*(1.0+spread*GasDev(idum)); 
	      sig^[i-1] := spread*y^[i-1]
	   END; 
	   mfit := 6; 
	   FOR i := 1 TO mfit DO 
	      lista^[i-1] := i
	   END; 
	   alamda := -1.0; 
	   FOR i := 1 TO ma DO 
	      a^[i-1] := gues^[i-1]
	   END; 
	   MrqMin(X, Y, SIG, npt, A, ma, LISTA, mfit, COVAR, ALPHA, funcs, MRQMINBETA, chisq, alamda); 
	   k := 1; 
	   itst := 0; 
	   REPEAT 
	      WriteLn; 
	      WriteString('Iteration #'); 
	      WriteInt(k, 2); 
	      WriteString('     chi-squared:'); 
	      WriteReal(chisq, 10, 4); 
	      WriteString('   alamda:'); 
	      WriteReal(alamda, 9, -10); 
	      WriteLn; 
	      WriteString('   a^[0]   a^[1]   a^[2]   a^[3]   a^[4]   a^[5]'); 
	      WriteLn; 
	      FOR i := 1 TO 6 DO 
	         WriteReal(a^[i-1], 8, 4)
	      END; 
	      WriteLn; 
	      INC(k, 1); 
	      ochisq := chisq; 
	      MrqMin(X, Y, SIG, npt, A, ma, LISTA, mfit, COVAR, ALPHA, funcs, MRQMINBETA, chisq, alamda); 
	      IF chisq > ochisq THEN 
	         itst := 0
	      ELSIF ABS(ochisq-chisq) < 0.1 THEN 
	         INC(itst, 1)
	      END; 
	   UNTIL itst >= 2; 
	   alamda := 0.0; 
	   MrqMin(X, Y, SIG, npt, A, ma, LISTA, mfit, COVAR, ALPHA, funcs, MRQMINBETA, chisq, alamda); 
	   WriteString('Uncertainties:'); 
	   WriteLn; 
	   FOR i := 1 TO 6 DO 
	      WriteReal(Sqrt(covar^[i-1]^[i-1]), 8, 4)
	   END; 
	   WriteLn;
	   ReadLn
   ELSE
      Error('XMrqMin', 'Not enough memory.');
   END;
   IF A # NilVector THEN DisposeVector(A) END;
   IF GUES # NilVector THEN DisposeVector(GUES) END;
   IF MRQMINBETA # NilVector THEN DisposeVector(MRQMINBETA) END;
   IF X # NilVector THEN DisposeVector(X) END;
   IF Y # NilVector THEN DisposeVector(Y) END;
   IF SIG # NilVector THEN DisposeVector(SIG) END;
   IF LISTA # NilIVector THEN DisposeIVector(LISTA) END;
   IF COVAR # NilMatrix THEN DisposeMatrix(COVAR) END;
   IF ALPHA # NilMatrix THEN DisposeMatrix(ALPHA) END;
END XMrqMin.
