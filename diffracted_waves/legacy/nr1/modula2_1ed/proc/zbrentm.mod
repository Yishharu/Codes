IMPLEMENTATION MODULE ZBrentM;

   FROM NRMath   IMPORT RealFunction;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   PROCEDURE ZBrent(fx: RealFunction; x1, x2, tol: REAL): REAL; 
        CONST 
         itmax = 100; (* Maximum allowed
                         number of iterations, and machine floating point precision. *)
         eps = 3.0E-8; 
      VAR 
         a, b, c, d, e: REAL; 
         min1, min2, min: REAL; 
         fa, fb, fc, p, q, r: REAL; 
         s, tol1, xm: REAL; 
         iter: INTEGER; 
   BEGIN 
      a := x1; 
      b := x2; 
      fa := fx(a); 
      fb := fx(b); 
      IF fb*fa > 0.0 THEN 
         Error('ZBRENT', 'root must be bracketed'); 
      END; 
      fc := fb; 
      FOR iter := 1 TO itmax DO 
         IF fb*fc > 0.0 THEN 
            c := a; (* Rename a, b, c and adjust bounding 
                       interval d. *)
            fc := fa; 
            d := b-a; 
            e := d
         END; 
         IF ABS(fc) < ABS(fb) THEN 
            a := b; 
            b := c; 
            c := a; 
            fa := fb; 
            fb := fc; 
            fc := fa
         END; 
         tol1 := 2.0*eps*ABS(b)+0.5*tol; 
		   (*
		     Convergence check.
		   *)
         xm := 0.5*(c-b); 
         IF (ABS(xm) <= tol1) OR (fb = 0.0) THEN 
            RETURN b; 
         END; 
         IF (ABS(e) >= tol1) AND (ABS(fa) > ABS(fb)) THEN 
            s := fb/fa; (* Attempt inverse quadratic 
                           interpolation. *)
            IF a = c THEN 
               p := 2.0*xm*s; 
               q := 1.0-s
            ELSE 
               q := fa/fc; 
               r := fb/fc; 
               p := s*(2.0*xm*q*(q-r)-(b-a)*(r-1.0)); 
               q := (q-1.0)*(r-1.0)*(s-1.0)
            END; 
            IF p > 0.0 THEN q := -q END; (* Check whether in bounds. *)
            p := ABS(p); 
            min1 := 3.0*xm*q-ABS(tol1*q); 
            min2 := ABS(e*q); 
            IF min1 < min2 THEN 
               min := min1
            ELSE 
               min := min2
            END; 
            IF 2.0*p < min THEN 
               e := d; (* Accept interpolation. *)
               d := p/q
            ELSE 
               d := xm; (* Interpolation failed,
                           use bisection. *)
               e := d
            END
         ELSE (* Bounds decreasing too slowly, use bisection. *)
            d := xm; 
            e := d
         END; 
         a := b; (* Move last best guess to a. *)
         fa := fb; 
         IF ABS(d) > tol1 THEN 
		   (*
		     Evaluate new trial root.
		   *)
            b := b+d
         ELSE 
            IF xm >= Float(0) THEN 
               b := b+ABS(tol1)
            ELSE 
               b := b-ABS(tol1)
            END
         END; 
         fb := fx(b)
      END; 
      Error('ZBRENT', 'maximum number of iterations exceeded'); 
      RETURN b
   END ZBrent; 
END ZBrentM.
