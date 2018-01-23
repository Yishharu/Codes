MODULE XSVDVar; (* driver for routine SVDVar *) 
 
   FROM LLSs   IMPORT SVDVar;
   FROM NRIO   IMPORT ReadLn, WriteLn,   WriteInt,  WriteReal, WriteString, 
                      Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

   CONST 
      np = 6; 
      ma = 3; 
   VAR 
      i, j: INTEGER; 
      V, CWM, TRU: Matrix; 
      v, cvm, tru: PtrToLines;
      W: Vector;
      w: PtrToReals; 
       
BEGIN 
   CreateMatrix(np, np, V, v);
   CreateVector(np, W, w);
   CreateMatrix(ma, ma, CWM, cvm);
   CreateMatrix(ma, ma, TRU, tru);
   IF (V # NilMatrix) AND (W # NilVector) AND (CWM # NilMatrix) AND
      (TRU # NilMatrix) THEN
	   w^[0] := 0.0;     w^[1] := 1.0;     w^[2] := 2.0; 
	   w^[3] := 3.0;     w^[4] := 4.0;     w^[5] := 5.0; 
	   v^[0]^[0] := 1.0;  v^[0]^[1] := 1.0;  v^[0]^[2] := 1.0; 
	   v^[0]^[3] := 1.0;  v^[0]^[4] := 1.0;  v^[0]^[5] := 1.0; 
	   v^[1]^[0] := 2.0;  v^[1]^[1] := 2.0;  v^[1]^[2] := 2.0; 
	   v^[1]^[3] := 2.0;  v^[1]^[4] := 2.0;  v^[1]^[5] := 2.0; 
	   v^[2]^[0] := 3.0;  v^[2]^[1] := 3.0;  v^[2]^[2] := 3.0; 
	   v^[2]^[3] := 3.0;  v^[2]^[4] := 3.0;  v^[2]^[5] := 3.0; 
	   v^[3]^[0] := 4.0;  v^[3]^[1] := 4.0;  v^[3]^[2] := 4.0; 
	   v^[3]^[3] := 4.0;  v^[3]^[4] := 4.0;  v^[3]^[5] := 4.0; 
	   v^[4]^[0] := 5.0;  v^[4]^[1] := 5.0;  v^[4]^[2] := 5.0; 
	   v^[4]^[3] := 5.0;  v^[4]^[4] := 5.0;  v^[4]^[5] := 5.0; 
	   v^[5]^[0] := 6.0;  v^[5]^[1] := 6.0;  v^[5]^[2] := 6.0; 
	   v^[5]^[3] := 6.0;  v^[5]^[4] := 6.0;  v^[5]^[5] := 6.0; 
	   tru^[0]^[0] := 1.25;  tru^[0]^[1] := 2.5;  tru^[0]^[2] := 3.75; 
	   tru^[1]^[0] := 2.5;   tru^[1]^[1] := 5.0;  tru^[1]^[2] := 7.5; 
	   tru^[2]^[0] := 3.75;  tru^[2]^[1] := 7.5;  tru^[2]^[2] := 11.25; 
	   WriteLn; 
	   WriteString('matrix v');  WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      FOR j := 0 TO np-1 DO 
	         WriteReal(v^[i]^[j], 12, 6)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('vector w'); WriteLn; 
	   FOR i := 0 TO np-1 DO 
	      WriteReal(w^[i], 12, 6)
	   END; 
	   WriteLn; 
	   SVDVar(V, W, CWM); 
	   WriteLn; 
	   WriteString('covariance matrix from svdvar'); 
	   WriteLn; 
	   FOR i := 0 TO ma-1 DO 
	      FOR j := 0 TO ma-1 DO 
	         WriteReal(cvm^[i]^[j], 12, 6)
	      END; 
	      WriteLn
	   END; 
	   WriteLn; 
	   WriteString('expected covariance matrix'); 
	   WriteLn; 
	   FOR i := 0 TO ma-1 DO 
	      FOR j := 0 TO ma-1 DO 
	         WriteReal(tru^[i]^[j], 12, 6)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
      Error('XCovSrt', 'Not enough memory.');
	END;
	IF V # NilMatrix THEN DisposeMatrix(V) END;
	IF W # NilVector THEN DisposeVector(W) END;
	IF CWM # NilMatrix THEN DisposeMatrix(CWM) END;
	IF TRU # NilMatrix THEN DisposeMatrix(TRU) END;
END XSVDVar.
