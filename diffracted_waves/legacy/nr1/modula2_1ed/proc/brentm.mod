IMPLEMENTATION MODULE BrentM;

   FROM NRMath IMPORT RealFunction;
   FROM NRIO   IMPORT Error;

   PROCEDURE Brent(    ax, bx, cx:  REAL;
                       func:        RealFunction;
                       tol:         REAL; 
                   VAR xmin: REAL): REAL; 
      CONST 
         itmax = 100; (* Maximum allowed number of iterations; golden ratio; and
                         a small number which protects against trying to achieve 
                         fractional accuracy for a minimum that happens to be exactly 
                         zero. *)
         cgold = 0.3819660; 
         zeps = 1.0E-10; 
      VAR 
         a, b, d, e, etemp: REAL; 
         fu, fv, fw, fx: REAL; 
         iter: INTEGER; 
         p, q, r, tol1, tol2: REAL; 
         u, v, w, x, xm: REAL; 

      PROCEDURE sign(a, b: REAL): REAL; 
      BEGIN 
         IF b >= 0.0 THEN RETURN ABS(a)
         ELSE RETURN -ABS(a)
         END; 
      END sign; 

   BEGIN 
      IF ax < cx THEN a := ax ELSE a := cx END; (* a and b must be in ascending
                                                   order. The input abscissas 
                                                   need not be. *)
      IF ax > cx THEN b := ax ELSE b := cx END; 
      v := bx; (* Initializations... *)
      w := v; 
      x := v; 
      e := 0.0; (* This will be the distance moved on the step before last. *)
      fx := func(x); 
      fv := fx; 
      fw := fx; 
      FOR iter := 1 TO itmax DO (* Main program loop. *)
         xm := 0.5*(a+b); 
         tol1 := tol*ABS(x)+zeps; 
         tol2 := 2.0*tol1; 
         IF ABS(x-xm) <= tol2-0.5*(b-a) THEN 
		   (*
		     Test for done here.
		   *)
            xmin := x; 
            RETURN fx; 
         END; 
         IF ABS(e) > tol1 THEN (* Construct a trial parabolic fit. *)
            r := (x-w)*(fx-fv); 
            q := (x-v)*(fx-fw); 
            p := (x-v)*q-(x-w)*r; 
            q := 2.0*(q-r); 
            IF q > 0.0 THEN 
               p := (-p)
            END; 
            q := ABS(q); 
            etemp := e; 
            e := d; 
            IF (ABS(p) >= ABS(0.5*q*etemp)) OR (p <= q*(a-x)) OR (p >= q*(b-x)) THEN 
			   (*
			     The above conditions determine the acceptability of the
			     parabolic fit. Here we take a golden section step into
			     the larger of the two segments.
			   *)
               IF x >= xm THEN 
                  e := a-x
               ELSE 
                  e := b-x
               END; 
               d := cgold*e
            ELSE 
               d := p/q; (* Take the parabolic step. *)
               u := x+d; 
               IF (u-a < tol2) OR (b-u < tol2) THEN 
                  d := sign(tol1, xm-x)
               END
            END
         ELSE 
            IF x >= xm THEN (* We arrive here for a golden section step, which we
                               take into the larger of the two segments. *)
               e := a-x
            ELSE 
               e := b-x
            END; 
            d := cgold*e(* Take the golden section step. *)
         END; 
         IF ABS(d) >= tol1 THEN (* Arrive here with d computed either from 
                                   parabolic fit, or else from golden section. *)
            u := x+d
         ELSE 
            u := x+sign(tol1, d)
         END; 
         fu := func(u); (* The one function evaluation per iteration. *)
         IF fu <= fx THEN (* Now we have to decide what to do with our function 
                             evaluation. Housekeeping follows: *)
            IF u >= x THEN 
               a := x
            ELSE 
               b := x
            END; 
            v := w; 
            fv := fw; 
            w := x; 
            fw := fx; 
            x := u; 
            fx := fu
         ELSE 
            IF u < x THEN 
               a := u
            ELSE 
               b := u
            END; 
            IF (fu <= fw) OR (w = x) THEN 
               v := w; 
               fv := fw; 
               w := u; 
               fw := fu
            ELSIF (fu <= fv) OR (v = x) OR (v = w) THEN 
               v := u; 
               fv := fu
            END
         END(* Done with housekeeping. Back for another iteration. *)
      END; 
      Error('Brent', 'Too many iterations'); 
      xmin := x; (* Arrive here ready to exit with best values. *)
      RETURN fx; 
   END Brent; 

END BrentM.
