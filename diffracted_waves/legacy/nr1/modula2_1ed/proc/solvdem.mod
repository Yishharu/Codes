IMPLEMENTATION MODULE SolvDEM;

   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error, WriteInt, WriteLn, WriteReal, WriteString;
   FROM NRMatr   IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr, 
                        NilMatrix, PtrToLines;
   FROM NRIVect  IMPORT IVector, CreateIVector, DisposeIVector, PtrToIntegers, 
                        GetIVectorAttr, NilIVector;
   FROM NRVect   IMPORT Vector, CreateVector, DisposeVector, PtrToReals, GetVectorAttr, 
                        NilVector;

      PROCEDURE BKSub(    ne, nb, jf, k1, k2: INTEGER; 
                      VAR c: RealArray3Dim); 
	   (*
	     Back substitution.
	   *)
         VAR 
            nbf, kp, k, j, i, im: INTEGER; 
            xx: REAL; 
      BEGIN 
         nbf := ne-nb; 
         im := 1; 
         FOR k := k2 TO k1 BY -1 DO (* Use recurrence relations to eliminate 
                                       remaining dependences. *)
            kp := k+1; 
            IF k = k1 THEN 
               im := nbf+1
            END; 
            FOR j := 1 TO nbf DO 
               xx := c[j-1, jf-1, kp-1]; 
               FOR i := im TO ne DO 
                  c[i-1, jf-1, k-1] := c[i-1, jf-1, k-1]-c[i-1, j-1, k-1]*xx
               END
            END
         END; 
         FOR k := k1 TO k2 DO 
		   (*
		     Reorder corrections to be in column 1.
		   *)
            kp := k+1; 
            FOR i := 1 TO nb DO 
               c[i-1, 0, k-1] := c[i+nbf-1, jf-1, k-1]
            END; 
            FOR i := 1 TO nbf DO 
               c[i+nb-1, 0, k-1] := c[i-1, jf-1, kp-1]
            END
         END
      END BKSub; 

      PROCEDURE PInvs(    ie1, ie2, je1, jsf, jc1, k, nyj: INTEGER; 
                      VAR c: RealArray3Dim; 
                          S: Matrix); 
		   (*
		     Diagonalize the square subsection of the s matrix, and store
		     the recursion coefficients in c.
		   *)
         VAR 
            js1, jpiv, jp, je2, jcoff, j, irow, ipiv, id, icoff, i,
            nsi, nsj: INTEGER; 
            pivinv, piv, dum, big: REAL; 
            PSCL: Vector;
            INDXR: IVector;
            pscl: PtrToReals; 
            indxr: PtrToIntegers; 
            s: PtrToLines;
      BEGIN 
         GetMatrixAttr(S, nsi, nsj, s);
         CreateVector(nyj, PSCL, pscl);
         CreateIVector(nyj, INDXR, indxr);
         IF (PSCL # NilVector) AND (INDXR # NilIVector) THEN
	         je2 := je1+ie2-ie1; 
	         js1 := je2+1; 
	         FOR i := ie1 TO ie2 DO (* Implicit pivoting, as in section2.1. *)
	            big := 0.0; 
	            FOR j := je1 TO je2 DO 
	               IF ABS(s^[i-1]^[j-1]) > big THEN 
	                  big := ABS(s^[i-1]^[j-1])
	               END
	            END; 
	            IF big = 0.0 THEN Error('PINVS', 'singular matrix - row all 0'); END; 
	            pscl^[i-1] := 1.0/big; 
	            indxr^[i-1] := 0
	         END; 
	         FOR id := ie1 TO ie2 DO 
	            piv := 0.0; 
	            FOR i := ie1 TO ie2 DO 
				   (*
				     Find pivot element.
				   *)
	               IF indxr^[i-1] = 0 THEN 
	                  big := 0.0; 
	                  FOR j := je1 TO je2 DO 
			               IF ABS(s^[i-1]^[j-1]) > big THEN 
			                 jp := j; 
			                 big := ABS(s^[i-1]^[j-1])
			               END
	                  END; 
	                  IF big*pscl^[i-1] > piv THEN 
	                     ipiv := i; 
	                     jpiv := jp; 
	                     piv := big*pscl^[i-1]
	                  END
	               END
	            END; 
	            IF s^[ipiv-1]^[jpiv-1] = 0.0 THEN 
	               Error('PINVS', 'singular matrix'); 
	            END; 
	            indxr^[ipiv-1] := jpiv; (* In place reduction.
                                        Save column ordering. *)
	            pivinv := 1.0/s^[ipiv-1]^[jpiv-1]; 
	            FOR j := je1 TO jsf DO (* Normalize pivot row. *)
	               s^[ipiv-1]^[j-1] := s^[ipiv-1]^[j-1]*pivinv
	            END; 
	            s^[ipiv-1]^[jpiv-1] := 1.0; 
	            FOR i := ie1 TO ie2 DO (* Reduce nonpivot elements in column. *)
	               IF indxr^[i-1] <> jpiv THEN 
	                  IF s^[i-1]^[jpiv-1] <> 0.0 THEN 
	              dum := s^[i-1]^[jpiv-1]; 
	              FOR j := je1 TO jsf DO 
	                s^[i-1]^[j-1] := s^[i-1]^[j-1]-dum*s^[ipiv-1]^[j-1]
	              END; 
	              s^[i-1]^[jpiv-1] := 0.0
	                  END
	               END
	            END
	         END; 
	         jcoff := jc1-js1; (* Sort and store unreduced coefficients. *)
	         icoff := ie1-je1; 
	         FOR i := ie1 TO ie2 DO 
	            irow := indxr^[i-1]+icoff; 
	            FOR j := js1 TO jsf DO 
	               c[irow-1, j+jcoff-1, k-1] := s^[i-1]^[j-1]
	            END
	         END; 
	      ELSE
	         Error('PInvs', 'Not enough memory.');
	      END;
         IF INDXR # NilIVector THEN DisposeIVector(INDXR) END; 
         IF PSCL # NilVector THEN DisposeVector(PSCL) END;
      END PInvs; 

      PROCEDURE Red(iz1, iz2, jz1, jz2, jm1: INTEGER; 
                  jm2, jmf, ic1, jc1, jcf, kc: INTEGER; 
                  VAR c: RealArray3Dim; 
                  S: Matrix); 
		   (*
		     Reduce columns jz1-jz2 of the S matrix, using previous
		     results as stored in the C matrix. Only columns jm1-jm2,jmf
		     are affected by the prior results.
		   *)
         VAR 
            loff, l, j, ic, i, nsi, nsj: INTEGER; 
            vx: REAL; 
            s: PtrToLines;
      BEGIN 
         GetMatrixAttr(S, nsi, nsj, s);
         loff := jc1-jm1; 
         ic := ic1; 
         FOR j := jz1 TO jz2 DO (* Loop over columns to be zeroed. *)
            FOR l := jm1 TO jm2 DO (* Loop over columns altered. *)
               vx := c[ic-1, l+loff-1, kc-1]; 
               FOR i := iz1 TO iz2 DO (* Loop over rows. *)
                  s^[i-1]^[l-1] := s^[i-1]^[l-1]-s^[i-1]^[j-1]*vx
               END
            END; 
            vx := c[ic-1, jcf-1, kc-1]; 
            FOR i := iz1 TO iz2 DO (* relax Plus final element. *)
               s^[i-1]^[jmf-1] := s^[i-1]^[jmf-1]-s^[i-1]^[j-1]*vx
            END; 
            INC(ic, 1)
         END;
      END Red; 

   PROCEDURE SolvDE(itmax: INTEGER; 
                    conv, slowc: REAL; 
                    SCALV: Vector;
                    INDEXV: IVector; 
                    nb, m: INTEGER; 
                    Y: Matrix; 
                    c: RealArray3Dim; 
                    S: Matrix;
                    Difeq: DifeqFunc); 
      VAR
         nyj, nyk, nsi, nsj, ne, ny: INTEGER;
         err, errj, fac, vmax, vz: REAL; 
         ic1, ic2, ic3, ic4, it: INTEGER; 
         j, j1, j2, j3, j4, j5, j6, j7, j8, j9: INTEGER; 
         jc1, jcf, jv, k, k1, k2, km, kp, nvars: INTEGER; 
         ERMAX: Vector;
         KMAX: IVector;
         scalv, ermax: PtrToReals;
         indexv, kmax: PtrToIntegers;
         y, s: PtrToLines;
   BEGIN 
      GetVectorAttr(SCALV, nyj, scalv);
      GetIVectorAttr(INDEXV, ne, indexv);
      GetMatrixAttr(Y, ny, nyk ,y);
      GetMatrixAttr(S, nsi, nsj ,s);
      CreateVector(nyj, ERMAX, ermax);
      CreateIVector(nyj, KMAX, kmax);
      IF (ERMAX # NilVector) AND (KMAX # NilIVector) THEN
	      k1 := 1; (* Set up row and column markers. *)
	      k2 := m; 
	      nvars := ne*m; 
	      j1 := 1; 
	      j2 := nb; 
	      j3 := nb+1; 
	      j4 := ne; 
	      j5 := j4+j1; 
	      j6 := j4+j2; 
	      j7 := j4+j3; 
	      j8 := j4+j4; 
	      j9 := j8+j1; 
	      ic1 := 1; 
	      ic2 := ne-nb; 
	      ic3 := ic2+1; 
	      ic4 := ne; 
	      jc1 := 1; 
	      jcf := ic3; 
	      FOR it := 1 TO itmax DO 
		   (*
		     Primary iteration loop.
		   *)
	         k := k1; (* Boundary
                      conditions at first point. *)
	         Difeq(k, k1, k2, j9, ic3, ic4, INDEXV, S, Y); 
	         PInvs(ic3, ic4, j5, j9, jc1, k1, nyj, c, S); 
	         FOR k := k1+1 TO k2 DO (* Finite difference equations at all 
                                    point pairs. *)
	            kp := k-1; 
	            Difeq(k, k1, k2, j9, ic1, ic4, INDEXV, S, Y); 
	            Red(ic1, ic4, j1, j2, j3, j4, j9, ic3, jc1, jcf, kp, c, S); 
	            PInvs(ic1, ic4, j3, j9, jc1, k, nyj, c, S)
	         END; 
	         k := k2+1; (* Final boundary conditions. *)
	         Difeq(k, k1, k2, j9, ic1, ic2, INDEXV, S, Y); 
	         Red(ic1, ic2, j5, j6, j7, j8, j9, ic3, jc1, jcf, k2, c, S); 
	         PInvs(ic1, ic2, j7, j9, jcf, k2+1, nyj, c, S); 
	         BKSub(ne, nb, jcf, k1, k2, c); (* Back substitution *)
	         err := 0.0; 
	         FOR j := 1 TO ne DO 
			   (*
			     Convergence check, accumulate average error.
			   *)
	            jv := indexv^[j-1]; 
	            errj := 0.0; 
	            km := 0; 
	            vmax := 0.0; 
	            FOR k := k1 TO k2 DO (* Find point with largest error, for
                                     each dependent variable. *)
	               vz := ABS(c[j-1, 0, k-1]); 
	               IF vz > vmax THEN 
	                  vmax := vz; 
	                  km := k
	               END; 
	               errj := errj+vz
	            END; 
	            err := err+errj/scalv^[jv-1]; (* Note weighting for each dependent variable. *)
	            ermax^[j-1] := c[j-1, 0, km-1]/scalv^[jv-1]; 
	            kmax^[j-1] := km
	         END; 
	         err := err/Float(nvars); 
	         fac := 1.0; 
	         IF err > slowc THEN (* Reduce correction applied when error is large. *)
	            fac := slowc/err
	         END; 
	         FOR jv := 1 TO ne DO 
			   (*
			     Apply corrections.
			   *)
	            j := indexv^[jv-1]; 
	            FOR k := k1 TO k2 DO 
	               y^[j-1]^[k-1] := y^[j-1]^[k-1]-fac*c[jv-1, 0, k-1]
	            END
	         END; 
	         WriteLn; 
	         WriteString('   Iter.    Error      FAC'); 
	         WriteLn; (* Summary of corrections for this step. *)
	         WriteInt(it, 6); 
	         WriteReal(err, 12, 6); 
	         WriteReal(fac, 11, 6); 
	         WriteLn; 
	         WriteString('    Var.    Kmax    Max. Error'); 
	         WriteLn; 
	         FOR j := 1 TO ne DO 
	            WriteInt(indexv^[j-1], 6);
	            WriteInt(kmax^[j-1], 9);
	            WriteReal(ermax^[j-1], 14, 6);
	            WriteLn
	         END;
	         IF err < conv THEN 
				   IF ERMAX # NilVector THEN DisposeVector(ERMAX) END;
				   IF KMAX # NilIVector THEN DisposeIVector(KMAX) END;
				   RETURN;
	         END;
	      END; 
	      Error('SolvDE', 'Too many iterations.'); (* Convergence failed. *)
	   ELSE
	      Error('SolvDE', 'Not enough memory.');
	   END;
 	   IF ERMAX # NilVector THEN DisposeVector(ERMAX) END;
	   IF KMAX # NilIVector THEN DisposeIVector(KMAX) END;
   END SolvDE;
END SolvDEM.
