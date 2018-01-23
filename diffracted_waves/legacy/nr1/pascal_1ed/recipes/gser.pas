PROCEDURE gser(a,x: real;
    VAR gamser,gln: real);
LABEL 99;
CONST
   itmax = 100;
   eps = 3.0e-7;
VAR
   n: integer;
   sum,del,ap: real;
BEGIN
   gln := gammln(a);
   IF x <= 0.0 THEN BEGIN
      IF x < 0.0 THEN BEGIN
         writeln('pause in GSER - x less than 0');
         readln
      END;
      gamser := 0.0
   END
   ELSE BEGIN
      ap := a;
      sum := 1.0/a;
      del := sum;
      FOR n := 1 TO itmax DO BEGIN
         ap := ap+1.0;
         del := del*x/ap;
         sum := sum+del;
         IF abs(del) < abs(sum)*eps THEN GOTO 99
      END;
      writeln('pause in GSER - a too large, itmax too small');
      readln;
99:   gamser := sum*exp(-x+a*ln(x)-gln)
   END
END;
