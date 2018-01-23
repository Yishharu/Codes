MODULE XLaguer; (* driver for routine Laguer *) 
 
   FROM LaguQ    IMPORT Laguer;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT ReadLn, WriteLn, WriteInt, WriteReal, WriteString, Error;
   FROM NRComp   IMPORT Complex, CVector, DisposeCVector, CreateCVector, 
                        GetCVectorAttr, NilCVector, PtrToComplexes;

   CONST 
      mp1 = 5; 
      ntry = 21; 
      eps = 1.0E-6; 
   VAR 
      i, iflag, j, n: INTEGER; 
      polish: BOOLEAN; 
      x: Complex; 
      A, Y: CVector; 
      a, y: PtrToComplexes;

BEGIN 
   CreateCVector(mp1, A, a);
   CreateCVector(ntry, Y, y);
   IF (A # NilCVector) AND (Y # NilCVector) THEN
	   a^[0].r := 0.0;  a^[0].i := 2.0; 
	   a^[1].r := 0.0;  a^[1].i := 0.0; 
	   a^[2].r := -1.0; a^[2].i := -2.0; 
	   a^[3].r := 0.0;  a^[3].i := 0.0; 
	   a^[4].r := 1.0;  a^[4].i := 0.0; 
	   WriteLn; 
	   WriteString('Roots of polynomial x^4-(1+2i)*x^2+2i'); 
	   WriteLn; 
	   WriteString('           REAL'); 
	   WriteString('       complex'); 
	   WriteLn; 
	   n := -1; 
	   polish := FALSE; 
	   FOR i := 1 TO ntry DO 
	      x.r := (Float(i)-11.0)/10.0; 
	      x.i := (Float(i)-11.0)/10.0; 
	      Laguer(A, mp1-1, x, eps, polish); 
	      IF n = -1 THEN 
	         n := 0; 
	         y^[0] := x; 
	         WriteInt(n+1, 5); 
	         WriteReal(x.r, 12, 6); 
	         WriteReal(x.i, 12, 6); 
	         WriteLn
	      ELSE 
	         iflag := 0; 
	         FOR j := 0 TO n DO 
	            IF Sqrt(((x.r-y^[j].r)*(x.r-y^[j].r))+((x.i-y^[j].i)*(x.i-y^[j].i))) <= eps*Sqrt((x.r*x.r)+(x.i*x.i)) THEN 
	               iflag := 1
	            END
	         END; 
	         IF iflag = 0 THEN 
	            INC(n, 1); 
	            y^[n] := x; 
	            WriteInt(n+1, 5); 
	            WriteReal(x.r, 12, 6); 
	            WriteReal(x.i, 12, 6); 
	            WriteLn
	         END
	      END
	   END;
	   ReadLn;
	ELSE
	   Error('XLaguer', 'Not enough memory.');
	END;
   IF (A # NilCVector) THEN DisposeCVector(A) END;
   IF (Y # NilCVector) THEN DisposeCVector(Y) END;
END XLaguer.
