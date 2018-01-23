(* BEGINENVIRON

FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE mnbrak(VAR ax,bx,cx,fa,fb,fc: real);
LABEL 99;
CONST
   gold = 1.618034;
   glimit = 100.0;
   tiny = 1.0e-20;
VAR
   ulim,u,r,q,fu,dum: real;

BEGIN
   fa := func(ax);
   fb := func(bx);
   IF fb > fa THEN BEGIN
      dum := ax;
      ax := bx;
      bx := dum;
      dum := fb;
      fb := fa;
      fa := dum
   END;
   cx := bx+gold*(bx-ax);
   fc := func(cx);
   WHILE fb >= fc DO BEGIN
      r := (bx-ax)*(fb-fc);
      q := (bx-cx)*(fb-fa);
      IF abs(q-r) > tiny THEN
         dum := abs(q-r)
      ELSE
         dum := tiny;
      IF q-r < 0.0 THEN dum := -dum;
      u := bx-((bx-cx)*q-(bx-ax)*r)/(2.0*dum);
      ulim := bx+glimit*(cx-bx);
      IF (bx-u)*(u-cx) > 0.0 THEN BEGIN
         fu := func(u);
         IF fu < fc THEN BEGIN
            ax := bx;
            fa := fb;
            bx := u;
            fb := fu;
            GOTO 99
         END
         ELSE IF fu > fb THEN BEGIN
            cx := u;
            fc := fu;
            GOTO 99
         END;
         u := cx+gold*(cx-bx);
         fu := func(u)
      END
      ELSE IF (cx-u)*(u-ulim) > 0.0 THEN BEGIN
         fu := func(u);
         IF fu < fc THEN BEGIN
            bx := cx;
            cx := u;
            u := cx+gold*(cx-bx);
            fb := fc;
            fc := fu;
            fu := func(u)
         END
      END
      ELSE IF (u-ulim)*(ulim-cx) >= 0.0 THEN BEGIN
         u := ulim;
         fu := func(u)
      END
      ELSE BEGIN
         u := cx+gold*(cx-bx);
         fu := func(u)
      END;
      ax := bx;
      bx := cx;
      cx := u;
      fa := fb;
      fb := fc;
      fc := fu
   END;
99:
END;
