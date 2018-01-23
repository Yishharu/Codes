(* BEGINENVIRON

FUNCTION func(x: real): real;
ENDENVIRON *)
FUNCTION golden(ax,bx,cx,tol: real;
                    VAR xmin: real): real;
CONST
   r = 0.61803399;
VAR
   f1,f2,c: real;
   x0,x1,x2,x3: real;
BEGIN
   c := 1.0-r;
   x0 := ax;
   x3 := cx;
   IF abs(cx-bx) > abs(bx-ax) THEN BEGIN
      x1 := bx;
      x2 := bx+c*(cx-bx)
   END
   ELSE BEGIN
      x2 := bx;
      x1 := bx-c*(bx-ax)
   END;
   f1 := func(x1);
   f2 := func(x2);
   WHILE abs(x3-x0) > tol*(abs(x1)+abs(x2)) DO BEGIN
      IF f2 < f1 THEN BEGIN
         x0 := x1;
         x1 := x2;
         x2 := r*x1+c*x3;
         f1 := f2;
         f2 := func(x2)
      END
      ELSE BEGIN
         x3 := x2;
         x2 := x1;
         x1 := r*x2+c*x0;
         f2 := f1;
         f1 := func(x1)
      END
   END;
   IF f1 < f2 THEN BEGIN
      golden := f1;
      xmin := x1
   END
   ELSE BEGIN
      golden := f2;
      xmin := x2
   END
END;
