PROCEDURE gcf(a,x: real;
   VAR gammcf,gln: real);
LABEL 99;
CONST
   itmax = 100;
   eps = 3.0e-7;
VAR
   n: integer;
   gold,g,fac,b1,b0,anf,ana,an,a1,a0: real;
BEGIN
   gln := gammln(a);
   gold := 0.0;
   a0 := 1.0;
   a1 := x;
   b0 := 0.0;
   b1 := 1.0;
   fac := 1.0;
   FOR n := 1 TO itmax DO BEGIN
      an := 1.0*n;
      ana := an-a;
      a0 := (a1+a0*ana)*fac;
      b0 := (b1+b0*ana)*fac;
      anf := an*fac;
      a1 := x*a0+anf*a1;
      b1 := x*b0+anf*b1;
      IF a1 <> 0.0 THEN BEGIN
         fac := 1.0/a1;
         g := b1*fac;
         IF abs((g-gold)/g) < eps THEN GOTO 99;
         gold := g
      END
   END;
   writeln('pause in GCF - a too large, itmax too small');
   readln;
99:
   gammcf := exp(-x+a*ln(x)-gln)*g
END;
