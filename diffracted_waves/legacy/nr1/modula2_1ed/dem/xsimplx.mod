MODULE XSimplx; (* driver for routine Simplx *) 
                (* incorporates examples discussed in text *) 

   FROM Simplex IMPORT Simplx;
   FROM NRIO    IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, 
                       Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                       NilMatrix, PtrToLines;
   FROM NRIVect IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, GetIVectorAttr,
                       NilIVector;

   CONST 
      n = 4; 
      m = 4; 
      np = 5; (* np >= n+1 *) 
      mp = 6; (* mp >= m+2 *) 
      m1 = 2; (* m1+m2+m3=m *) 
      m2 = 1; 
      m3 = 1; 
      nm1m2 = 7; (* nm1m2=n+m1+m2 *) 
   TYPE 
      CharArray2 = ARRAY [1..2] OF CHAR; 
   VAR 
      i, icase, j: INTEGER; 
      rite: BOOLEAN; 
      IZROV, IPOSV: IVector;
      izrov, iposv: PtrToIntegers;
      A: Matrix;
      a: PtrToLines; 
      text: ARRAY [1..nm1m2] OF CharArray2; 
       
BEGIN 
   CreateIVector(n, IZROV, izrov);
   CreateIVector(m, IPOSV, iposv);
   CreateMatrix(mp, np, A, a);
   IF (IZROV # NilIVector) AND (IPOSV # NilIVector) AND (A # NilMatrix) THEN 
	   text[1] := 'x1'; text[2] := 'x2'; text[3] := 'x3'; text[4] := 'x4'; 
	   text[5] := 'y1'; text[6] := 'y2'; text[7] := 'y3'; 
	   a^[0]^[0] := 0.0;   a^[0]^[1] := 1.0;  a^[0]^[2] := 1.0; 
	   a^[0]^[3] := 3.0;   a^[0]^[4] := -0.5; 
	   a^[1]^[0] := 740.0; a^[1]^[1] := -1.0; a^[1]^[2] := 0.0; 
	   a^[1]^[3] := -2.0;  a^[1]^[4] := 0.0; 
	   a^[2]^[0] := 0.0;   a^[2]^[1] := 0.0;  a^[2]^[2] := -2.0; 
	   a^[2]^[3] := 0.0;   a^[2]^[4] := 7.0; 
	   a^[3]^[0] := 0.5;   a^[3]^[1] := 0.0;  a^[3]^[2] := -1.0; 
	   a^[3]^[3] := 1.0;   a^[3]^[4] := -2.0; 
	   a^[4]^[0] := 9.0;   a^[4]^[1] := -1.0; a^[4]^[2] := -1.0; 
	   a^[4]^[3] := -1.0;  a^[4]^[4] := -1.0; 
	   Simplx(A, m, n, m1, m2, m3, icase, IZROV, IPOSV); 
	   WriteLn; 
	   IF icase = 1 THEN 
	      WriteString('unbounded objective function'); WriteLn
	   ELSIF icase = -1 THEN 
	      WriteString('no solutions satisfy constraints given'); WriteLn
	   ELSE 
	      WriteString('           '); 
	      FOR i := 0 TO n-1 DO 
	         IF izrov^[i] <= nm1m2 THEN 
	            WriteString('        ');
	            WriteString(text[izrov^[i]])
	         END
	      END; 
	      WriteLn; 
	      FOR i := 0 TO m DO 
	         IF i = 0 THEN 
	            WriteString('  '); 
	            rite := TRUE
	         ELSIF iposv^[i-1] <= nm1m2 THEN 
	            WriteString(text[iposv^[i-1]]); 
	            rite := TRUE
	         ELSE 
	            rite := FALSE
	         END; 
	         IF rite THEN 
	            WriteReal(a^[i]^[0], 10, 2); 
	            FOR j := 1 TO n DO 
	               IF izrov^[j-1] <= nm1m2 THEN 
	                  WriteReal(a^[i]^[j], 10, 2)
	               END
	            END; 
	            WriteLn
	         END
	      END
	   END;
	   ReadLn;
	ELSE
	   Error('XSimplx', 'Not enough memory.');
	END;
	IF IZROV # NilIVector THEN DisposeIVector(IZROV) END;
	IF IPOSV # NilIVector THEN DisposeIVector(IPOSV) END;
	IF A # NilMatrix THEN DisposeMatrix(A) END;
END XSimplx.
