MODULE XADI; (* driver for routine ADI *)

   FROM ADIM     IMPORT ADI;
   FROM NRMath   IMPORT Ln, LnSD, Cos, CosSD;
   FROM NRSystem IMPORT LongReal, D, DI, SI, Float, FloatSD;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteLongReal, WriteString, Error;
   FROM NRLMatr  IMPORT LMatrix, DisposeLMatrix, CreateLMatrix, GetLMatrixAttr,
                        NilLMatrix, PtrToLLines;

   CONST
      jmax = 11;
      pi = 3.1415926;
   VAR 
      alim, alpha, beta, eps, work1, work2, one, two: LongReal; 
      i, j, k, mid, twotok: INTEGER; 
      A, B, C, DD, E, F, G, U: LMatrix; 
      a, b, c, d, e, f, g, u: PtrToLLines; 

BEGIN 
   CreateLMatrix(jmax, jmax, A, a);
   CreateLMatrix(jmax, jmax, B, b);
   CreateLMatrix(jmax, jmax, C, c);
   CreateLMatrix(jmax, jmax, DD, d);
   CreateLMatrix(jmax, jmax, E, e);
   CreateLMatrix(jmax, jmax, F, f);
   CreateLMatrix(jmax, jmax, G, g);
   CreateLMatrix(jmax, jmax, U, u);
   IF ( (A # NilLMatrix) AND (B # NilLMatrix) AND (C # NilLMatrix) AND 
        (DD # NilLMatrix) AND (E # NilLMatrix)  AND (F # NilLMatrix) AND 
        (U # NilLMatrix) ) THEN
    two := 2.0;
    one := 1.0;
	   FOR i := 0 TO jmax-1 DO 
	      FOR j := 0 TO jmax-1 DO 
	         a^[i]^[j] := -1.0;
	         b^[i]^[j] := 2.0; 
	         c^[i]^[j] := -1.0; 
	         d^[i]^[j] := -1.0; 
	         e^[i]^[j] := 2.0; 
	         f^[i]^[j] := -1.0; 
	         g^[i]^[j] := 0.0;
	         u^[i]^[j] := 0.0
	      END
	   END; 
	   mid := (jmax DIV 2)+1; 
	   g^[mid-1]^[mid-1] := 2.0; 
	   alpha := two*(one-CosSD(pi/Float(jmax)));
	   beta := two*(one-CosSD(Float(jmax-1)*pi/Float(jmax)));
	   alim := LnSD(4.0*Float(jmax)/pi);
	   k := 0;
	   twotok := 1;
	   REPEAT
	      INC(k, 1);
	      twotok := 2*twotok;
	   UNTIL (FloatSD(twotok) >= alim);
	   eps := 1.0E-4;
	   ADI(A, B, C, DD, E, F, G, U, k, alpha, beta, eps);
	   WriteString('ADI Solution:');
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
	         work1 := D(-4.0)*u^[i]^[j];
	         work2 := u^[i+1]^[j]+u^[i-1]^[j];
	         g^[i]^[j] := work1+work2+u^[i]^[j-1]+u^[i]^[j+1];
	      END;
		      WriteString('       ');
	      FOR j := 1 TO jmax-2 DO
	         WriteLongReal(g^[i]^[j], 7, 2)
	      END; 
	      WriteLn
	   END;
	   ReadLn;
	ELSE
	   Error('XADI', 'Not enough memory');
	END;
	IF (A # NilLMatrix) THEN DisposeLMatrix(A); END;
	IF (B # NilLMatrix) THEN DisposeLMatrix(B); END;
	IF (C # NilLMatrix) THEN DisposeLMatrix(C); END;
	IF (DD # NilLMatrix) THEN DisposeLMatrix(DD); END;
	IF (E # NilLMatrix) THEN DisposeLMatrix(E); END;
	IF (F # NilLMatrix) THEN DisposeLMatrix(F); END;
	IF (G # NilLMatrix) THEN DisposeLMatrix(G); END;
	IF (U # NilLMatrix) THEN DisposeLMatrix(U); END;
END XADI.
