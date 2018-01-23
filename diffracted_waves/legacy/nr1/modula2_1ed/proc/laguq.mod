IMPLEMENTATION MODULE LaguQ;

   FROM PolRat   IMPORT PolDiv;
   FROM NRMath   IMPORT Sqrt;
   FROM NRSystem IMPORT Float;
   FROM NRIO     IMPORT Error;

   FROM NRComp IMPORT
           Complex, CVector, DisposeCVector, CreateCVector, GetCVectorAttr, CVectorPtr, 
           NilCVector, PtrToComplexes;

   FROM NRVect IMPORT
           Vector, DisposeVector, PtrToReals, CreateVector, GetVectorAttr, 
           NilVector, VectorPtr;

   PROCEDURE CDiv(VAR a, b, c: Complex); 
   (*
     Complex division of a by b, answer in c. Routine avoids
     unnecessary overflow or underflow.
   *)
      VAR 
         t, den: REAL; 
   BEGIN 
      IF ABS(b.r) >= ABS(b.i) THEN 
         t := b.i/b.r; 
         den := b.r+t*b.i; 
         c.r := (a.r+a.i*t)/den; 
         c.i := (a.i-a.r*t)/den
      ELSE 
         t := b.r/b.i; 
         den := b.i+t*b.r; 
         c.r := (a.r*t+a.i)/den; 
         c.i := (a.i*t-a.r)/den
      END
   END CDiv; 

   PROCEDURE CAbs(VAR a: Complex): REAL; 
   (*
     Complex absolute value of a.  Routine avoids
     unnecessary overflow or underflow.
   *)
      VAR 
         x, y, result: REAL; 
   BEGIN 
      x := ABS(a.r); 
      y := ABS(a.i); 
      IF x = 0.0 THEN 
         result := y
      ELSIF y = 0.0 THEN 
         result := x
      ELSIF x > y THEN 
         result := x*Sqrt(1.0+(y/x)*(y/x))
      ELSE 
         result := y*Sqrt(1.0+(x/y)*(x/y))
      END; 
      RETURN result
   END CAbs; 

   PROCEDURE CSqrt(VAR a, b: Complex); 
   (*
     Returns complex square root of a in b.  Routine avoids
     unnecessary overflow or underflow.
   *)
      VAR 
         x, y, u, v, w, t: REAL; 
   BEGIN 
      IF (a.r = 0.0) AND (a.i = 0.0) THEN 
         u := 0.0; 
         v := 0.0
      ELSE 
         x := ABS(a.r); 
         y := ABS(a.i); 
         IF x >= y THEN 
            w := Sqrt(x)*Sqrt(0.5*(1.0+Sqrt(1.0+(y/x)*(y/x))))
         ELSE 
            t := x/y; 
            w := Sqrt(y)*Sqrt(0.5*(t+Sqrt(1.0+(t*t))))
         END; 
         IF a.r >= 0.0 THEN 
            u := w; 
            v := a.i/(2.0*u)
         ELSE 
            IF a.i >= 0.0 THEN 
               v := w
            ELSE 
               v := -w
            END; 
            u := a.i/(2.0*v)
         END
      END; 
      b.r := u; 
      b.i := v; 
   END CSqrt; 

   PROCEDURE Laguer(    A: CVector; 
                        m: INTEGER;
                    VAR x: Complex; 
                        eps: REAL; 
                        polish: BOOLEAN); 
     CONST 
         epss = 6.0E-8; 
         mxit = 100; 
      VAR 
         j, iter, mA: INTEGER; 
         err, dxold, cdx, abx, dum: REAL; 
         sq, h, gp, gm, g2, g,
         b, d, dx, f, x1, cdum: Complex; 
         a: PtrToComplexes;
   BEGIN 
      GetCVectorAttr(A, mA, a);
      dxold := CAbs(x); 
      FOR iter := 1 TO mxit DO (* Loop over iterations up to allowed maximum. *)
         b := a^[m]; 
         err := CAbs(b); 
         d.r := 0.0; 
         d.i := 0.0; 
         f.r := 0.0; 
         f.i := 0.0; 
         abx := CAbs(x); 
         FOR j := m-1 TO 0 BY -1 DO (* Efficient computation of the
                                       polynomial and its first two derivatives. *)
            dum := f.r; 
            f.r := x.r*f.r-x.i*f.i+d.r; 
            f.i := x.r*f.i+x.i*dum+d.i; 
            dum := d.r; 
            d.r := x.r*d.r-x.i*d.i+b.r; 
            d.i := x.r*d.i+x.i*dum+b.i; 
            dum := b.r; 
            b.r := x.r*b.r-x.i*b.i+a^[j].r; 
            b.i := x.r*b.i+x.i*dum+a^[j].i; 
            err := CAbs(b)+abx*err
         END; 
         err := epss*err; (* Estimate of polynomial roundoff error. *)
         IF CAbs(b) <= err THEN (* We are on the root. *)
            RETURN 
         END; 
         CDiv(d, b, g); (* The generic case: use Laguerre's formula. *)
         g2.r := g.r*g.r-g.i*g.i; 
         g2.i := 2.0*g.r*g.i; 
         CDiv(f, b, cdum); 
         h.r := g2.r-2.0*cdum.r; 
         h.i := g2.i-2.0*cdum.i; 
         cdum.r := Float(m-1)*(Float(m)*h.r-g2.r); 
         cdum.i := Float(m-1)*(Float(m)*h.i-g2.i); 
         CSqrt(cdum, sq); 
         gp.r := g.r+sq.r; 
         gp.i := g.i+sq.i; 
         gm.r := g.r-sq.r; 
         gm.i := g.i-sq.i; 
         IF CAbs(gp) < CAbs(gm) THEN 
            gp := gm
         END; 
         cdum.r := Float(m); 
         cdum.i := 0.0; 
         CDiv(cdum, gp, dx); 
         x1.r := x.r-dx.r; 
         x1.i := x.i-dx.i; 
         IF (x.r = x1.r) AND (x.i = x1.i) THEN (* Converged. *)
            RETURN 
         END; 
         x := x1; 
         cdx := CAbs(dx); 
         dxold := cdx; 
         IF  NOT polish THEN 
            IF cdx <= eps*CAbs(x) THEN (* Converged. *)
               RETURN 
            END
         END
      END; 
      Error('Laguer', 'Too many iterations.'); 
	   (*
	     Very unusual --- can only occur for complex roots. Try a different
	     starting guess for the root.
	   *)
   END Laguer; 

   PROCEDURE Qroot(    P: Vector; 
                   VAR b, c: REAL; 
                       eps: REAL); 
        CONST 
         itmax = 20; (* At most itmax iterations. *)
         tiny = 1.0E-6; 
      VAR 
         iter, i, n: INTEGER; 
         sc, sb, s, rc, rb, r, dv, delc, delb: REAL; 
         Q, QQ, REMM, D: Vector; 
         q, qq, rem, d, p: PtrToReals; 

   PROCEDURE DeallocateAll;
   BEGIN
      IF (Q # NilVector) THEN DisposeVector(Q) END;
      IF (QQ # NilVector) THEN DisposeVector(QQ) END;
      IF (REMM # NilVector) THEN DisposeVector(REMM) END;
      IF (D # NilVector) THEN DisposeVector(D) END;
   END DeallocateAll;

   BEGIN 
      GetVectorAttr(P, n, p);
      CreateVector(n, Q, q);
      CreateVector(n, QQ, qq);
      CreateVector(n, REMM, rem);
      CreateVector(3, D, d);
      IF (Q # NilVector) AND (QQ # NilVector) AND (REMM # NilVector) THEN
	      d^[2] := 1.0; 
	      FOR iter := 1 TO itmax DO 
	         d^[1] := b; 
	         d^[0] := c; 
	         PolDiv(P, D, Q, REMM); 
	         s := rem^[0]; (* First division r,s. *)
	         r := rem^[1]; 
	         PolDiv(Q, D, QQ, REMM); (* n-1 *)
	         sc := -rem^[0]; (* Second division partial r,s
                             with respect to c. *)
	         rc := -rem^[1]; 
	         FOR i := n-2 TO 0 BY -1 DO 
	            q^[i+1] := q^[i]
	         END; 
	         q^[0] := 0.0; 
	         PolDiv(Q, D, QQ, REMM); 
	         sb := -rem^[0]; (* Third division partial r,s
                             with respect to b. *)
	         rb := -rem^[1]; 
	         dv := 1.0/(sb*rc-sc*rb); 
			   (*
			     Solve 2x2 equation.
			   *)
	         delb := (r*sc-s*rc)*dv; 
	         delc := (-r*sb+s*rb)*dv; 
	         b := b+delb; 
	         c := c+delc; (* Coefficients converged? *)
	         IF 
	         ((ABS(delb) <= eps*ABS(b)) OR (ABS(b) < tiny)) AND ((ABS(delc) <= eps*ABS(c)) OR (ABS(c) < tiny)) THEN 
	            DeallocateAll;
	            RETURN;
	         END
	      END; 
	      Error('Qroot', 'Too many iterations'); 
	   ELSE
	      Error('Qroot', 'Not enough memory.');
	   END;
	   DeallocateAll;
   END Qroot; 

   PROCEDURE Zroots(A:      CVector;
                    m:      INTEGER;
                    ROOTS:  CVector; 
                    polish: BOOLEAN); 
      CONST 
         eps = 2.0E-6; (* Desired accuracy. *)
      VAR 
         jj, j, i, mA, mRoots: INTEGER; 
         dum: REAL; 
         b, c, x: Complex; 
         AD: CVector;
         ad, a, roots: PtrToComplexes; 
   BEGIN 
      GetCVectorAttr(A, mA, a);
      GetCVectorAttr(ROOTS, mRoots, roots);
      CreateCVector(m+1, AD, ad);
      IF AD # NilCVector THEN
	      FOR j := 0 TO m DO (* Copy of coefficients for successive deflation. *)
	         ad^[j] := a^[j]
	      END; 
	      FOR j := m-1 TO 0 BY -1 DO (* Loop over each root to be found. *)
	         x.r := 0.0; (* Start at zero to favor
                         convergence to smallest remaining root. *)
	         x.i := 0.0; 
	         Laguer(AD, j+1, x, eps, FALSE); (* Find the root. *)
	         IF ABS(x.i) <= 2.0*(eps*eps)*ABS(x.r) THEN 
	            x.i := 0.0
	         END; 
	         roots^[j] := x; 
	         b := ad^[j+1]; (* Forward deflation. *)
	         FOR jj := j TO 0 BY -1 DO 
	            c := ad^[jj]; 
	            ad^[jj] := b; 
	            dum := b.r; 
	            b.r := b.r*x.r-b.i*x.i+c.r; 
	            b.i := dum*x.i+b.i*x.r+c.i
	         END
	      END; 
	      IF polish THEN 
	         FOR j := 0 TO m-1 DO (* Polish the roots using the undeflated
                                  coefficients. *)
	            Laguer(A, m, roots^[j], eps, TRUE)
	         END; 
	      END; 
	      FOR j := 1 TO m-1 DO (* Sort roots by their real parts by straight
                               insertion. *)
	         x := roots^[j]; 
	         LOOP
		         FOR i := j-1 TO 0 BY -1 DO 
		            IF roots^[i].r <= x.r THEN 
		               EXIT; 
		            END; 
		            roots^[i+1] := roots^[i]; 
		         END; 
		         i := -1; 
		         EXIT;
		      END;
	         roots^[i+1] := x; 
	      END; 
	      DisposeCVector(AD);
	   ELSE
	      Error('Zroots', 'Not enough memory.');
	   END;
   END Zroots; 

END LaguQ.
