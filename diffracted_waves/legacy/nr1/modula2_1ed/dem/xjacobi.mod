MODULE XJacobi; (* driver for routine Jacobi *)
 
   FROM Jacobis IMPORT Jacobi;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                       NilMatrix, PtrToLines;
   FROM NRVect  IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                       NilVector;

   CONST 
      n = 10;
      nmat = 3; 
   TYPE 
      IntegerArray3 = ARRAY [1..3] OF INTEGER; 
   VAR 
      i, j, k, kk, l, ll, nrot: INTEGER; 
      A, B, C, V: Matrix; 
      a, b, c, v: PtrToLines; 
      DD, R: Vector; 
      d, r: PtrToReals; 
      num: IntegerArray3; 
       
BEGIN 
   num[1] := 3;  num[2] := 5;  num[3] := 10; 
   CreateMatrix(3, 3, A, a);
   CreateMatrix(5, 5, B, b);
   CreateMatrix(10, 10, C, c);
   CreateMatrix(10, 10, V, v);
   CreateVector(10, DD, d);
   CreateVector(10, R, r);
   IF (A # NilMatrix) AND (B # NilMatrix) AND (C # NilMatrix) AND
      (DD # NilVector) AND (R # NilVector) THEN
	   a^[0]^[0] := 1.0;   a^[0]^[1] := 2.0;  a^[0]^[2] := 3.0; 
	   a^[1]^[0] := 2.0;   a^[1]^[1] := 2.0;  a^[1]^[2] := 3.0; 
	   a^[2]^[0] := 3.0;   a^[2]^[1] := 3.0;  a^[2]^[2] := 3.0; 
	   b^[0]^[0] := -2.0;  b^[0]^[1] := -1.0;  b^[0]^[2] := 0.0; 
	   b^[0]^[3] := 1.0;   b^[0]^[4] := 2.0;  
	   b^[1]^[0] := -1.0;  b^[1]^[1] := -1.0;  b^[1]^[2] := 0.0;  
	   b^[1]^[3] := 1.0;   b^[1]^[4] := 2.0;   
	   b^[2]^[0] := 0.0;   b^[2]^[1] := 0.0;   b^[2]^[2] := 0.0;  
	   b^[2]^[3] := 1.0;   b^[2]^[4] := 2.0; 
	   b^[3]^[0] := 1.0;   b^[3]^[1] := 1.0;   b^[3]^[2] := 1.0; 
	   b^[3]^[3] := 1.0;   b^[3]^[4] := 2.0; 
	   b^[4]^[0] := 2.0;   b^[4]^[1] := 2.0;   b^[4]^[2] := 2.0; 
	   b^[4]^[3] := 2.0;   b^[4]^[4] := 2.0; 
	   c^[0]^[0] := 5.0;   c^[0]^[1] := 4.0;   c^[0]^[2] := 3.0; 
	   c^[0]^[3] := 2.0;   c^[0]^[4] := 1.0;   c^[0]^[5] := 0.0; 
	   c^[0]^[6] := -1.0;  c^[0]^[7] := -2.0;  c^[0]^[8] := -3.0; 
	   c^[0]^[9] := -4.0; 
	   c^[1]^[0] := 4.0;   c^[1]^[1] := 5.0;   c^[1]^[2] := 4.0; 
	   c^[1]^[3] := 3.0;   c^[1]^[4] := 2.0;   c^[1]^[5] := 1.0; 
	   c^[1]^[6] := 0.0;   c^[1]^[7] := -1.0;  c^[1]^[8] := -2.0; 
	   c^[1]^[9] := -3.0;  c^[2]^[0] := 3.0;   c^[2]^[1] := 4.0; 
	   c^[2]^[2] := 5.0;   c^[2]^[3] := 4.0;   c^[2]^[4] := 3.0; 
	   c^[2]^[5] := 2.0;   c^[2]^[6] := 1.0;   c^[2]^[7] := 0.0; 
	   c^[2]^[8] := -1.0;  c^[2]^[9] := -2.0;  c^[3]^[0] := 2.0; 
	   c^[3]^[1] := 3.0;   c^[3]^[2] := 4.0;   c^[3]^[3] := 5.0; 
	   c^[3]^[4] := 4.0;   c^[3]^[5] := 3.0;   c^[3]^[6] := 2.0; 
	   c^[3]^[7] := 1.0;   c^[3]^[8] := 0.0;   c^[3]^[9] := -1.0; 
	   c^[4]^[0] := 1.0;   c^[4]^[1] := 2.0;   c^[4]^[2] := 3.0; 
	   c^[4]^[3] := 4.0;   c^[4]^[4] := 5.0;   c^[4]^[5] := 4.0; 
	   c^[4]^[6] := 3.0;   c^[4]^[7] := 2.0;   c^[4]^[8] := 1.0; 
	   c^[4]^[9] := 0.0;   c^[5]^[0] := 0.0;   c^[5]^[1] := 1.0; 
	   c^[5]^[2] := 2.0;   c^[5]^[3] := 3.0;   c^[5]^[4] := 4.0; 
	   c^[5]^[5] := 5.0;   c^[5]^[6] := 4.0;   c^[5]^[7] := 3.0; 
	   c^[5]^[8] := 2.0;   c^[5]^[9] := 1.0;   c^[6]^[0] := -1.0; 
	   c^[6]^[1] := 0.0;   c^[6]^[2] := 1.0;   c^[6]^[3] := 2.0; 
	   c^[6]^[4] := 3.0;   c^[6]^[5] := 4.0;   c^[6]^[6] := 5.0; 
	   c^[6]^[7] := 4.0;   c^[6]^[8] := 3.0;   c^[6]^[9] := 2.0; 
	   c^[7]^[0] := -2.0;  c^[7]^[1] := -1.0;  c^[7]^[2] := 0.0; 
	   c^[7]^[3] := 1.0;   c^[7]^[4] := 2.0;   c^[7]^[5] := 3.0; 
	   c^[7]^[6] := 4.0;   c^[7]^[7] := 5.0;   c^[7]^[8] := 4.0; 
	   c^[7]^[9] := 3.0;   c^[8]^[0] := -3.0;  c^[8]^[1] := -2.0; 
	   c^[8]^[2] := -1.0;  c^[8]^[3] := 0.0;   c^[8]^[4] := 1.0; 
	   c^[8]^[5] := 2.0;   c^[8]^[6] := 3.0;   c^[8]^[7] := 4.0; 
	   c^[8]^[8] := 5.0;   c^[8]^[9] := 4.0;   c^[9]^[0] := -4.0; 
	   c^[9]^[1] := -3.0;  c^[9]^[2] := -2.0;  c^[9]^[3] := -1.0; 
	   c^[9]^[4] := 0.0;   c^[9]^[5] := 1.0;   c^[9]^[6] := 2.0; 
	   c^[9]^[7] := 3.0;   c^[9]^[8] := 4.0;   c^[9]^[9] := 5.0; 
	   FOR i := 1 TO nmat DO 
	      IF i = 1 THEN 
	         Jacobi(A, DD, V, nrot)
	      ELSIF i = 2 THEN 
	         Jacobi(B, DD, V, nrot)
	      ELSIF i = 3 THEN 
	         Jacobi(C, DD, V, nrot)
	      END; 
	      WriteString('matrix number'); 
	      WriteInt(i, 2); 
	      WriteLn; 
	      WriteString('number of Jacobi rotations:'); 
	      WriteInt(nrot, 3); 
	      WriteLn; 
	      WriteString('eigenvalues:'); 
	      WriteLn; 
	      FOR j := 0 TO num[i]-1 DO 
	         WriteReal(d^[j], 12, 6); 
	         IF (j+1) MOD 5 = 0 THEN 
	            WriteLn
	         END
	      END; 
	      ReadLn;
	      WriteLn; 
	      WriteString('eigenvectors:'); 
	      WriteLn; 
	      FOR j := 0 TO num[i]-1 DO 
	         WriteString('   number'); 
	         WriteInt(j+1, 3); 
	         WriteLn; 
	         FOR k := 0 TO num[i]-1 DO 
	            WriteReal(v^[k]^[j], 12, 6); 
	            IF (k+1) MOD 5 = 0 THEN 
	               WriteLn
	            END
	         END; 
	         WriteLn
	      END; 
	      ReadLn; (* eigenvector test *) 
	      WriteString('eigenvector test'); 
	      WriteLn; 
	      FOR j := 0 TO num[i]-1 DO 
	         FOR l := 0 TO num[i]-1 DO 
	            r^[l] := 0.0; 
	            FOR k := 0 TO num[i]-1 DO 
	               IF k > l THEN 
	                  kk := l; 
	                  ll := k
	               ELSE 
	                  kk := k; 
	                  ll := l
	               END; 
	               IF i = 1 THEN 
	                  r^[l] := r^[l]+a^[ll]^[kk]*v^[k]^[j]
	               ELSIF i = 2 THEN 
	                  r^[l] := r^[l]+b^[ll]^[kk]*v^[k]^[j]
	               ELSIF i = 3 THEN 
	                  r^[l] := r^[l]+c^[ll]^[kk]*v^[k]^[j]
	               END
	            END
	         END; 
	         WriteString('vector number'); 
	         WriteInt(j+1, 3); 
	         WriteLn; 
	         WriteString('     vector'); 
	         WriteString('     mtrx*vec.'); 
	         WriteString('     ratio'); 
	         WriteLn; 
	         FOR l := 0 TO num[i]-1 DO 
	            WriteReal(v^[l]^[j], 12, 6); 
	            WriteReal(r^[l], 12, 6); 
	            WriteReal(r^[l]/v^[l]^[j], 12, 6); 
	            WriteLn
	         END;
	         IF (j+1) MOD 3 = 0 THEN ReadLn; END;
	      END; 
	      WriteString('press return to continue...'); 
	      WriteLn; 
	      ReadLn
	   END;
	ELSE
	   Error('Jacobi', 'Not enough memory.');
	END;
	IF (A # NilMatrix) THEN DisposeMatrix(A) END;
	IF (B # NilMatrix) THEN DisposeMatrix(B) END;
	IF (C # NilMatrix) THEN DisposeMatrix(C) END;
	IF (V # NilMatrix) THEN DisposeMatrix(V) END;
	IF (DD # NilVector) THEN DisposeVector(DD) END;
	IF (R # NilVector) THEN DisposeVector(R) END;
END XJacobi.
