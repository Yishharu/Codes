(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE ratint(VAR xa,ya: RealArrayNP;
                         n: integer;
                         x: real;
                  VAR y,dy: real);
LABEL 99;
CONST
   tiny = 1.0e-25;
VAR
   ns,m,i: integer;
   w,t,hh,h,dd: real;
   c,d: ^RealArrayNP;
BEGIN
   new(c);
   new(d);
   ns := 1;
   hh := abs(x-xa[1]);
   FOR i := 1 TO n DO BEGIN
      h := abs(x-xa[i]);
      IF h = 0.0 THEN BEGIN
         y := ya[i];
         dy := 0.0;
         GOTO 99
      END
      ELSE IF h < hh THEN BEGIN
         ns := i;
         hh := h
      END;
      c^[i] := ya[i];
      d^[i] := ya[i]+tiny
   END;
   y := ya[ns];
   ns := ns-1;
   FOR m := 1 TO n-1 DO BEGIN
      FOR i := 1 TO n-m DO BEGIN
         w := c^[i+1]-d^[i];
         h := xa[i+m]-x;
         t := (xa[i]-x)*d^[i]/h;
         dd := t-c^[i+1];
         IF dd = 0.0 THEN BEGIN
            writeln('pause in routine RATINT');
            readln
         END;
         dd := w/dd;
         d^[i] := c^[i+1]*dd;
         c^[i] := t*dd
      END;
      IF 2*ns < n-m THEN dy := c^[ns+1]
      ELSE BEGIN
         dy := d^[ns];
         ns := ns-1
      END;
      y := y+dy
   END;
99:
   dispose(d);
   dispose(c)
END;
