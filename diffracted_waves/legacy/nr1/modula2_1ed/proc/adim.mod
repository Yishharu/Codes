IMPLEMENTATION MODULE ADIM;

   FROM NRMath   IMPORT Sqrt, SqrtDD;
   FROM NRSystem IMPORT LongReal, D;
   FROM NRIO     IMPORT Error;
   FROM NRLMatr  IMPORT LMatrix, DisposeLMatrix, CreateLMatrix, GetLMatrixAttr,
                        NilLMatrix, PtrToLLines;
   FROM NRIVect  IMPORT IVector, DisposeIVector, PtrToIntegers, CreateIVector,
                        GetIVectorAttr, NilIVector;
   FROM NRLVect  IMPORT LVector, DisposeLVector, PtrToLongReals, CreateLVector,
                        GetLVectorAttr, NilLVector;

   CONST
      jj = 50;
      kk = 6;
      nrr = 32; (* This is 2^(kk-1). Double precision is a good idea
                   for jMax bigger than about 25. *)
   VAR 
      AA, BB, CC, RR, UU, ALPH, BET, R: LVector;  
      PSI, SS: LMatrix; 
      aa, bb, cc, rr, uu, alph, bet, r: PtrToLongReals;
      psi, s: PtrToLLines;

   PROCEDURE Tridag(A, B, C, R, U: LVector;
                    n: INTEGER); 
   (*
     This is a double precision version of Tridag for use with ADI.
   *)
      VAR 
         j, nA, nB, nC, nR, nU:   INTEGER; 
         bet, work: LongReal; 
         GAM: LVector; 
         a, b, c, r, u, gam: PtrToLongReals;
   BEGIN 
      GetLVectorAttr(U, nU,  u);
      GetLVectorAttr(A, nA, a);
      GetLVectorAttr(B, nB, b);
      GetLVectorAttr(C, nC, c);
      GetLVectorAttr(R, nR, r);
      IF (nU = nA) AND (nA = nB) AND (nB = nC) AND (nC = nR) THEN
         CreateLVector(jj, GAM, gam);
         IF GAM # NilLVector THEN
		      IF b^[0] = D(0.0) THEN
		         Error('Tridag', '');
		      ELSE;
			      bet := b^[0];
			      u^[0] := r^[0]/bet;
			      FOR j := 1 TO n-1 DO
			         gam^[j] := c^[j-1]/bet;
			         bet := b^[j]-a^[j]*gam^[j];
			         IF bet = D(0.0) THEN
			            Error('Tridag', '');
			         END;
			         work := a^[j]*u^[j-1];
			         u^[j] := (r^[j]-work)/bet;
			      END;
			      FOR j := n-2 TO 0 BY -1 DO
			         work := gam^[j+1]*u^[j+1];
			         u^[j] := u^[j]-work;
			      END;
			   END;
			   DisposeLVector(GAM);
			ELSE
			   Error('Tridag', 'Not enough memory.');
			END;
		ELSE
		   Error('Tridag', 'Inproper input vectors.');
		END;
   END Tridag; 

   PROCEDURE CreateAll;
   BEGIN
      CreateLVector(jj, AA, aa);
      CreateLVector(jj, BB, bb);
      CreateLVector(jj, CC, cc);
      CreateLVector(jj, RR, rr);
      CreateLVector(jj, UU, uu);
      CreateLVector(kk, ALPH, alph);
      CreateLVector(kk, BET, bet);
      CreateLVector(nrr, R, r);
      CreateLMatrix(jj, jj, PSI, psi);
      CreateLMatrix(nrr, kk, SS, s);
   END CreateAll; 

   PROCEDURE DisposeAll;
   BEGIN
      IF AA # NilLVector THEN DisposeLVector(AA) END;
      IF	BB # NilLVector THEN DisposeLVector(BB) END;
      IF CC # NilLVector THEN DisposeLVector(CC) END;
      IF RR # NilLVector THEN DisposeLVector(RR) END;
      IF UU # NilLVector THEN DisposeLVector(UU) END;
      IF ALPH # NilLVector THEN DisposeLVector(ALPH) END;
      IF BET # NilLVector THEN DisposeLVector(BET) END;
      IF R # NilLVector THEN DisposeLVector(R) END;
      IF PSI # NilLMatrix THEN DisposeLMatrix(PSI) END;
      IF SS # NilLMatrix THEN DisposeLMatrix(SS) END;
   END DisposeAll;

   PROCEDURE ADI(A, B, C, DD, E, F, G, U: LMatrix;
                 k: INTEGER;
                 alpha, beta, eps: LongReal); 
      CONST 
         maxits = 100; 
      VAR 
         m, nB, nC, nD, nE, nF, nU, nG, mB, mC, mD, mE, mF, mG, mU,
         i, nr, nits, next, n, l, kits, k1, j, jmax, twopwr: INTEGER; 
         rfact, resid, disc, anormg, anorm, ab, work1, work2: LongReal; 
         a, b, c, d, e, f, g, u: PtrToLLines;
   BEGIN 
      GetLMatrixAttr(A, jmax, m, a);
      GetLMatrixAttr(B, nB, mB, b);
      GetLMatrixAttr(C, nC, mC, c);
      GetLMatrixAttr(DD, nD, mD, d);
      GetLMatrixAttr(E, nE, mE, e);
      GetLMatrixAttr(F, nF, mF, f);
      GetLMatrixAttr(G, nG, mG, g);
      GetLMatrixAttr(U, nU, mU, u);
      IF jmax > jj THEN Error('ADI', 'Increase jj.'); RETURN; END; 
      IF k > (kk-1) THEN Error('ADI', 'Increase kk.'); RETURN; END; 
      CreateAll;
      IF ( (AA # NilLVector) AND (BB # NilLVector) AND (CC # NilLVector) AND 
           (RR # NilLVector) AND (UU # NilLVector) AND (ALPH # NilLVector) AND 
           (BET # NilLVector) AND (R # NilLVector) AND (PSI # NilLMatrix) AND 
           (SS # NilLMatrix) ) THEN
	      IF ( (jmax = nB) AND (nB = nC) AND (nC = nD) AND (nD = nE) AND (nE = nF) AND
	              (jmax = m) AND (m = mB) AND (mB = mC) AND (mC = mD) AND (mD = mE) AND
	              (mE = mF) ) THEN 
	         k1 := k+1; 
		      nr := 1; 
		      FOR i := 1 TO k DO nr := 2*nr END; 
		      alph^[0] := alpha; (* Determine r's from (17.6.15)-(17.6.19). *)
		      bet^[0] := beta; 
		      FOR j := 1 TO k DO 
		         alph^[j] := SqrtDD(alph^[j-1]*bet^[j-1]);
		         work1 := alph^[j-1]+bet^[j-1];
		         bet^[j] := D(0.5)*work1;
		      END;
		      s^[0]^[0] := SqrtDD(alph^[k1-1]*bet^[k1-1]);
		      FOR j := 1 TO k DO
		         ab := alph^[k1-j-1]*bet^[k1-j-1];
		         twopwr := 1;
		         FOR i := 1 TO j-1 DO
		            twopwr := 2*twopwr
		         END;
		         FOR n := 1 TO twopwr DO
		            disc := SqrtDD((s^[n-1]^[j-1]*s^[n-1]^[j-1])-ab);
		            s^[2*n-1]^[j] := s^[n-1]^[j-1]+disc;
		            s^[2*n-2]^[j] := ab/s^[2*n-1]^[j]
		         END
		      END;
		      FOR n := 1 TO nr DO
		         r^[n-1] := s^[n-1]^[k1-1]
		      END;
		      anormg := 0.0; (* Compute initial residual, assuming U is
                          zero. *)
		      FOR j := 2 TO jmax-1 DO
		         FOR l := 2 TO jmax-1 DO
		            anormg := anormg+ABS(g^[j-1]^[l-1]);
		            work1 := -d^[j-1]^[l-1]*u^[j-1]^[l-2];
		            work2 := f^[j-1]^[l-1]*u^[j-1]^[l];
		            psi^[j-1]^[l-1] := work1+(r^[0]-e^[j-1]^[l-1])*u^[j-1]^[l-1]-work2;(* Equation (17.6.23). *)
		         END
		      END;
		      nits := maxits DIV nr;
		      FOR kits := 1 TO nits DO
		         FOR n := 1 TO nr DO (* Start cycle of 2^k iterations. *)
		            IF n = nr THEN next := 1
		            ELSE next := n+1 END;
		            rfact := r^[n-1]+r^[next-1]; (* This is "2r" in (17.6.27). *)
		            FOR l := 2 TO jmax-1 DO
		               FOR j := 2 TO jmax-1 DO (* Solve (17.6.24). *)
		                  aa^[j-2] := a^[j-1]^[l-1];
		                  bb^[j-2] := b^[j-1]^[l-1]+r^[n-1];
		                  cc^[j-2] := c^[j-1]^[l-1];
		                  rr^[j-2] := psi^[j-1]^[l-1]-g^[j-1]^[l-1]
		               END;
		               Tridag(AA, BB, CC, RR, UU, jmax-2);
		               FOR j := 2 TO jmax-1 DO (* Equation (17.6.25). *)
		                  psi^[j-1]^[l-1] := -psi^[j-1]^[l-1]+D(2.0)*r^[n-1]*uu^[j-2]
		               END
		            END;
		            FOR j := 2 TO jmax-1 DO
		               FOR l := 2 TO jmax-1 DO (* Solve (17.6.26). *)
		                  aa^[l-2] := d^[j-1]^[l-1]; 
		                  bb^[l-2] := e^[j-1]^[l-1]+r^[n-1]; 
		                  cc^[l-2] := f^[j-1]^[l-1]; 
		                  rr^[l-2] := psi^[j-1]^[l-1]
		               END; 
		               Tridag(AA, BB, CC, RR, UU, jmax-2); 
		               FOR l := 2 TO jmax-1 DO 
		                  u^[j-1]^[l-1] := uu^[l-2]; (* Store current
                                                      value of solution. *)
		                  psi^[j-1]^[l-1] := -psi^[j-1]^[l-1]+rfact*uu^[l-2]
			                                          (* Equation (17.6.27). *)
		               END;
		            END
		         END; 
		         anorm := 0.0; (* Check residual for convergence every
                                2^k iterations. *)
		         FOR j := 2 TO jmax-1 DO 
		            FOR l := 2 TO jmax-1 DO 
		               resid := a^[j-1]^[l-1]*u^[j-2]^[l-1]+
		                       (b^[j-1]^[l-1]+e^[j-1]^[l-1])*u^[j-1]^[l-1]+
		                       c^[j-1]^[l-1]*u^[j]^[l-1]+d^[j-1]^[l-1]*u^[j-1]^[l-2]+
		                       f^[j-1]^[l-1]*u^[j-1]^[l]+g^[j-1]^[l-1]; 
		               anorm := anorm+ABS(resid)
		            END
		         END; 
		         IF anorm < eps*anormg THEN 
		            DisposeAll; 
		            RETURN;
		         END
		      END; 
		      Error('ADI', 'Too many iterations.'); 
		   ELSE
		      Error('ADI', 'Inproper input data.');
		   END;
	   ELSE
	      Error('ADI', 'Not enough memory.');
	   END;
      DisposeAll; 
   END ADI; 

END ADIM.
