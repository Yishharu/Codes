IMPLEMENTATION MODULE Simplex;

   FROM NRIO    IMPORT Error;
   FROM NRMatr  IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                       NilMatrix, PtrToLines;
   FROM NRIVect IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                       GetIVectorAttr, NilIVector;

    PROCEDURE Simplx(    A: Matrix; 
                         m, n, m1, m2, m3: INTEGER; 
                     VAR icase: INTEGER; 
                         IZROV, IPOSV: IVector); 
      CONST 
         eps = 1.0E-6; 
      VAR 
         nl2, nl1, m12, kp, kh, k, is, ir, ip, i, nextStep,
         nIZROV, mIPOSV, mA, nA: INTEGER; 
         q1, bmax: REAL; 
         L1, L2, L3: IVector; 
         l1, l2, l3, izrov, iposv: PtrToIntegers;
         a: PtrToLines;

      PROCEDURE DisposeVectors;
      BEGIN
	      IF L1 # NilIVector THEN DisposeIVector(L1); END;
	      IF L2 # NilIVector THEN DisposeIVector(L2); END;
	      IF L3 # NilIVector THEN DisposeIVector(L3); END;      
      END DisposeVectors;

      PROCEDURE simp1(    A: Matrix; 
                          mm: INTEGER; 
                          LL: IVector; 
                          nll, iabf: INTEGER; 
                      VAR kp: INTEGER; 
                      VAR bmax: REAL); 
	   (*
	     Determines the maximum of those elements whose index
	     is contained in the supplied list LL, either with or
	     without taking the absolute value, as flagged by IABF.
	   *)
         VAR 
            n, m, k, nl: INTEGER; 
            test: REAL; 
            a: PtrToLines;
            ll: PtrToIntegers;
      BEGIN 
         GetMatrixAttr(A, m, n, a);
         GetIVectorAttr(LL, nl, ll);
         kp := ll^[0]; 
         bmax := a^[mm]^[kp]; 
         FOR k := 2 TO nll DO 
            IF iabf = 0 THEN 
               test := a^[mm]^[ll^[k-1]]-bmax
            ELSE 
               test := ABS(a^[mm]^[ll^[k-1]])-ABS(bmax)
            END; 
            IF test > 0.0 THEN 
               bmax := a^[mm]^[ll^[k-1]]; 
               kp := ll^[k-1]
            END
         END
      END simp1; 

      PROCEDURE simp2(A: Matrix;    m, n: INTEGER;
                      L2: IVector;  nl2: INTEGER; 
                      VAR ip: INTEGER; 
                      kp: INTEGER;  VAR q1: REAL); 
	   (*
	     Locate a pivot element, taking degeneracy into account.
	   *)
         CONST 
            eps = 1.0E-6; 
         VAR 
            mA, nA, nl, k, ii, i: INTEGER; 
            qp, q0, q: REAL; 
            a: PtrToLines;
            l2: PtrToIntegers;
      BEGIN 
         GetMatrixAttr(A, mA, nA, a);
         GetIVectorAttr(L2, nl, l2);
         ip := 0; 
         LOOP
	         FOR i := 1 TO nl2 DO 
	            IF a^[l2^[i-1]]^[kp] < -eps THEN EXIT; END
	         END; 
	         RETURN; 
	      END;(* No possible pivots.  Return with message. *)
         q1 := -a^[l2^[i-1]]^[0]/a^[l2^[i-1]]^[kp]; 
         ip := l2^[i-1]; 
         FOR i := i+1 TO nl2 DO 
            ii := l2^[i-1]; 
            IF a^[ii]^[kp] < (-eps) THEN 
               q := -a^[ii]^[0]/a^[ii]^[kp]; 
               IF q < q1 THEN 
                  ip := ii; 
                  q1 := q
               ELSIF q = q1 THEN (* We have a degeneracy. *)
                  LOOP
	                  FOR k := 1 TO n DO 
			               qp := -a^[ip]^[k]/a^[ip]^[kp]; 
			               q0 := -a^[ii]^[k]/a^[ii]^[kp]; 
			               IF q0 <> qp THEN 
			                 EXIT; 
			               END
	                  END; 
	                  EXIT;
	               END;
                  IF q0 < qp THEN ip := ii END
               END
            END
         END; 
      END simp2; 

      PROCEDURE simp3(A: Matrix; 
                      i1, k1, ip, kp: INTEGER); 
	   (*
	     Matrix operations to exchange a left-hand and right-hand variable
	     (see text).
	   *)
         VAR 
            m, n, kk, ii: INTEGER; 
            piv: REAL; 
            a: PtrToLines;
      BEGIN 
         GetMatrixAttr(A, m, n, a);
         piv := 1.0/a^[ip]^[kp]; 
         FOR ii := 1 TO i1+1 DO 
            IF ii-1 <> ip THEN 
               a^[ii-1]^[kp] := a^[ii-1]^[kp]*piv; 
               FOR kk := 1 TO k1+1 DO 
                  IF kk-1 <> kp THEN 
                     a^[ii-1]^[kk-1] := a^[ii-1]^[kk-1]-a^[ip]^[kk-1]*a^[ii-1]^[kp]
                  END
               END
            END
         END; 
         FOR kk := 1 TO k1+1 DO 
            IF kk-1 <> kp THEN 
               a^[ip]^[kk-1] := -a^[ip]^[kk-1]*piv
            END
         END; 
         a^[ip]^[kp] := piv
      END simp3; 

	   PROCEDURE label5(VAR nextStep: INTEGER); 
	   (* nextStep = 0: RETURN; nextStep = 3: Label 3; *)
	   BEGIN
	      LOOP
		      simp1(A, 0, L1, nl1, 0, kp, bmax); (* Test the z-row for doneness. *)
		      IF bmax <= 0.0 THEN (* Done.  Solution found.  Return
                                   with the good news. *)
		         icase := 0; 
		         DisposeVectors;
		         nextStep := 0;
		         RETURN;
		      END; 
		      simp2(A, m, n, L2, nl2, ip, kp, q1); (* Locate a pivot element (phase two). *)
		      IF ip = 0 THEN (* Objective function is unbounded. Report and return. *)
		         icase := 1; 
		         DisposeVectors;
		         nextStep := 0;
		         RETURN;
		      END; 
		      simp3(A, m, n, ip, kp); (* Exchange a left- and a right-hand variable (phase two),
                                       and return for another iteration. *)
		      is := izrov^[kp-1]; 
		      izrov^[kp-1] := iposv^[ip-1]; 
		      iposv^[ip-1] := is; 
		      IF ir <> 0 THEN 
		         nextStep := 3;
		         RETURN;
		      END; 
		   END;
	   END label5;

   BEGIN 
      GetIVectorAttr(IZROV, nIZROV, izrov);
      GetIVectorAttr(IPOSV, mIPOSV, iposv);
      GetMatrixAttr(A, mA, nA, a);
      IF m <> m1+m2+m3 THEN 
         Error('pause in routine Simplx', 'bad input constraint counts'); 
      END; 
      CreateIVector(n, L1, l1);
      CreateIVector(m, L2, l2);
      CreateIVector(m, L3, l3);
      nl1 := n; (* Initially make all variables right-hand. *)
      FOR k := 1 TO n DO (* Initialize index lists. *)
         l1^[k-1] := k; 
         izrov^[k-1] := k
      END; 
      nl2 := m; (* Make all artificial variables left-hand, *)
      FOR i := 1 TO m DO (* and initialize those lists. *)
         IF a^[i]^[0] < 0.0 THEN (* Constants bi must be nonnegative. *)
            Error('Simplx',  'bad input tableau'); 
         END; 
         l2^[i-1] := i; 
         iposv^[i-1] := n+i
      END; 
      FOR i := 1 TO m2 DO l3^[i-1] := 1 END; (* Used later, but initialized here. *)
      LOOP
	      ir := 0; (* Flag meaning that we are in phase two, i.e
                     have a feasible starting solution. Go to phase two if
                     origin is a feasible solution. *)
	      IF m2+m3 = 0 THEN 
		      label5(nextStep);
		      IF nextStep = 0 THEN 
		         DisposeVectors;
		         RETURN;
		      ELSE
		         EXIT;
		      END;
	      END; 
	      ir := 1; (* Flag meaning we must start out in phase one. *)
	      FOR k := 1 TO n+1 DO (* Compute the auxiliary objective function. *)
	         q1 := 0.0; 
	         FOR i := m1+1 TO m DO 
	            q1 := q1+a^[i]^[k-1]
	         END; 
	         a^[m+2-1]^[k-1] := -q1
	      END; 
	      EXIT;
	   END;
	   LOOP
	      simp1(A, m+1, L1, nl1, 0, kp, bmax); (* Find maximum coefficient of auxiliary
                                                 objective function. *)
	      LOOP
		      IF (bmax <= eps) AND (a^[m+2-1]^[0] < -eps) THEN 
		         icase := -1; (* Auxiliary objective function is still
                           negative and can't be improved, hence
                           no feasible solution exists. *)
		         DisposeVectors;
		         RETURN;
		      ELSIF (bmax <= eps) AND (a^[m+2-1]^[0] <= eps) THEN (* Auxiliary objective function is zero
                                                                   and can't be improved, signaling a feasible starting
                                                                   vector.  Clean out the artificial variables by GOTO 1's and then
                                                                   move on to phase two. *)
		         m12 := m1+m2+1; 
		         IF m12 <= m THEN 
		            FOR ip := m12 TO m DO 
		               IF iposv^[ip-1] = ip+n THEN 
		                  simp1(A, ip, L1, nl1, 1, kp, bmax); 
		                  IF bmax > 0.0 THEN 
		                     nextStep := 1;
		                     EXIT 
		                  END
		               END
		            END
		         END; 
		         ir := 0; (* Set flag indicating we have reached phase two. *)
		         DEC(m12, 1); 
		         IF m1+1 > m12 THEN 
				      label5(nextStep);
				      IF nextStep = 0 THEN 
				         DisposeVectors;
				         RETURN;
				      ELSE
				         EXIT;
				      END;
		         END; 
		         FOR i := m1+1 TO m12 DO 
		            IF l3^[i-m1-1] = 1 THEN 
		               FOR k := 1 TO n+1 DO 
		                  a^[i]^[k-1] := -a^[i]^[k-1]
		               END
		            END(* Go to phase two. *)
		         END; 
			      label5(nextStep);
			      IF nextStep = 0 THEN 
			         DisposeVectors;
			         RETURN;
			      ELSE
			         EXIT;
			      END;
		      END; 
		      simp2(A, m, n, L2, nl2, ip, kp, q1); (* Locate a pivot element (phase one). *)
		      IF ip = 0 THEN (* Maximum of auxiliary objective function
                              is unbounded, so no feasible solution exists. *)
		         icase := -1; 
		         DisposeVectors;
		         RETURN;
		      END; 
		      nextStep := 1;
		      EXIT;
		   END;
		   IF nextStep # 3 THEN
		      simp3(A, m+1, n, ip, kp); (* Exchange a left- and a right-hand variable (phase one),
                                         then update lists. *)
		      LOOP
			      IF iposv^[ip-1] >= n+m1+m2+1 THEN 
			         LOOP
				         FOR k := 1 TO nl1 DO 
				            IF l1^[k-1] = kp THEN EXIT; END
				         END; 
				         EXIT;
				      END;
			         DEC(nl1, 1); 
			         FOR is := k TO nl1 DO 
			            l1^[is-1] := l1^[is]
			         END
			      ELSE 
			         IF iposv^[ip-1] < n+m1+1 THEN 
			            EXIT 
			         END; 
			         kh := iposv^[ip-1]-m1-n; 
			         IF l3^[kh-1] = 0 THEN EXIT END; 
			         l3^[kh-1] := 0
			      END; 
			      a^[m+2-1]^[kp] := a^[m+2-1]^[kp]+1.0; 
			      FOR i := 1 TO m+2 DO 
			         a^[i-1]^[kp] := -a^[i-1]^[kp]
			      END; 
			      EXIT;
			   END;
		      is := izrov^[kp-1]; 
		      izrov^[kp-1] := iposv^[ip-1]; 
		      iposv^[ip-1] := is; 
		      IF ir <> 0 THEN (* If still in phase one, repeat. *)
				   (*
				     End of phase one code for finding an initial feasible solution.  Now,
				     in phase two, optimize it.
				   *)
				ELSE
			      label5(nextStep);
			      IF nextStep = 0 THEN 
			         DisposeVectors;
			         RETURN;
			      END;
		      END; 
		   END;
	   END;
   END Simplx; 

END Simplex.
