IMPLEMENTATION MODULE LUDecomp;

   FROM NRIO    IMPORT Error;
   FROM NRMatr  IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRIVect IMPORT IVector, PtrToIntegers, GetIVectorAttr;
   FROM NRVect  IMPORT Vector, DisposeVector, PtrToReals, CreateVector,
                       GetVectorAttr;

   PROCEDURE LUDCMP(    A:    Matrix;
                        INDX: IVector;
                    VAR d:    REAL);
      CONST
         tiny = 1.0E-15;
      VAR 
         k, j, imax, i, length, n, m: INTEGER; 
         sum, dum, big: REAL; 
         a:    PtrToLines;
         VV:   Vector;(* VV stores the implicit scaling of each row. *)
         vv:   PtrToReals;
         indx: PtrToIntegers;
   BEGIN 
      GetMatrixAttr(A, n, m, a);
      IF n = m THEN
	      CreateVector(n, VV, vv); 
	      GetIVectorAttr(INDX, length, indx);
	      d := 1.0; (* No row interchanges yet. *)
	      FOR i := 0 TO n-1 DO (* Loop over rows to get the implicit scaling
                               information. *)
	         big := 0.0; 
	         FOR j := 0 TO n-1 DO 
	            IF ABS(a^[i]^[j]) > big THEN 
	               big := ABS(a^[i]^[j])
	            END
	         END; 
	         IF big = 0.0 THEN (* No nonzero largest element. *)
	            Error('LUDCMP', 'singular matrix'); 
	         END; 
	         vv^[i] := 1.0/big (* Save the scaling. *)
	      END; 
	      FOR j := 0 TO n-1 DO (* This is the loop over columns of Crout's method. *)
	         FOR i := 0 TO j-1 DO 
			   (*
			     This is equation (2.3.12) except for i=j.
			   *)
	            sum := a^[i]^[j]; 
	            FOR k := 0 TO i-1 DO 
	               sum := sum-a^[i]^[k]*a^[k]^[j]
	            END; 
	            a^[i]^[j] := sum
	         END; 
	         big := 0.0; (* Initialize for the search for largest
                         pivot element. *)
	         FOR i := j TO n-1 DO (* This is i=j of equation (2.3.12) and
                                    i=j+1ldots n of equation (2.3.13). *)
	            sum := a^[i]^[j]; 
	            FOR k := 0 TO j-1 DO 
	               sum := sum-a^[i]^[k]*a^[k]^[j]
	            END; 
	            a^[i]^[j] := sum; 
				   (*
				     Is the figure of merit for the pivot better than the best so far?
				   *)
	            dum := vv^[i]*ABS(sum); 
	            IF dum >= big THEN 
	               big := dum; 
	               imax := i
	            END
	         END; 
	         IF j <> imax THEN 
			   (*
			     Do we need to interchange rows?
			   *)
	            FOR k := 0 TO n-1 DO (* Yes, do so... *)
	               dum := a^[imax]^[k]; 
	               a^[imax]^[k] := a^[j]^[k]; 
	               a^[j]^[k] := dum
	            END; 
	            d := -d; (* ...and change the parity of d. *)
	            vv^[imax] := vv^[j](* Also interchange the scale factor. *)
	         END; 
	         indx^[j] := imax; 
	         IF a^[j]^[j] = 0.0 THEN 
	            a^[j]^[j] := tiny
	         END; 
			   (*
			     If the pivot element is zero the matrix is singular
			     (at least to the precision of the algorithm).  For some applications on
			     singular matrices, it is desirable to substitute tiny for zero.
			   *)
	         IF j <> n-1 THEN 
	            dum := 1.0/a^[j]^[j]; (* Now, finally, divide by the
                                      pivot element. *)
	            FOR i := j+1 TO n-1 DO 
	               a^[i]^[j] := a^[i]^[j]*dum
	            END
	         END
	      END; (* Clenshaw's recurrence. *)
	      DisposeVector(VV)
	   ELSE
	      Error('LUDCMP', 'Inproper matrix!');
      END;
   END LUDCMP; 

   PROCEDURE LUBKSB(A:    Matrix; 
                    INDX: IVector; 
                    B:    Vector); 
      VAR 
         j, ip, ii, i, length, n, m: INTEGER; 
         a:    PtrToLines;
         sum:  REAL; 
         indx: PtrToIntegers;
         b:    PtrToReals;
   BEGIN 
      GetMatrixAttr(A, n, m, a);
      IF n = m THEN
	      GetIVectorAttr(INDX, length, indx);
	      GetVectorAttr(B, length, b);
	      ii := -1; 
		   (*
		     When ii is set to a positive value, or zero, it will
		     become the index of the first nonvanishing element of b.  We now do
		     the forward substitution, equation (2.3.6).  The only new wrinkle is to
		     unscramble the permutation as we go.
		   *)
	      FOR i := 0 TO n-1 DO 
	         ip := indx^[i]; 
	         sum := b^[ip]; 
	         b^[ip] := b^[i]; 
	         IF ii <> -1 THEN 
	            FOR j := ii TO i-1 DO 
	               sum := sum-a^[i]^[j]*b^[j]
	            END
	         ELSIF sum <> 0.0 THEN (* a nonzero element was encountered, so
                                   from now on we will have to do the sums in the loop above. *)
	            ii := i
	         END; 
	         b^[i] := sum
	      END; 
	      FOR i := n-1 TO 0 BY -1 DO 
		   (*
		     Now we do the backsubstitution, equation (2.3.7).
		   *)
	         sum := b^[i]; 
	         FOR j := i+1 TO n-1 DO 
	            sum := sum-a^[i]^[j]*b^[j]
	         END; 
	         b^[i] := sum/a^[i]^[i](* Store a component of the solution
                                   vector x. *)
	      END(* All done! *)
	   ELSE
	      Error('LUBKSB', 'Inproper matrix!');
      END;
   END LUBKSB; 

END LUDecomp.
