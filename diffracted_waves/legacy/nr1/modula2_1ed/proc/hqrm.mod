IMPLEMENTATION MODULE HQRM;

   FROM NRMath IMPORT Sqrt;
   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, CreateMatrix, DisposeMatrix, GetMatrixAttr,  
                      NilMatrix, PtrToLines;
   FROM NRVect IMPORT Vector, CreateVector, DisposeVector, PtrToReals, 
                      GetVectorAttr, NilVector;

   PROCEDURE sign(a, b: REAL): REAL; 
   BEGIN 
      IF b < 0.0 THEN RETURN -ABS(a)
      ELSE RETURN ABS(a)
      END; 
   END sign; 

   PROCEDURE min(a, b: INTEGER): INTEGER; 
   BEGIN 
      IF a < b THEN RETURN a
      ELSE RETURN b
      END; 
   END min; 

   PROCEDURE HQR(A: Matrix; WR, WI: Vector); 
      VAR 
         n, nwr, nwi, nn, m, ma, l, k, j, its, i, mmin: INTEGER; 
         z, y, x, w, v, u, t, s, r, q, p, anorm: REAL; 
         a: PtrToLines;
         wr, wi: PtrToReals;
   BEGIN (* Compute matrix norm for possible use
            in locating single small subdiagonal element. *)
      GetMatrixAttr(A, n, ma, a);
      GetVectorAttr(WR, nwr, wr);
      GetVectorAttr(WI, nwi, wi);
      anorm := ABS(a^[0]^[0]); 
      FOR i := 1 TO n-1 DO 
         FOR j := i-1 TO n-1 DO 
            anorm := anorm+ABS(a^[i]^[j])
         END
      END; 
      nn := n-1; 
      t := 0.0; (* ...gets changed only by an exceptional shift. *)
      WHILE nn >= 0 DO (* Begin search for next eigenvalue. *)
         its := 0; 
         LOOP
	         LOOP
		         FOR l := nn TO 1 BY -1 DO (* Begin iteration: look for single small
                                            subdiagonal element. *)
		            s := ABS(a^[l-1]^[l-1])+ABS(a^[l]^[l]); 
		            IF s = 0.0 THEN 
		               s := anorm
		            END; 
		            IF ABS(a^[l]^[l-1])+s = s THEN 
		               EXIT; 
		            END
		         END; 
		         l := 0; 
		         EXIT;
		      END;
	         x := a^[nn]^[nn]; 
	         IF l = nn THEN (* One root found. *)
	            wr^[nn] := x+t; 
	            wi^[nn] := 0.0; 
	            DEC(nn, 1)
	         ELSE 
	            y := a^[nn-1]^[nn-1]; 
	            w := a^[nn]^[nn-1]*a^[nn-1]^[nn]; 
	            IF l = nn-1 THEN (* Two roots found... *)
	               p := 0.5*(y-x); 
	               q := p*p+w; 
	               z := Sqrt(ABS(q)); 
	               x := x+t; 
	               IF q >= 0.0 THEN (* ...a real pair. *)
	                  z := p+sign(z, p); 
	                  wr^[nn] := x+z; 
	                  wr^[nn-1] := wr^[nn]; 
	                  IF z <> 0.0 THEN 
	                     wr^[nn] := x-w/z
	                  END; 
	                  wi^[nn] := 0.0; 
	                  wi^[nn-1] := 0.0
	               ELSE (* ...a complex pair. *)
	                  wr^[nn] := x+p; 
	                  wr^[nn-1] := wr^[nn]; 
	                  wi^[nn] := z; 
	                  wi^[nn-1] := -z
	               END; 
	               DEC(nn, 2)
	            ELSE 
	               IF its = 30 THEN (* No roots found.  Continue iteration. *)
	                  Error('pause in routine HQR', 'too many iterations'); 
	               END; 
	               IF (its = 10) OR (its = 20) THEN 
						   (*
						     Form exceptional shift.
						   *)
	                  t := t+x; 
	                  FOR i := 0 TO nn DO 
	                     a^[i]^[i] := a^[i]^[i]-x
	                  END; 
	                  s := ABS(a^[nn]^[nn-1])+ABS(a^[nn-1]^[nn-2]); 
	                  x := 0.75*s; 
	                  y := x; 
	                  w := -0.4375*s*s
	               END; 
	               INC(its); 
	               m := nn-2;(* Form shift. Then
                             look for 2 con-sec-u-tive small subdiagonal elements. *)
	               LOOP 
	                  z := a^[m]^[m]; 
	                  r := x-z; 
	                  s := y-z; 
	                  p := (r*s-w)/a^[m+1]^[m]+a^[m]^[m+1]; (* Equation 11.6.23. *)
	                  q := a^[m+1]^[m+1]-z-r-s; 
	                  r := a^[m+2]^[m+1]; 
	                  s := ABS(p)+ABS(q)+ABS(r); (* Scale to prevent overflow or underflow. *)
	                  p := p/s; 
	                  q := q/s; 
	                  r := r/s; 
	                  IF m = l THEN EXIT END; 
	                  u := ABS(a^[m]^[m-1])*(ABS(q)+ABS(r)); 
	                  v := ABS(p)*(ABS(a^[m-1]^[m-1])+ABS(z)+ABS(a^[m+1]^[m+1])); 
	                  IF u+v = v THEN EXIT; END;(* Equation 11.6.26. *)
	                  DEC(m);
	               END; 
	               FOR i := m+2 TO nn DO 
	                  a^[i]^[i-2] := 0.0; 
	                  IF i <> m+2 THEN 
	                     a^[i]^[i-3] := 0.0
	                  END
	               END; 
	               FOR k := m TO nn-1 DO (* Double qr step on rows
                                         l to nn and columns m to nn. *)
	                  IF k <> m THEN 
			               p := a^[k]^[k-1]; (* Begin setup
                                       of Householder vector. *)
			               q := a^[k+1]^[k-1]; 
			               IF k <> nn-1 THEN 
			                 r := a^[k+2]^[k-1]
			               ELSE 
			                 r := 0.0
			               END; 
			               x := ABS(p)+ABS(q)+ABS(r); 
			               IF x <> 0.0 THEN 
			                 p := p/x; (* Scale to
                                 prevent overflow or underflow. *)
			                 q := q/x; 
			                 r := r/x
			               END
	                  END; 
	                  s := sign(Sqrt(p*p+q*q+r*r), p); 
	                  IF s <> 0.0 THEN 
	                     IF k = m THEN 
	                        IF l <> m THEN 
	                           a^[k]^[k-1] := -a^[k]^[k-1]
	                        END; 
	                     ELSE 
	                        a^[k]^[k-1] := -s*x
	                     END; 
	                     p := p+s; (* Equations 11.6.24. *)
	                     x := p/s; 
	                     y := q/s; 
	                     z := r/s; 
	                     q := q/p; 
	                     r := r/p; 
	                     FOR j := k TO nn DO (* Row modification. *)
	                        p := a^[k]^[j]+q*a^[k+1]^[j]; 
	                        IF k <> nn-1 THEN 
	                           p := p+r*a^[k+2]^[j]; 
	                           a^[k+2]^[j] := a^[k+2]^[j]-p*z
	                        END; 
	                        a^[k+1]^[j] := a^[k+1]^[j]-p*y; 
	                        a^[k]^[j] := a^[k]^[j]-p*x
	                     END; 
	                     mmin := min(nn, k+3); 
	                     FOR i := l TO mmin DO (* Column modification. *)
	                        p := x*a^[i]^[k]+y*a^[i]^[k+1]; 
	                        IF k <> nn-1 THEN 
	                           p := p+z*a^[i]^[k+2]; 
	                           a^[i]^[k+2] := a^[i]^[k+2]-p*r
	                        END; 
	                        a^[i]^[k+1] := a^[i]^[k+1]-p*q; 
	                        a^[i]^[k] := a^[i]^[k]-p
	                     END;
	                  END;
	               END; 
	               EXIT; (* Go back for next iteration 
                           on current eigenvalue. *)
	            END;
	         END;
	         EXIT;
	      END (* LOOP *);
      END;(* Go back for next eigenvalue. *)
   END HQR; 

END HQRM.
