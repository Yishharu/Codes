(* BEGINENVIRON

FUNCTION func(x: real): real;
ENDENVIRON *)
FUNCTION brent(ax,bx,cx,tol: real;
                   VAR xmin: real): real;
LABEL 99;
CONST
   itmax = 100;
   cgold = 0.3819660;
   zeps = 1.0e-10;
VAR
   a,b,d,e,etemp: real;
   fu,fv,fw,fx: real;
   iter: integer;
   p,q,r,tol1,tol2: real;
   u,v,w,x,xm: real;

FUNCTION sign(a,b: real): real;
BEGIN
   IF b >= 0.0 THEN sign := abs(a) ELSE sign := -abs(a)
END;

BEGIN
   IF ax < cx THEN a := ax ELSE a := cx;
   IF ax > cx THEN b := ax ELSE b := cx;
   v := bx;
   w := v;
   x := v;
   e := 0.0;
   fx := func(x);
   fv := fx;
   fw := fx;
   FOR iter := 1 TO itmax DO BEGIN
      xm := 0.5*(a+b);
      tol1 := tol*abs(x)+zeps;
      tol2 := 2.0*tol1;
      IF abs(x-xm) <= tol2-0.5*(b-a) THEN GOTO 99;
      IF abs(e) > tol1 THEN BEGIN
         r := (x-w)*(fx-fv);
         q := (x-v)*(fx-fw);
         p := (x-v)*q-(x-w)*r;
         q := 2.0*(q-r);
         IF q > 0.0 THEN p := -p;
         q := abs(q);
         etemp := e;
         e := d;
         IF (abs(p) >= abs(0.5*q*etemp)) OR (p <= q*(a-x))
            OR (p >= q*(b-x)) THEN BEGIN
            IF x >= xm THEN
               e := a-x
            ELSE
               e := b-x;
            d := cgold*e
         END
         ELSE BEGIN
            d := p/q;
            u := x+d;
            IF (u-a < tol2) OR (b-u < tol2) THEN
               d := sign(tol1,xm-x)
         END
      END
      ELSE BEGIN
         IF x >= xm THEN
            e := a-x
         ELSE
            e := b-x;
         d := cgold*e
      END;
      IF abs(d) >= tol1 THEN
         u := x+d
      ELSE
         u := x+sign(tol1,d);
      fu := func(u);
      IF fu <= fx THEN BEGIN
         IF u >= x THEN a := x ELSE b := x;
         v := w;
         fv := fw;
         w := x;
         fw := fx;
         x := u;
         fx := fu
      END
      ELSE BEGIN
         IF u < x THEN a := u ELSE b := u;
         IF (fu <= fw) OR (w = x) THEN BEGIN
            v := w;
            fv := fw;
            w := u;
            fw := fu
         END
         ELSE IF (fu <= fv) OR (v = x) OR (v = w) THEN BEGIN
            v := u;
            fv := fu
         END
      END
   END;
   writeln('pause in routine BRENT - too many iterations');
99:
   xmin := x;
   brent := fx
END;
