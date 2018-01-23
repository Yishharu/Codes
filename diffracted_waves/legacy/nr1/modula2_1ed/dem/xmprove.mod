MODULE XMprove; (* driver for routine Mprove *) 

   FROM IterImpr IMPORT Mprove;
   FROM LUDecomp IMPORT LUBKSB, LUDCMP;
   FROM Uniform  IMPORT Ran3;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, MatrixPtr,
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector,
                        IVectorPtr, NilIVector;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector,
                        VectorPtr, NilVector;

   CONST 
      n = 5; 
 
   VAR 
      Ran3Inext, Ran3Inextp, i, idum, j: INTEGER; 
      d: REAL; 
      A, AA: Matrix; (* n, n *) 
      B, X, Ran3MaV: Vector; (* n *) 
      INDX: IVector; (* n *) 
      a, aa: PtrToLines;
      b, x, Ran3Ma: PtrToReals;
      indx: PtrToIntegers;

BEGIN 
   CreateMatrix(n, n, A, a);
   CreateMatrix(n, n, AA, aa);
   CreateVector(n, B, b);
   CreateVector(n, X, x);
   CreateIVector(n, INDX, indx);
   CreateVector(55, Ran3MaV, Ran3Ma);
   IF ((A # NilMatrix) AND (AA # NilMatrix) AND (B # NilVector) AND 
       (X # NilVector) AND (INDX # NilIVector) AND (Ran3MaV # NilVector)) THEN
	   a^[0]^[0] := 1.0;  a^[0]^[1] := 2.0;  a^[0]^[2] := 3.0; 
	   a^[0]^[3] := 4.0;  a^[0]^[4] := 5.0;  
	   a^[1]^[0] := 2.0;  a^[1]^[1] := 3.0;  a^[1]^[2] := 4.0;  
	   a^[1]^[3] := 5.0;  a^[1]^[4] := 1.0;  
	   a^[2]^[0] := 1.0;  a^[2]^[1] := 1.0;  a^[2]^[2] := 1.0; 
	   a^[2]^[3] := 1.0;  a^[2]^[4] := 1.0; 
	   a^[3]^[0] := 4.0;  a^[3]^[1] := 5.0;  a^[3]^[2] := 1.0; 
	   a^[3]^[3] := 2.0;  a^[3]^[4] := 3.0; 
	   a^[4]^[0] := 5.0;  a^[4]^[1] := 1.0;  a^[4]^[2] := 2.0; 
	   a^[4]^[3] := 3.0;  a^[4]^[4] := 4.0; 
	   b^[0] := 1.0;      b^[1] := 1.0;      b^[2] := 1.0; 
	   b^[3] := 1.0;      b^[4] := 1.0; 
	   FOR i := 0 TO n-1 DO 
	      x^[i] := b^[i]; 
	      FOR j := 0 TO n-1 DO 
	         aa^[i]^[j] := a^[i]^[j]
	      END
	   END; 
	   LUDCMP(AA, INDX, d); 
	   LUBKSB(AA, INDX, X); 
	   WriteLn; 
	   WriteString('Solution vector for the equations:'); 
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteReal(x^[i], 12, 6)
	   END; 
	   WriteLn; (* now phoney up x and let MProve fit it *) 
	   idum := -13; 
	   FOR i := 0 TO n-1 DO 
	      x^[i] := x^[i]*(1.0+0.2*Ran3(idum))
	   END; 
	   WriteLn; 
	   WriteString('Solution vector with noise added:'); 
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteReal(x^[i], 12, 6)
	   END; 
	   WriteLn; 
	   Mprove(A, AA, INDX, B, X); 
	   WriteLn; 
	   WriteString('Solution vector recovered by MProve:'); 
	   WriteLn; 
	   FOR i := 0 TO n-1 DO 
	      WriteReal(x^[i], 12, 6)
	   END; 
	   WriteLn;
   ELSE
      Error('XMprove', 'Not enough memory');
   END;
   IF A # NilMatrix THEN DisposeMatrix(A) END;
   IF AA # NilMatrix THEN DisposeMatrix(AA) END;
   IF B # NilVector THEN DisposeVector(B) END;
   IF X # NilVector THEN DisposeVector(X) END;
   IF Ran3MaV # NilVector THEN DisposeVector(Ran3MaV) END;
   IF INDX # NilIVector THEN DisposeIVector(INDX) END;
   ReadLn;
END XMprove.
