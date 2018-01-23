MODULE XPowell; (* driver for routine Powell *) 

   FROM Bessel IMPORT BessJ0;
   FROM DirSet IMPORT Powell;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                      Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   CONST 
      ndim = 3; 
      ftol = 1.0E-6; 
   VAR 
      fret: REAL; 
      i, iter, j: INTEGER; 
      XI: Matrix;
      P: Vector;
      p: PtrToReals; 
      xi: PtrToLines; 
       
   PROCEDURE fnc(X: Vector): REAL; 
      VAR 
         n: INTEGER;
         x: PtrToReals;
   BEGIN 
      GetVectorAttr(X, n, x);
      RETURN 0.5-BessJ0(((x^[0]-1.0)*(x^[0]-1.0))+
                        ((x^[1]-2.0)*(x^[1]-2.0))+((x^[2]-3.0)*(x^[2]-3.0))); 
   END fnc; 
    
BEGIN 
   CreateMatrix(ndim, ndim, XI, xi);
   CreateVector(ndim, P, p);
   IF (XI # NilMatrix) AND (P # NilVector) THEN
	   xi^[0]^[0] := 1.0; 
	   xi^[0]^[1] := 0.0; 
	   xi^[0]^[2] := 0.0; 
	   xi^[1]^[0] := 0.0; 
	   xi^[1]^[1] := 1.0; 
	   xi^[1]^[2] := 0.0; 
	   xi^[2]^[0] := 0.0; 
	   xi^[2]^[1] := 0.0; 
	   xi^[2]^[2] := 1.0; 
	   p^[0] := 1.5; 
	   p^[1] := 1.5; 
	   p^[2] := 2.5; 
	   Powell(P, XI, ftol, iter, fret, fnc); 
	   WriteString('Iterations:'); 
	   WriteInt(iter, 3); WriteLn; WriteLn; 
	   WriteString('Minimum found at: '); WriteLn; 
	   FOR i := 0 TO ndim-1 DO WriteReal(p^[i], 12, 6) END; 
	   WriteLn; 
	   WriteLn; 
	   WriteString('Minimum function value ='); 
	   WriteReal(fret, 12, 6); WriteLn; WriteLn; 
	   WriteString('TRUE minimum of function is at:'); WriteLn; 
	   WriteReal(1.0, 12, 6); 
	   WriteReal(2.0, 12, 6); 
	   WriteReal(3.0, 12, 6); 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XPowell', 'Not enough memory.');
	END;
	IF XI # NilMatrix THEN DisposeMatrix(XI) END;
	IF P # NilVector THEN DisposeVector(P) END;
END XPowell.
