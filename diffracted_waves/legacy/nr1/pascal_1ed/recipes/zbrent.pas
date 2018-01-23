(* BEGINENVIRON

FUNCTION fx(x: real): real;
ENDENVIRON *)
FUNCTION zbrent(x1,x2,tol: real): real;
LABEL 99;
CONST
   itmax = 100;
   eps = 3.0e-8;
VAR
   a,b,c,d,e: real;
   min1,min2,min: real;
   fa,fb,fc,p,q,r: real;
   s,tol1,xm: real;
   iter: integer;
BEGIN
   a := x1;
   b := x2;
   fa := fx(a);
   fb := fx(b);
   IF fb*fa > 0.0 THEN BEGIN
      writeln('pause in routine ZBRENT');
      writeln('root must be bracketed');
      readln
   END;
   fc := fb;
   FOR iter := 1 TO itmax DO BEGIN
      IF fb*fc > 0.0 THEN BEGIN
         c := a;
         fc := fa;
         d := b-a;
         e := d
      END;
      IF abs(fc) < abs(fb) THEN BEGIN
         a := b;
         b := c;
         c := a;
         fa := fb;
         fb := fc;
         fc := fa
      END;
      tol1 := 2.0*eps*abs(b)+0.5*tol;
      xm := 0.5*(c-b);
      IF (abs(xm) <= tol1) OR (fb = 0.0) THEN BEGIN
         zbrent := b;
         GOTO 99
      END;
      IF (abs(e) >= tol1) AND (abs(fa) > abs(fb)) THEN BEGIN
         s := fb/fa;
         IF a = c THEN BEGIN
            p := 2.0*xm*s;
            q := 1.0-s
         END
         ELSE BEGIN
            q := fa/fc;
            r := fb/fc;
            p := s*(2.0*xm*q*(q-r)-(b-a)*(r-1.0));
            q := (q-1.0)*(r-1.0)*(s-1.0)
         END;
         IF p > 0.0 THEN q := -q;
         p := abs(p);
         min1 := 3.0*xm*q-abs(tol1*q);
         min2 := abs(e*q);
         IF min1 < min2 THEN min := min1 ELSE min := min2;
         IF 2.0*p < min THEN BEGIN
            e := d;
            d := p/q
         END
         ELSE BEGIN
            d := xm;
            e := d
         END
      END
      ELSE BEGIN
         d := xm;
         e := d
      END;
      a := b;
      fa := fb;
      IF abs(d) > tol1 THEN b := b+d
      ELSE BEGIN
         IF xm >= 0 THEN b := b+abs(tol1)
         ELSE b := b-abs(tol1)
      END;
      fb := fx(b)
   END;
   writeln('pause in routine ZBRENT');
   writeln('maximum number of iterations exceeded');
   readln;
   zbrent := b;
99:
END;
