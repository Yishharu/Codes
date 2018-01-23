IMPLEMENTATION MODULE SVD;

   FROM NRMath IMPORT Sqrt;
   FROM NRIO   IMPORT Error;
   FROM NRMatr IMPORT Matrix, GetMatrixAttr, PtrToLines;
   FROM NRVect IMPORT Vector, DisposeVector, PtrToReals, CreateVector, 
                      GetVectorAttr;

   PROCEDURE SVBKSB(U: Matrix; 
                    W: Vector; 
                    V: Matrix; 
                    B,
                    X: Vector); 
      VAR 
         jj, j, i, m, n, nW, nV, mV, mB, nX: INTEGER; 
         s: REAL; 
         TMP: Vector;
         tmp, w, b, x: PtrToReals; 
         u, v: PtrToLines;
   BEGIN 
      GetMatrixAttr(U, m, n, u);
      GetVectorAttr(W, nW, w);
      GetMatrixAttr(V, mV, nV, v);
      GetVectorAttr(B, mB, b);
      GetVectorAttr(X, nX, x);
      CreateVector(n, TMP, tmp);
      FOR j := 0 TO n-1 DO (* Calculate U^TB. *)
         s := 0.0; 
         IF w^[j] <> 0.0 THEN (* Nonzero result only if wj is nonzero. *)
            FOR i := 0 TO m-1 DO 
               s := s+u^[i]^[j]*b^[i]
            END; 
            s := s/w^[j] (* This is the divide by wj. *)
         END; 
         tmp^[j] := s
      END; 
      FOR j := 0 TO n-1 DO (* Matrix multiply by V to get answer. *)
         s := 0.0; 
         FOR jj := 0 TO n-1 DO 
            s := s+v^[j]^[jj]*tmp^[jj]
         END; 
         x^[j] := s
      END; 
      DisposeVector(TMP);
   END SVBKSB; 

   PROCEDURE Sign(a, b: REAL): REAL; 
   BEGIN 
      IF b >= 0.0 THEN 
         RETURN ABS(a)
      ELSE 
         RETURN -ABS(a)
      END; 
   END Sign; 

   PROCEDURE Max(a, b: REAL): REAL; 
   BEGIN 
      IF a > b THEN 
         RETURN a
      ELSE 
         RETURN b
      END; 
   END Max; 

   PROCEDURE Pythag(a, b: REAL): REAL; 
   (*
     PYTHAG computes rta^2+b^2 without destructive overflow
     or underflow.
   *)
      VAR 
         at, bt: REAL; 
   BEGIN 
      at := ABS(a); 
      bt := ABS(b); 
      IF at > bt THEN 
         RETURN at*Sqrt(1.0+(bt/at)*(bt/at))
      ELSIF bt = 0.0 THEN 
         RETURN 0.0
      ELSE 
         RETURN bt*Sqrt(1.0+(at/bt)*(at/bt))
      END; 
   END Pythag; 

   PROCEDURE SVDCMP(A: Matrix; 
                    W: Vector; 
                    V: Matrix); 
      VAR 
         nm, l, k, j, jj, its, i, mnmin, length, nv, mv, n, m: INTEGER; 
         z, y, x, scale, s, h, g, f, c, anorm: REAL; 
         a, v: PtrToLines;
         w, rv1: PtrToReals;
         rv1V: Vector;
         flag: BOOLEAN;
   BEGIN 
      GetMatrixAttr(A, m, n, a);
      GetVectorAttr(W, length, w);
      CreateVector(n, rv1V, rv1); 
	   (*
	     Householder reduction to bidiagonal form.
	   *)
      GetMatrixAttr(V, nv, mv, v);
      g := 0.0; 
      scale := 0.0; 
      anorm := 0.0; 
      FOR i := 0 TO n-1 DO 
         l := i+1; 
         rv1^[i] := scale*g; 
         g := 0.0; 
         s := 0.0; 
         scale := 0.0; 
         IF i <= m-1 THEN 
            FOR k := i TO m-1 DO 
               scale := scale+ABS(a^[k]^[i])
            END; 
            IF scale <> 0.0 THEN 
               FOR k := i TO m-1 DO 
                  a^[k]^[i] := a^[k]^[i]/scale; 
                  s := s+a^[k]^[i]*a^[k]^[i]
               END; 
               f := a^[i]^[i]; 
               g := -Sign(Sqrt(s), f); 
               h := f*g-s; 
               a^[i]^[i] := f-g; 
               FOR j := l TO n-1 DO 
                  s := 0.0; 
                  FOR k := i TO m-1 DO 
                     s := s+a^[k]^[i]*a^[k]^[j]
                  END; 
                  f := s/h; 
                  FOR k := i TO m-1 DO 
                     a^[k]^[j] := a^[k]^[j]+f*a^[k]^[i]
                  END
               END; 
               FOR k := i TO m-1 DO 
                  a^[k]^[i] := scale*a^[k]^[i]
               END
            END
         END; 
         w^[i] := scale*g; 
         g := 0.0; 
         s := 0.0; 
         scale := 0.0; 
         IF (i <= m-1) AND (i <> n-1) THEN 
            FOR k := l TO n-1 DO 
               scale := scale+ABS(a^[i]^[k])
            END; 
            IF scale <> 0.0 THEN 
               FOR k := l TO n-1 DO 
                  a^[i]^[k] := a^[i]^[k]/scale; 
                  s := s+a^[i]^[k]*a^[i]^[k]
               END; 
               f := a^[i]^[l]; 
               g := -Sign(Sqrt(s), f); 
               h := f*g-s; 
               a^[i]^[l] := f-g; 
               FOR k := l TO n-1 DO 
                  rv1^[k] := a^[i]^[k]/h
               END; 
               FOR j := l TO m-1 DO 
                  s := 0.0; 
                  FOR k := l TO n-1 DO 
                     s := s+a^[j]^[k]*a^[i]^[k]
                  END; 
                  FOR k := l TO n-1 DO 
                    a^[j]^[k] := a^[j]^[k]+s*rv1^[k]
                  END
               END; 
               FOR k := l TO n-1 DO 
                  a^[i]^[k] := scale*a^[i]^[k]
               END
            END
         END; 
         anorm := Max(anorm, (ABS(w^[i])+ABS(rv1^[i])))
      END; 
	   (*
	     Accumulation of right-hand transformations.
	   *)
      FOR i := n-1 TO 0 BY -1 DO 
         IF i < n-1 THEN 
            IF g <> 0.0 THEN 
               FOR j := l TO n-1 DO 
                  v^[j]^[i] := (a^[i]^[j]/a^[i]^[l])/g (* Double division to avoid possible underflow: *)
               END; 
               FOR j := l TO n-1 DO 
                  s := 0.0; 
                  FOR k := l TO n-1 DO 
                     s := s+a^[i]^[k]*v^[k]^[j]
                  END; 
                  FOR k := l TO n-1 DO 
                     v^[k]^[j] := v^[k]^[j]+s*v^[k]^[i]
                  END
               END
            END; 
            FOR j := l TO n-1 DO 
               v^[i]^[j] := 0.0; 
               v^[j]^[i] := 0.0
            END
         END; 
         v^[i]^[i] := 1.0; 
         g := rv1^[i]; 
         l := i
      END; 
	   (*
	     Accumulation of left-hand transformations.
	   *)
      IF m < n THEN 
         mnmin := m-1
      ELSE 
         mnmin := n-1
      END; 
      FOR i := mnmin TO 0 BY -1 DO 
         l := i+1; 
         g := w^[i]; 
         FOR j := l TO n-1 DO 
            a^[i]^[j] := 0.0
         END; 
         IF g <> 0.0 THEN 
            g := 1.0/g; 
            FOR j := l TO n-1 DO 
               s := 0.0; 
               FOR k := l TO m-1 DO 
                  s := s+a^[k]^[i]*a^[k]^[j]
               END; 
               f := (s/a^[i]^[i])*g; 
               FOR k := i TO m-1 DO 
                  a^[k]^[j] := a^[k]^[j]+f*a^[k]^[i]
               END
            END; 
            FOR j := i TO m-1 DO 
               a^[j]^[i] := a^[j]^[i]*g
            END
         ELSE 
            FOR j := i TO m-1 DO 
               a^[j]^[i] := 0.0
            END
         END; 
         a^[i]^[i] := a^[i]^[i]+1.0
      END; 
	   (*
	     Diagonalization of the bidiagonal form.
	   *)
      FOR k := n-1 TO 0 BY -1 DO (* Loop over singular values. *)
         its := 1;
         LOOP
		   (*
		     Loop over allowed iterations.
		   *)
            IF its = 31 THEN EXIT END;
            flag := TRUE;
            l := k;
            LOOP (* Test for splitting: *)
               IF l = -1 THEN 
                  EXIT 
               END;
               nm := l-1; (* Note that rv1[1] is always zero. *)
               IF ABS(rv1^[l]) + anorm = anorm THEN 
                  flag := FALSE;
                  EXIT 
               END; 
               IF (ABS(w^[nm]) + anorm = anorm) THEN EXIT END;
               DEC(l);
            END; 
            IF flag  THEN
	            c := 0.0; (* Cancellation of rv1[l], if l>1 : *)
	            s := 1.0; 
	            i := l;
	            FOR i := l TO k DO 
	               f := s*rv1^[i]; 
	               IF (ABS(f) + anorm # anorm) THEN 
		               g := w^[i]; 
		               h := Pythag(f, g); 
		               w^[i] := h; 
		               h := 1.0/h; 
		               c := g*h; 
		               s := -f*h; 
		               FOR j := 0 TO m-1 DO 
		                  y := a^[j]^[nm]; 
		                  z := a^[j]^[i]; 
		                  a^[j]^[nm] := y*c+z*s; 
		                  a^[j]^[i] := -y*s+z*c
		               END;
	               END;
	            END; 
            END;
            z := w^[k]; 
            IF l = k THEN (* Convergence. *)
               IF z < 0.0 THEN 
				   (*
				     Singular value is made nonnegative.
				   *)
                  w^[k] := -z; 
                  FOR j := 0 TO n-1 DO 
                    v^[j]^[k] := -v^[j]^[k]
                  END
               END; 
               EXIT;
            END; 
            IF its = 30 THEN 
               Error('SVDCMP', 'No convergence in 30 iterations'); 
            END; 
            x := w^[l]; (* Shift from bottom 2-by-2 minor: *)
            nm := k-1; 
            y := w^[nm]; 
            g := rv1^[nm]; 
            h := rv1^[k]; 
            f := ((y-z)*(y+z)+(g-h)*(g+h))/(2.0*h*y); 
            g := Pythag(f, 1.0); 
            f := ((x-z)*(x+z)+h*((y/(f+Sign(g, f)))-h))/x; 
			   (*
			     Next QR transformation:
			   *)
            c := 1.0; 
            s := 1.0; 
            FOR j := l TO nm DO 
               i := j+1; 
               g := rv1^[i]; 
               y := w^[i]; 
               h := s*g; 
               g := c*g; 
               z := Pythag(f, h); 
               rv1^[j] := z; 
               c := f/z; 
               s := h/z; 
               f := x*c+g*s; 
               g := -x*s+g*c; 
               h := y*s; 
               y := y*c; 
               FOR jj := 0 TO n-1 DO 
                  x := v^[jj]^[j]; 
                  z := v^[jj]^[i]; 
                  v^[jj]^[j] := x*c+z*s; 
                  v^[jj]^[i] := -x*s+z*c
               END; 
               z := Pythag(f, h); 
               w^[j] := z; (* Rotation can be arbitrary if z=0. *)
               IF z <> 0.0 THEN 
                  z := 1.0/z; 
                  c := f*z; 
                  s := h*z
               END; 
               f := c*g+s*y; 
               x := -s*g+c*y; 
               FOR jj := 0 TO m-1 DO 
                  y := a^[jj]^[j]; 
                  z := a^[jj]^[i]; 
                  a^[jj]^[j] := y*c+z*s; 
                  a^[jj]^[i] := -y*s+z*c
               END
            END; 
            rv1^[l] := 0.0; 
            rv1^[k] := f; 
            w^[k] := x;
            INC(its);
         END; 
      END; 
      DisposeVector(rv1V)
   END SVDCMP; 

END SVD.
