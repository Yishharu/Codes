MODULE XSparse; (* driver for routine Sparse *) 

   FROM SparseL IMPORT Sparse;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                       GetVectorAttr, NilVector, VectorPtr;

   CONST
      n = 20;
   VAR 
      i, ii: INTEGER; 
      rsq: REAL; 
      B, BCMP, X: Vector;
      b, bcmp, x: PtrToReals;

   PROCEDURE aSub(xinV, xoutV: Vector); 
      VAR 
         i, n, nxOut: INTEGER; 
         xIn, xOut: PtrToReals;
   BEGIN 
      GetVectorAttr(xinV, n, xIn);
      GetVectorAttr(xoutV, nxOut, xOut);
      IF (n = nxOut) THEN
	      xOut^[0] := xIn^[0]+2.0*xIn^[1]; 
	      xOut^[n-1] := -2.0*xIn^[n-2]+xIn^[n-1]; 
	      FOR i := 1 TO n-2 DO 
	         xOut^[i] := -2.0*xIn^[i-1]+xIn^[i]+2.0*xIn^[i+1]
	      END
	   ELSE
	      Error('aSub', 'Inproper input vectors!');
	   END;
   END aSub; 

   PROCEDURE aTSub(xinV, xoutV: Vector); 
      VAR 
         i, n, nxOut: INTEGER; 
         xIn, xOut: PtrToReals;
   BEGIN 
      GetVectorAttr(xinV, n, xIn);
      GetVectorAttr(xoutV, nxOut, xOut);
      IF (n = nxOut) THEN
	      xOut^[0] := xIn^[0]-2.0*xIn^[1]; 
	      xOut^[n-1] := 2.0*xIn^[n-2]+xIn^[n-1]; 
	      FOR i := 1 TO n-2 DO 
	         xOut^[i] := 2.0*xIn^[i-1]+xIn^[i]-2.0*xIn^[i+1]
	      END
	   ELSE
	      Error('aSub', 'Inproper input vectors!');
	   END;
   END aTSub; 
    
BEGIN 
   CreateVector(n, X, x);
   CreateVector(n, B, b);
   CreateVector(n, BCMP, bcmp);
   IF ((X # NilVector) AND (B # NilVector) AND (BCMP # NilVector)) THEN
	   FOR i := 0 TO n-1 DO 
	      x^[i] := 0.0; 
	      b^[i] := 1.0
	   END; 
	   b^[0] := 3.0; 
	   b^[n-1] := -1.0; 
	   Sparse(B, X, rsq, aSub, aTSub); 
	   WriteString('sum-squared residual:'); 
	   WriteReal(rsq, 15, -10); 
	   WriteLn; 
	   WriteLn; 
	   WriteString('solution vector:'); 
	   WriteLn; 
	   FOR ii := 1 TO (n DIV 5) DO 
	      FOR i := 5*(ii-1) TO (5*ii)-1 DO 
	         WriteReal(x^[i], 12, 6)
	      END; 
	      WriteLn
	   END; 
	   IF n MOD 5 > 0 THEN 
	      FOR i := 1 TO n MOD 5 DO 
	         WriteReal(x^[5*(n DIV 5)+i-1], 12, 6)
	      END
	   END; 
	   WriteLn; 
	   aSub(X, BCMP); 
	   WriteLn; 
	   WriteString('press RETURN to continue...'); 
	   WriteLn; 
	   ReadLn; 
	   WriteString('test of solution vector:'); 
	   WriteLn; 
	   WriteString('      a*x'); 
	   WriteString('           b'); 
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteReal(bcmp^[i], 12, 6); 
	      WriteReal(b^[i], 12, 6); 
	      WriteLn
	   END;
   ELSE
      Error('XSparse', 'Not enough memory');
   END;
   IF (X # NilVector) THEN DisposeVector(X); END;
   IF (B # NilVector) THEN DisposeVector(B); END;
   IF (BCMP # NilVector) THEN DisposeVector(BCMP); END;
   ReadLn;
END XSparse.
