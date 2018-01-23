(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..n] OF real;
ENDENVIRON *)
PROCEDURE mdian2(VAR x: RealArrayNP;
                     n: integer;
              VAR xmed: real);
LABEL 99;
CONST
   big = 1.0e30;
   afac = 1.5;
   amp = 1.5;
VAR
   np,nm,j: integer;
   xx,xp,xm,sumx,sum,eps: real;
   stemp,dum,ap,am,aa,a: real;
BEGIN
   a := 0.5*(x[1]+x[n]);
   eps := abs(x[n]-x[1]);
   ap := big;
   am := -big;
   WHILE true DO BEGIN
      sum := 0.0;
      sumx := 0.0;
      np := 0;
      nm := 0;
      xp := big;
      xm := -big;
      FOR j := 1 TO n DO BEGIN
         xx := x[j];
         IF xx <> a THEN BEGIN
            IF xx > a THEN BEGIN
               np := np+1;
               IF xx < xp THEN xp := xx
            END
            ELSE IF xx < a THEN BEGIN
               nm := nm+1;
               IF xx > xm THEN xm := xx
            END;
            dum := 1.0/(eps+abs(xx-a));
            sum := sum+dum;
            sumx := sumx+xx*dum
         END
      END;
      stemp := (sumx/sum)-a;
      IF np-nm >= 2 THEN BEGIN
         am := a;
         IF stemp < 0.0 THEN
            aa := xp
         ELSE
            aa := xp+stemp*amp;
         IF aa > ap THEN
            aa := 0.5*(a+ap);
         eps := afac*abs(aa-a);
         a := aa
      END
      ELSE IF nm-np >= 2 THEN BEGIN
         ap := a;
         IF stemp > 0.0 THEN
            aa := xm
         ELSE
            aa := xm+stemp*amp;
         IF aa < am THEN
            aa := 0.5*(a+am);
         eps := afac*abs(aa-a);
         a := aa
      END
      ELSE BEGIN
         IF odd(n) THEN BEGIN
            IF np = nm THEN
               xmed := a
            ELSE IF np > nm THEN
               xmed := xp
            ELSE
               xmed := xm
         END
         ELSE BEGIN
            IF np = nm THEN
               xmed := 0.5*(xp+xm)
            ELSE IF np > nm THEN
               xmed := 0.5*(a+xp)
            ELSE
               xmed := 0.5*(xm+a)
         END;
         GOTO 99
      END
   END;
99:
END;
