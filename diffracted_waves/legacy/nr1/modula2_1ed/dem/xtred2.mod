MODULE XTRED2; (* driver for routine TRED2 *) 

   FROM TRED2M IMPORT TRED2;
   FROM NRIO   IMPORT ReadLn, WriteLn, WriteReal, WriteString, Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                      NilVector;

	CONST
	   np = 10;
	VAR
	   i,j,k,l,m: INTEGER;
	   A, C, F: Matrix;
	   a,c,f: PtrToLines;
	   DD, E: Vector;
	   d,e: PtrToReals;

BEGIN
   CreateMatrix(np, np, A, a);
   CreateMatrix(np, np, C, c);
   CreateMatrix(np, np, F, f);
   CreateVector(np, DD, d);
   CreateVector(np, E, e);
   IF (A # NilMatrix) AND (C # NilMatrix) AND (F # NilMatrix) 
       AND (DD # NilVector) AND (E # NilVector) THEN
	   c^[0]^[0] := 5.0;   c^[0]^[1] := 4.0;  c^[0]^[2] := 3.0; 
	   c^[0]^[3] := 2.0;   c^[0]^[4] := 1.0;  c^[0]^[5] := 0.0; 
	   c^[0]^[6] := -1.0;  c^[0]^[7] := -2.0; c^[0]^[8] := -3.0; 
	   c^[0]^[9] := -4.0;
	   c^[1]^[0] := 4.0;   c^[1]^[1] := 5.0;  c^[1]^[2] := 4.0; 
	   c^[1]^[3] := 3.0;   c^[1]^[4] := 2.0;  c^[1]^[5] := 1.0; 
	   c^[1]^[6] := 0.0;   c^[1]^[7] := -1.0; c^[1]^[8] := -2.0; 
	   c^[1]^[9] := -3.0;  c^[2]^[0] := 3.0;  c^[2]^[1] := 4.0; 
	   c^[2]^[2] := 5.0;   c^[2]^[3] := 4.0;  c^[2]^[4] := 3.0; 
	   c^[2]^[5] := 2.0;   c^[2]^[6] := 1.0;  c^[2]^[7] := 0.0; 
	   c^[2]^[8] := -1.0;  c^[2]^[9] := -2.0; 
	   c^[3]^[0] := 2.0;   c^[3]^[1] := 3.0;  c^[3]^[2] := 4.0; 
	   c^[3]^[3] := 5.0;   c^[3]^[4] := 4.0;  c^[3]^[5] := 3.0; 
	   c^[3]^[6] := 2.0;   c^[3]^[7] := 1.0;  c^[3]^[8] := 0.0; 
	   c^[3]^[9] := -1.0; 
	   c^[4]^[0] := 1.0;   c^[4]^[1] := 2.0;  c^[4]^[2] := 3.0; 
	   c^[4]^[3] := 4.0;   c^[4]^[4] := 5.0;  c^[4]^[5] := 4.0; 
	   c^[4]^[6] := 3.0;   c^[4]^[7] := 2.0;  c^[4]^[8] := 1.0; 
	   c^[4]^[9] := 0.0; 
	   c^[5]^[0] := 0.0;   c^[5]^[1] := 1.0;  c^[5]^[2] := 2.0; 
	   c^[5]^[3] := 3.0;   c^[5]^[4] := 4.0;  c^[5]^[5] := 5.0; 
	   c^[5]^[6] := 4.0;   c^[5]^[7] := 3.0;  c^[5]^[8] := 2.0; 
	   c^[5]^[9] := 1.0; 
	   c^[6]^[0] := -1.0;  c^[6]^[1] := 0.0;  c^[6]^[2] := 1.0; 
	   c^[6]^[3] := 2.0;   c^[6]^[4] := 3.0;  c^[6]^[5] := 4.0; 
	   c^[6]^[6] := 5.0;   c^[6]^[7] := 4.0;  c^[6]^[8] := 3.0; 
	   c^[6]^[9] := 2.0; 
	   c^[7]^[0] := -2.0;  c^[7]^[1] := -1.0; c^[7]^[2] := 0.0; 
	   c^[7]^[3] := 1.0;   c^[7]^[4] := 2.0;  c^[7]^[5] := 3.0; 
	   c^[7]^[6] := 4.0;   c^[7]^[7] := 5.0;  c^[7]^[8] := 4.0; 
	   c^[7]^[9] := 3.0; 
	   c^[8]^[0] := -3.0;  c^[8]^[1] := -2.0; c^[8]^[2] := -1.0; 
	   c^[8]^[3] := 0.0;   c^[8]^[4] := 1.0;  c^[8]^[5] := 2.0; 
	   c^[8]^[6] := 3.0;   c^[8]^[7] := 4.0;  c^[8]^[8] := 5.0; 
	   c^[8]^[9] := 4.0;   
	   c^[9]^[0] := -4.0;  c^[9]^[1] := -3.0;  c^[9]^[2] := -2.0; 
	   c^[9]^[3] := -1.0;  c^[9]^[4] := 0.0;   c^[9]^[5] := 1.0;  
	   c^[9]^[6] := 2.0;   c^[9]^[7] := 3.0;   c^[9]^[8] := 4.0; 
	   c^[9]^[9] := 5.0; 
	   FOR i := 0 TO np-1 DO
	      FOR j := 0 TO np-1 DO 
	         a^[i]^[j] := c^[i]^[j];
	      END;
	   END;
	   TRED2(A, DD, E);
	   WriteString('diagonal elements'); WriteLn;
	   FOR i := 0 TO np-1 DO 
	      WriteReal(d^[i], 12, 6);
	      IF (i+1) MOD 5 = 0 THEN WriteLn END;
	   END;
	   WriteString('off-diagonal elements'); WriteLn;
	   FOR i := 1 TO np-1 DO 
	      WriteReal(e^[i], 12, 6);
	      IF (i+1) MOD 5 = 0 THEN WriteLn END;
	   END;
	(* check transformation matrix *)
	   FOR j := 0 TO np-1 DO 
	      FOR k := 0 TO np-1 DO 
	         f^[j]^[k] := 0.0;
	         FOR l := 0 TO np-1 DO
	            FOR m := 0 TO np-1 DO
	               f^[j]^[k] := f^[j]^[k]+a^[l]^[j]*c^[l]^[m]*a^[m]^[k];
	            END;
	         END;
	      END
	   END;
	(* how does it look? *)
	   WriteString('tridiagonal matrix');  WriteLn;
	   FOR i := 0 TO np-1 DO 
	      FOR j := 0 TO np-1 DO 
	         WriteReal(f^[i]^[j], 7, 2);
	      END;
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XTRED2', 'Not enough memory.');
	END;
   IF A # NilMatrix THEN DisposeMatrix(A) END;
   IF C # NilMatrix THEN DisposeMatrix(C) END;
   IF F # NilMatrix THEN DisposeMatrix(F) END; 
   IF DD # NilVector THEN DisposeVector(DD) END; 
   IF E # NilVector THEN DisposeVector(E) END; 
END XTRED2.
