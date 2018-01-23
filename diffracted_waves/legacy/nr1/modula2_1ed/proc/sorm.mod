IMPLEMENTATION MODULE SORM;

   FROM NRSystem IMPORT LongReal, D;
   FROM NRIO     IMPORT ReadLn, WriteLn, Error;
   FROM NRLMatr  IMPORT LMatrix, DisposeLMatrix, CreateLMatrix, GetLMatrixAttr, 
                        NilLMatrix, PtrToLLines;  
   FROM NRIVect  IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector, 
                        GetIVectorAttr, NilIVector;

   PROCEDURE SOR(A, B, C, DD, E, F, U: LMatrix; 
                 rjac: LongReal); 
      CONST 
         maxits = 1000; 
         eps = 1.0E-5; 
      VAR 
         n, l, j, jMax, m,
         nB, nC, nD, nE, nF, nU, mB, mC, mD, mE, mF, mU: INTEGER; 
         resid, omega, anormf, anorm: LongReal; (* Double precision is a good idea
                                                   for jMax bigger than about 25. *)
         a, b, c, d, e, f, u: PtrToLLines;
   BEGIN 
      GetLMatrixAttr(A, jMax, m, a);
      GetLMatrixAttr(B, nB, mB, b);
      GetLMatrixAttr(C, nC, mC, c);
      GetLMatrixAttr(DD, nD, mD, d);
      GetLMatrixAttr(E, nE, mE, e);
      GetLMatrixAttr(F, nF, mF, f);
      GetLMatrixAttr(U, nU, mU, u);
      IF ( (jMax = nB) AND (nB = nC) AND (nC = nD) AND (nD = nE) AND (nE = nF) AND
              (jMax = m) AND (m = mB) AND (mB = mC) AND (mC = mD) AND (mD = mE) AND
              (mE = mF) ) THEN
	      anormf := 0.0; (* Compute initial norm of residual. Stop
                         iteration when norm has been reduced by a factor eps. *)
	      FOR j := 1 TO jMax-2 DO 
	         FOR l := 1 TO jMax-2 DO 
	            anormf := anormf+ABS(f^[j]^[l]) (* Assumes initial U is zero. *)
	         END
	      END; 
	      omega := 1.0; 
	      FOR n := 1 TO maxits DO 
	         anorm := 0.0; 
	         FOR j := 1 TO jMax-2 DO 
	            FOR l := 1 TO jMax-2 DO 
	               IF ODD(j+l+2) = ODD(n) THEN (* Odd-even ordering. *)
	                  resid := a^[j]^[l]*u^[j+1]^[l]+b^[j]^[l]*u^[j-1]^[l]+c^[j]^[l]*u^[j]^[l+1]+d^[j]^[l]*u^[j]^[l-1]+e^[j]^[l]*u^[j]^[l]-f^[j]^[l]; 
	                  anorm := anorm+ABS(resid); 
	                  u^[j]^[l] := u^[j]^[l]-omega*resid/e^[j]^[l]
	               END
	            END
	         END; 
	         IF n = 1 THEN 
	            omega := D(1.0)/(D(1.0)-D(0.5)*rjac*rjac)
	         ELSE 
	            omega := D(1.0)/(D(1.0)-D(0.25)*rjac*rjac*omega)
	         END; 
	         IF (n > 1) AND (anorm < D(eps)*anormf) THEN RETURN END
	      END; 
	      Error('SOR', 'Too many iterations.'); 
	      WriteLn; 
	      ReadLn; 
	   ELSE
	      Error('SOR', 'Inproper input data.');
	   END;
   END SOR; 

END SORM.
