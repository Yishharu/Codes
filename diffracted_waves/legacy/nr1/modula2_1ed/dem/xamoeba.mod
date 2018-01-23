MODULE XAmoeba; (* driver for routine Amoeba *)
 
   FROM Bessel  IMPORT BessJ0;
   FROM AmoebaM IMPORT Amoeba;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                       NilMatrix, PtrToLines;
   FROM NRIVect IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, GetIVectorAttr,
                       NilIVector;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr,
                       NilVector;

   CONST
      np = 3;
      mp = 4;
      ftol = 1.0E-6;
   VAR
      i, nfunc, j, ndim: INTEGER;
      X, Y: Vector;
      x, y: PtrToReals;
      P: Matrix;
      p: PtrToLines;

   PROCEDURE func(X: Vector): REAL;
      VAR
         x: PtrToReals;
         n: INTEGER;
   BEGIN
      GetVectorAttr(X, n, x);
      RETURN 0.6-BessJ0(((x^[0]-0.5)*(x^[0]-0.5))
                       +((x^[1]-0.6)*(x^[1]-0.6))
                       +((x^[2]-0.7)*(x^[2]-0.7)));
   END func;

BEGIN
   CreateVector(np, X, x);
   CreateVector(mp, Y, y);
   CreateMatrix(mp, np, P, p);
   IF (X # NilVector) AND (Y # NilVector) AND (P # NilMatrix) THEN
	   p^[0]^[0] := 0.0;  p^[0]^[1] := 0.0;  p^[0]^[2] := 0.0;
	   p^[1]^[0] := 1.0;  p^[1]^[1] := 0.0;  p^[1]^[2] := 0.0;
	   p^[2]^[0] := 0.0;  p^[2]^[1] := 1.0;  p^[2]^[2] := 0.0;
	   p^[3]^[0] := 0.0;  p^[3]^[1] := 0.0;  p^[3]^[2] := 1.0;
	   ndim := np;
	   FOR i := 0 TO mp-1 DO
	      FOR j := 0 TO np-1 DO
	         x^[j] := p^[i]^[j]
	      END;
	      y^[i] := func(X)
	   END;
	   Amoeba(P, Y, ndim, ftol, func, nfunc);
	   WriteLn;
	   WriteString('Function evaluations: ');
	   WriteInt(nfunc, 3);
	   WriteLn;
	   WriteString('Vertices of final 3-d simplex and');
	   WriteLn;
	   WriteString('function values at the vertices:');
	   WriteLn;
	   WriteLn;
	   WriteString('  i');
	   WriteString('      x[i]');
	   WriteString('        y^[i]');
	   WriteString('        z[i]');
	   WriteString('      function');
	   WriteLn;
	   WriteLn;
	   FOR i := 0 TO mp-1 DO
	      WriteInt(i, 3);
	      FOR j := 0 TO np-1 DO
	         WriteReal(p^[i]^[j], 12, 6)
	      END;
	      WriteReal(y^[i], 12, 6);
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('TRUE minimum is at (0.5,0.6,0.7)'); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XAmoeba', 'Not enough memory.');
	END;
	IF (X # NilVector) THEN DisposeVector(X) END;
	IF (Y # NilVector) THEN DisposeVector(Y) END;
	IF (P # NilMatrix) THEN DisposeMatrix(P) END;
END XAmoeba.
