(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE polint(VAR xa,ya: RealArrayNP;
                         n: integer;
                         x: real;
                  VAR y,dy: real);
VAR
   ns,m,i: integer;
   w,hp,ho,dift,dif,den: real;
   c,d: ^RealArrayNP;
BEGIN
   new(c);
   new(d);
   ns := 1;
   dif := abs(x-xa[1]);
   FOR i := 1 TO n DO BEGIN
      dift := abs(x-xa[i]);
      IF dift < dif THEN BEGIN
         ns := i;
         dif := dift
      END;
      c^[i] := ya[i];
      d^[i] := ya[i]
   END;
   y := ya[ns];
   ns := ns-1;
   FOR m := 1 TO n-1 DO BEGIN
      FOR i := 1 TO n-m DO BEGIN
         ho := xa[i]-x;
         hp := xa[i+m]-x;
         w := c^[i+1]-d^[i];
         den := ho-hp;
         IF den = 0.0 THEN BEGIN
            writeln ('pause in routine POLINT');
            readln
         END;
         den := w/den;
         d^[i] := hp*den;
         c^[i] := ho*den
      END;
      IF 2*ns < n-m THEN
         dy := c^[ns+1]
      ELSE BEGIN
         dy := d^[ns];
         ns := ns-1
      END;
      y := y+dy
   END;
   dispose(d);
   dispose(c)
END;
