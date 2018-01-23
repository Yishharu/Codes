MODULE XBalanc; (* driver for routine Balanc *) 

   FROM BalancM IMPORT Balanc;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,
                       NilMatrix, PtrToLines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr,
                       NilVector;

   CONST 
      np = 5; 
   VAR 
      i, j: INTEGER; 
      A: Matrix; 
      C, R: Vector; 
      a: PtrToLines;
      c, r: PtrToReals;
       
BEGIN 
   CreateMatrix(np, np, A, a);
   CreateVector(np, C, c);
   CreateVector(np, R, r);
   IF (A # NilMatrix) AND (C # NilVector) AND (R # NilVector) THEN
	   a^[0]^[0] := 1.0;   a^[0]^[1] := 100.0;  a^[0]^[2] := 1.0; 
	   a^[0]^[3] := 100.0; a^[0]^[4] := 1.0;    a^[1]^[0] := 1.0; 
	   a^[1]^[1] := 1.0;   a^[1]^[2] := 1.0;    a^[1]^[3] := 1.0; 
	   a^[1]^[4] := 1.0;   a^[2]^[0] := 1.0;    a^[2]^[1] := 100.0; 
	   a^[2]^[2] := 1.0;   a^[2]^[3] := 100.0;  a^[2]^[4] := 1.0; 
	   a^[3]^[0] := 1.0;   a^[3]^[1] := 1.0;    a^[3]^[2] := 1.0; 
	   a^[3]^[3] := 1.0;   a^[3]^[4] := 1.0;    a^[4]^[0] := 1.0; 
	   a^[4]^[1] := 100.0; a^[4]^[2] := 1.0;    a^[4]^[3] := 100.0; 
	   a^[4]^[4] := 1.0; (* write norms *) 
	   FOR i := 0 TO np-1 DO 
	      r^[i] := 0.0; 
	      c^[i] := 0.0; 
	      FOR j := 0 TO np-1 DO 
	         r^[i] := r^[i]+ABS(a^[i]^[j]); 
	         c^[i] := c^[i]+ABS(a^[j]^[i])
	      END
	   END; 
	   WriteString('rows:'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      WriteReal(r^[i], 12, 2)
	   END; 
	   WriteLn; 
	   WriteString('columns:'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      WriteReal(c^[i], 12, 2)
	   END; 
	   WriteLn; WriteLn; 
	   WriteString('***** balancing matrix *****'); 
	   WriteLn; WriteLn; 
	   Balanc(A); (* write norms *) 
	   FOR i := 0 TO np-1 DO 
	      r^[i] := 0.0; 
	      c^[i] := 0.0; 
	      FOR j := 0 TO np-1 DO 
	         r^[i] := r^[i]+ABS(a^[i]^[j]); 
	         c^[i] := c^[i]+ABS(a^[j]^[i])
	      END
	   END; 
	   WriteString('rows:'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      WriteReal(r^[i], 12, 2)
	   END; 
	   WriteLn; 
	   WriteString('columns:'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      WriteReal(c^[i], 12, 2)
	   END; 
	   WriteLn;
	   ReadLn;
	ELSE
	   Error('XBalanc', 'Not enough memory.');
	END;
	IF (A # NilMatrix) THEN DisposeMatrix(A) END;
	IF (C # NilVector) THEN DisposeVector(C) END;
	IF (R # NilVector) THEN DisposeVector(R) END;
END XBalanc.
