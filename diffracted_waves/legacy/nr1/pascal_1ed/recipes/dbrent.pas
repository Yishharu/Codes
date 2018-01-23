(* BEGINENVIRON

FUNCTION func(x: real): real;
FUNCTION dfunc(x: real): real;
ENDENVIRON *)
FUNCTION dbrent(ax,bx,cx,tol: real;
                    VAR xmin: real): real;
LABEL 99;
CONST
   itmax = 100;
   zeps = 1.0e-10;
VAR
   a,b,d,d1,d2: real;
   du,dv,dw,dx: real;
   e,fu,fv,fw,fx: real;
   iter: integer;
   olde,tol1,tol2: real;
   u,u1,u2,v,w,x,xm: real;
   ok1,ok2: boolean;

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
   dx := dfunc(x);
   dv := dx;
   dw := dx;
   FOR iter := 1 TO itmax DO BEGIN
      xm := 0.5*(a+b);
      tol1 := tol*abs(x)+zeps;
      tol2 := 2.0*tol1;
      IF abs(x-xm) <= tol2-0.5*(b-a) THEN GOTO 99;
      IF abs(e) > tol1 THEN BEGIN
         d1 := 2.0*(b-a);
         d2 := d1;
         IF dw <> dx THEN
            d1 := (w-x)*dx/(dx-dw);
         IF dv <> dx THEN
            d2 := (v-x)*dx/(dx-dv);
         u1 := x+d1;
         u2 := x+d2;
         ok1 := ((a-u1)*(u1-b) > 0.0) AND (dx*d1 <= 0.0);
         ok2 := ((a-u2)*(u2-b) > 0.0) AND (dx*d2 <= 0.0);
         olde := e;
         e := d;
         IF ok1 OR ok2 THEN BEGIN
            IF ok1 AND ok2 THEN
               IF abs(d1) < abs(d2) THEN
                  d := d1
               ELSE
                  d := d2
            ELSE IF ok1 THEN
               d := d1
            ELSE
               d := d2;
            IF abs(d) <= abs(0.5*olde) THEN BEGIN
               u := x+d;
               IF (u-a < tol2) OR (b-u < tol2) THEN
                  d := sign(tol1,xm-x);
            END
            ELSE BEGIN
               IF dx >= 0.0 THEN
                  e := a-x
               ELSE
                  e := b-x;
               d := 0.5*e
            END
         END
         ELSE BEGIN
            IF dx >= 0.0 THEN
               e := a-x
            ELSE
               e := b-x;
            d := 0.5*e
         END
      END
      ELSE BEGIN
         IF dx >= 0.0 THEN
            e := a-x
         ELSE
            e := b-x;
         d := 0.5*e
      END;
      IF abs(d) >= tol1 THEN BEGIN
         u := x+d;
         fu := func(u)
      END
      ELSE BEGIN
         u := x+sign(tol1,d);
         fu := func(u);
         IF fu > fx THEN GOTO 99
      END;
      du := dfunc(u);
      IF fu <= fx THEN BEGIN
         IF u >= x THEN a := x ELSE b := x;
         v := w;
         fv := fw;
         dv := dw;
         w := x;
         fw := fx;
         dw := dx;
         x := u;
         fx := fu;
         dx := du
      END
      ELSE BEGIN
         IF u < x THEN a := u ELSE b := u;
         IF (fu <= fw) OR (w = x) THEN BEGIN
            v := w;
            fv := fw;
            dv := dw;
            w := u;
            fw := fu;
            dw := du
         END
         ELSE IF (fu < fv) OR (v = x) OR (v = w) THEN BEGIN
            v := u;
            fv := fu;
            dv := du
         END
      END
   END;
   writeln('pause in routine DBRENT - too many iterations');
99:
   xmin := x;
   dbrent := fx
END;
