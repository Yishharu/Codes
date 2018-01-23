MODULE XSVDFit; (* driver for routine SVDFit *) 
                (* polynomial fit *) 

   FROM LLSs     IMPORT SVDFit, SVDVar;
   FROM Transf   IMPORT GasDev;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                        Error;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

   CONST 
      npt = 100; 
      spread = 0.02; 
      npol = 5; 
      mp = npt; 
      np = npol; 
   VAR 
      GasdevIset: INTEGER; 
      GasdevGset: REAL; 
      chisq, work1, work2: REAL; 
      i, idum: INTEGER; 
      X, Y, SIG: Vector;
      x, y, sig: PtrToReals;  
      A, W: Vector;
      a, w: PtrToReals; 
      CVM, U, V: Matrix;
      cvm, u, v: PtrToLines; 
       
   (* This is essentially FPoly renamed. *) 
   PROCEDURE func(x: REAL; 
                  P: Vector); 
      VAR 
         j, ma: INTEGER; 
         p: PtrToReals;
   BEGIN 
      GetVectorAttr(P, ma, p);
      p^[0] := 1.0; 
      FOR j := 1 TO ma-1 DO 
         p^[j] := p^[j-1]*x
      END
   END func; 
    
BEGIN 
   CreateVector(npol, A, a);
   CreateMatrix(np, np, CVM, cvm);
   CreateMatrix(mp, np, U, u);
   CreateMatrix(np, np, V, v);
   CreateVector(npol, W, w);
   CreateVector(npt, X, x);
   CreateVector(npt, Y, y);
   CreateVector(npt, SIG, sig);
   IF (A # NilVector) AND (CVM # NilMatrix) AND (U # NilMatrix) AND
      (V # NilMatrix) AND (W # NilVector) AND (X # NilVector) AND
      (Y # NilVector) AND (SIG # NilVector) THEN
	   GasdevIset := 0; 
	   idum := -911; 
	   FOR i := 1 TO npt DO 
	      x^[i-1] := 0.02*Float(i); 
	      work1 := 4.0+x^[i-1]*5.0;
	      work2 := 3.0+x^[i-1]*work1;
	      y^[i-1] := 1.0+x^[i-1]*(2.0+x^[i-1]*work2); 
	      y^[i-1] := y^[i-1]*(1.0+spread*GasDev(idum)); 
	      sig^[i-1] := y^[i-1]*spread
	   END; 
	   SVDFit(X, Y, SIG, A, U, V, W, func, chisq); 
	   SVDVar(V, W, CVM); 
	   WriteLn; 
	   WriteString('Polynomial fit:'); WriteLn; 
	   FOR i := 0 TO npol-1 DO 
	      WriteReal(a^[i], 12, 6); 
	      WriteString('  +-'); 
	      WriteReal(Sqrt(cvm^[i]^[i]), 10, 6); 
	      WriteLn
	   END; 
	   WriteString('Chi-squared'); 
	   WriteReal(chisq, 12, 6); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XSVDFit', 'Not enough memory.');
	END;
	IF X # NilVector THEN DisposeVector(X) END;
	IF Y # NilVector THEN DisposeVector(Y) END;
	IF SIG # NilVector THEN DisposeVector(SIG) END;
	IF A # NilVector THEN DisposeVector(A) END;
	IF W # NilVector THEN DisposeVector(W) END;
	IF CVM # NilMatrix THEN DisposeMatrix(CVM) END;
	IF U # NilMatrix THEN DisposeMatrix(U) END;
	IF V # NilMatrix THEN DisposeMatrix(V) END;
END XSVDFit.
