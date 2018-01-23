MODULE XSOR; (* driver for routine SOR *)

   FROM SORM     IMPORT SOR;
   FROM NRMath   IMPORT Cos, CosSD;
   FROM NRSystem IMPORT LongReal, D, DI, SI, Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteReal, WriteLongReal, WriteString, Error;
   FROM NRLMatr  IMPORT LMatrix, DisposeLMatrix, CreateLMatrix, GetLMatrixAttr,
                        NilLMatrix, PtrToLLines;

   CONST
      jmax = 11;
      pi = 3.1415926;
   VAR
      i, j, midl: INTEGER;
      rjac, work1, work2: LongReal;
      A, B, C, DD, E, F, U: LMatrix;
      a, b, c, d, e, f, u: PtrToLLines;

BEGIN
   CreateLMatrix(jmax, jmax, A, a);
   CreateLMatrix(jmax, jmax, B, b);
   CreateLMatrix(jmax, jmax, C, c);
   CreateLMatrix(jmax, jmax, DD, d);
   CreateLMatrix(jmax, jmax, E, e);
   CreateLMatrix(jmax, jmax, F, f);
   CreateLMatrix(jmax, jmax, U, u);
   IF ( (A # NilLMatrix) AND (B # NilLMatrix) AND (C # NilLMatrix) AND
        (DD # NilLMatrix) AND (E # NilLMatrix)  AND (F # NilLMatrix) AND
        (U # NilLMatrix) ) THEN
	   FOR i := 0 TO jmax-1 DO
	      FOR j := 0 TO jmax-1 DO
	         a^[i]^[j] := 1.0;
	         b^[i]^[j] := 1.0;
	         c^[i]^[j] := 1.0;
	         d^[i]^[j] := 1.0;
	         e^[i]^[j] := -4.0;
	         f^[i]^[j] := 0.0;
	         u^[i]^[j] := 0.0
	      END
	   END;
	   midl := jmax DIV 2;
	   f^[midl]^[midl] := 2.0;
	   rjac := CosSD(pi/Float(jmax));
	   SOR(A, B, C, DD, E, F, U, rjac);
	   WriteString('SOR Solution:');
	   WriteLn;
	   FOR i := 0 TO jmax-1 DO 
	      FOR j := 0 TO jmax-1 DO 
	         WriteLongReal(u^[i]^[j], 7, 2)
	      END;
	      WriteLn
	   END;
	   WriteLn;
	   WriteString('Test that solution satisfies difference eqns:');
	   WriteLn;
	   FOR i := 1 TO jmax-2 DO
	      FOR j := 1 TO jmax-2 DO
	         work1 := D(4.0)*u^[i]^[j];
	         work2 := u^[i+1]^[j]+u^[i-1]^[j];
	         f^[i]^[j] := work2+u^[i]^[j+1]+u^[i]^[j-1]-work1;
	      END;
	      WriteString('       ');
	      FOR j := 1 TO jmax-2 DO
	         WriteLongReal(f^[i]^[j], 7, 2)
	      END;
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XSOR', 'Not enough memory');
	END;
	IF (A # NilLMatrix) THEN DisposeLMatrix(A); END;
	IF (B # NilLMatrix) THEN DisposeLMatrix(B); END;
	IF (C # NilLMatrix) THEN DisposeLMatrix(C); END;
	IF (DD # NilLMatrix) THEN DisposeLMatrix(DD); END;
	IF (E # NilLMatrix) THEN DisposeLMatrix(E); END;
	IF (F # NilLMatrix) THEN DisposeLMatrix(F); END;
	IF (U # NilLMatrix) THEN DisposeLMatrix(U); END;
END XSOR.
