IMPLEMENTATION MODULE DBrentM;

   FROM NRMath IMPORT RealFunction;
   FROM NRIO   IMPORT Error;

   PROCEDURE DBrent(     ax, bx, cx: REAL;
                        func, dfunc: RealFunction;
                        tol:         REAL; 
                    VAR xmin: REAL): REAL; 
      CONST 
         itmax = 100; 
         zeps = 1.0E-10; 
      VAR 
         a, b, d, d1, d2: REAL; 
         du, dv, dw, dx: REAL; 
         e, fu, fv, fw, fx: REAL; 
         iter: INTEGER; 
         olde, tol1, tol2: REAL; 
         u, u1, u2, v, w, x, xm: REAL; 
         ok1, ok2: BOOLEAN; (* The oks will be used as flags for whether
                               proposed steps are acceptable or not. *)

      PROCEDURE sign(a, b: REAL): REAL; 
      BEGIN 
         IF b >= 0.0 THEN RETURN ABS(a)
         ELSE RETURN -ABS(a)
         END; 
      END sign; 

   (*
     Comments following will point out only differences from the
     routine Brent.  Read that routine first.
   *)
   BEGIN 
      IF ax < cx THEN 
         a := ax
      ELSE 
         a := cx
      END; 
      IF ax > cx THEN 
         b := ax
      ELSE 
         b := cx
      END; 
      v := bx; 
      w := v; 
      x := v; 
      e := 0.0; 
      fx := func(x); 
      fv := fx; 
      fw := fx; 
      dx := dfunc(x); (* Our housekeeping chores are doubled
                         by the necessity of handling derivative values as well as function
                         values. *)
      dv := dx; 
      dw := dx; 
      FOR iter := 1 TO itmax DO 
         xm := 0.5*(a+b); 
         tol1 := tol*ABS(x)+zeps; 
         tol2 := 2.0*tol1; 
         IF ABS(x-xm) <= tol2-0.5*(b-a) THEN 
		      xmin := x; 
		      RETURN fx; 
         END; 
         IF ABS(e) > tol1 THEN 
            d1 := 2.0*(b-a); (* Initialize these d's to an out-of-bracket value. *)
            d2 := d1; 
            IF dw <> dx THEN 
               d1 := (w-x)*dx/(dx-dw)(* Secant method, first on one, then on the other, point. *)
            END; 
            IF dv <> dx THEN 
               d2 := (v-x)*dx/(dx-dv)
				   (*
				     Which of the two estimates of d shall we take?  We will insist 
				     that they be within the bracket, and on the side pointed to by 
				     the derivative at x:
				   *)
            END; 
            u1 := x+d1; 
            u2 := x+d2; 
            ok1 := ((a-u1)*(u1-b) > 0.0) AND (dx*d1 <= 0.0); 
            ok2 := ((a-u2)*(u2-b) > 0.0) AND (dx*d2 <= 0.0); 
            olde := e; (* Movement on the step before last. *)
            e := d; 
            IF ok1 OR ok2 THEN (* Take only an acceptable d.  If both
                                  are acceptable, then take the smallest one. *)
               IF ok1 AND ok2 THEN 
                  IF ABS(d1) < ABS(d2) THEN 
              d := d1
                  ELSE 
              d := d2
                  END
               ELSIF ok1 THEN 
                  d := d1
               ELSE 
                  d := d2
               END; 
               IF ABS(d) <= ABS(0.5*olde) THEN 
                  u := x+d; 
                  IF (u-a < tol2) OR (b-u < tol2) THEN 
                     d := sign(tol1, xm-x)
                  END; 
               ELSE 
                  IF dx >= 0.0 THEN (* Determine which segment from the
                                       sign of the derivative. *)
                     e := a-x
                  ELSE 
                     e := b-x
                  END; 
                  d := 0.5*e (* Bisect, not golden section. *)
               END
            ELSE 
               IF dx >= 0.0 THEN 
                  e := a-x
               ELSE 
                  e := b-x
               END; 
               d := 0.5*e
            END
         ELSE 
            IF dx >= 0.0 THEN 
               e := a-x
            ELSE 
               e := b-x
            END; 
            d := 0.5*e
         END; 
         IF ABS(d) >= tol1 THEN 
            u := x+d; 
            fu := func(u)
         ELSE 
            u := x+sign(tol1, d); 
            fu := func(u); 
            IF fu > fx THEN (* If the minimum step in the downhill direction 
                               takes us uphill, then we are done. *)
			      xmin := x; 
			      RETURN fx; 
            END
         END; 
         du := dfunc(u); (* Now all the housekeeping, sigh. *)
         IF fu <= fx THEN 
            IF u >= x THEN 
               a := x
            ELSE 
               b := x
            END; 
            v := w; 
            fv := fw; 
            dv := dw; 
            w := x; 
            fw := fx; 
            dw := dx; 
            x := u; 
            fx := fu; 
            dx := du
         ELSE 
            IF u < x THEN 
               a := u
            ELSE 
               b := u
            END; 
            IF (fu <= fw) OR (w = x) THEN 
               v := w; 
               fv := fw; 
               dv := dw; 
               w := u; 
               fw := fu; 
               dw := du
                 ELSIF (fu < fv) OR (v = x) OR (v = w) THEN 
               v := u; 
               fv := fu; 
               dv := du
            END
         END
      END; 
      Error('DBrent', 'T oo many iterations'); 
      xmin := x; 
      RETURN fx; 
   END DBrent; 

END DBrentM.
