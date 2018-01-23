MODULE XElmHes; (* driver for routine ElmHes *) 

   FROM BalancM IMPORT Balanc;
   FROM ElmHesM IMPORT ElmHes;
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
	   a^[0]^[0] := 1.0;    a^[0]^[1] := 2.0;    a^[0]^[2] := 300.0; 
	   a^[0]^[3] := 4.0;    a^[0]^[4] := 5.0;    a^[1]^[0] := 2.0; 
	   a^[1]^[1] := 3.0;    a^[1]^[2] := 400.0;  a^[1]^[3] := 5.0; 
	   a^[1]^[4] := 6.0;    a^[2]^[0] := 3.0;    a^[2]^[1] := 4.0; 
	   a^[2]^[2] := 5.0;    a^[2]^[3] := 6.0;    a^[2]^[4] := 7.0; 
	   a^[3]^[0] := 4.0;    a^[3]^[1] := 5.0;    a^[3]^[2] := 600.0; 
	   a^[3]^[3] := 7.0;    a^[3]^[4] := 8.0;    a^[4]^[0] := 5.0; 
	   a^[4]^[1] := 6.0;    a^[4]^[2] := 700.0;  a^[4]^[3] := 8.0; 
	   a^[4]^[4] := 9.0; 
	   WriteString('***** original matrix *****'); 
	   WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      FOR j := 0 TO np-1 DO 
	         WriteReal(a^[i]^[j], 12, 2)
	      END; 
	      WriteLn
	   END; 
	   WriteString('***** balance matrix *****'); WriteLn; 
	   Balanc(A); 
	   FOR i := 0 TO np-1 DO 
	      FOR j := 0 TO np-1 DO 
	         WriteReal(a^[i]^[j], 12, 2)
	      END; 
	      WriteLn
	   END; 
	   WriteString('***** reduce to hessenberg form *****'); 
	   WriteLn; 
	   ElmHes(A); 
	   FOR j := 0 TO np-3 DO 
	      FOR i := j+2 TO np-1 DO 
	         a^[i]^[j] := 0.0
	      END
	   END; 
	   FOR i := 0 TO np-1 DO 
	      FOR j := 0 TO np-1 DO 
	         WriteString('  '); 
	         WriteReal(a^[i]^[j], 12, 0)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XElmHes', 'Not enough memory.');
	END;
	IF (A # NilMatrix) THEN DisposeMatrix(A) END;
	IF (C # NilVector) THEN DisposeVector(C) END;
	IF (R # NilVector) THEN DisposeVector(R) END;
END XElmHes.
