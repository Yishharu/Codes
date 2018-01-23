MODULE XMNewt; (* driver for routine MNewt *)
 
   FROM MNewtM   IMPORT MNewt;
   FROM NRSystem IMPORT Float, LongReal, S, D;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRMatr   IMPORT Matrix, DisposeMatrix, CreateMatrix, GetMatrixAttr,
                        NilMatrix, PtrToLines;
   FROM NRVect   IMPORT Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr,
                        NilVector, VectorPtr;

   CONST
      ntrial = 5;
      tolx = 1.0E-3;
      n = 4;
      tolf = 1.0E-3;
   VAR 
      i, j, k, kk, l: INTEGER; 
      xx: REAL; 
      X, BETA: Vector; 
      x, beta: PtrToReals; 
      ALPHA: Matrix; 
      alpha: PtrToLines;

   PROCEDURE usrfun(X: Vector;  ALPHA: Matrix; BETA: Vector);
      VAR
         n, nBeta, nAlpha, mAlpha: INTEGER;
         x, beta: PtrToReals;
         alpha: PtrToLines;
         a, one, three: LongReal;
   BEGIN
      one := 1.0;
      three := 3.0;
      GetVectorAttr(X, n, x);
      GetVectorAttr(BETA, nBeta, beta);
      GetMatrixAttr(ALPHA, nAlpha, mAlpha, alpha);
      alpha^[0]^[0] := 2.0*x^[0];
      alpha^[0]^[1] := 2.0*x^[1];
      alpha^[0]^[2] := 2.0*x^[2];
      alpha^[0]^[3] := -3.0;
      alpha^[1]^[0] := 2.0*x^[0];
      alpha^[1]^[1] := 2.0*x^[1];
      alpha^[1]^[2] := 2.0*x^[2];
      alpha^[1]^[3] := -2.0*x^[3];
      alpha^[2]^[0] := 1.0;
      alpha^[2]^[1] := -1.0;
      alpha^[2]^[2] := 0.0;
      alpha^[2]^[3] := 0.0;
      alpha^[3]^[0] := 0.0;
      alpha^[3]^[1] := 1.0;
      alpha^[3]^[2] := -1.0;
      alpha^[3]^[3] := 0.0;
      a := D(-x^[0])*D(x^[0])-D(x^[1])*D(x^[1])-D(x^[2])*D(x^[2])+three*D(x^[3]);
      beta^[0] := S(a);
      a := D(-x^[0])*D(x^[0])-D(x^[1])*D(x^[1])-D(x^[2])*D(x^[2])+D(x^[3])*D(x^[3])+one;
      beta^[1] := S(a);
      beta^[2] := -x^[0]+x^[1];
      beta^[3] := -x^[1]+x^[2]
   END usrfun;

BEGIN
   CreateVector(n, X, x);
   CreateMatrix(n, n, ALPHA, alpha);
   CreateVector(n, BETA, beta);
	IF (X # NilVector) AND (ALPHA # NilMatrix) AND (BETA # NilVector) THEN
	   FOR l := 0 TO 1 DO
	      kk := 2*l-1;
	      FOR k := 1 TO 3 DO
	         xx := 0.2*Float(k)*Float(kk);
	         WriteString('Starting vector number');
	         WriteInt(k, 2);
	         WriteLn;
	         FOR i := 1 TO 4 DO
	            x^[i-1] := xx+0.2*Float(i)
	         END;
	         FOR i := 1 TO 4 DO
	            WriteString('     x[');
	            WriteInt(i, 1);
	            WriteString(']  :=  ');
	            WriteReal(x^[i-1], 6, 2);
	            WriteLn
	         END;
	         WriteLn;
	         FOR j := 1 TO ntrial DO
	            MNewt(usrfun, 1, X, tolx, tolf);
	            usrfun(X, ALPHA, BETA);
	            WriteString('    i');
	            WriteString('       x[i-1]');
	            WriteString('            f');
	            WriteLn;
	            FOR i := 1 TO n DO
	               WriteInt(i, 5);
	               WriteString('   ');
	               WriteReal(x^[i-1], 13, 0);
	               WriteString('   ');
	               WriteReal(-beta^[i-1], 13, 0);
	               WriteLn
	            END;
	            WriteLn;
	            WriteString('press RETURN to continue...');
	            WriteLn;
	            ReadLn;
	         END;
	      END;
	   END;
	ELSE
	   Error('XMNewt', 'Not enough memory.');
	END;
	IF (X # NilVector) THEN DisposeVector(X) END;
	IF (ALPHA # NilMatrix) THEN DisposeMatrix(ALPHA) END;
	IF (BETA # NilVector) THEN DisposeVector(BETA) END;
END XMNewt.
