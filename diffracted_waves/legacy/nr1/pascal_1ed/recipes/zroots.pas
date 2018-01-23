(* BEGINENVIRON
CONST
   mp1 =
TYPE
   Complex = RECORD
                r,i: real
             END;
   ComplexArrayMp1 = ARRAY [1..mp1] OF Complex;
ENDENVIRON *)
PROCEDURE zroots(VAR a: ComplexArrayMp1;
                     m: integer;
             VAR roots: ComplexArrayMp1;
                polish: boolean);
LABEL 10;
CONST
   eps = 2.0e-6;
VAR
   jj,j,i: integer;
   dum: real;
   b,c,x: Complex;
   ad: ^ComplexArrayMp1;
BEGIN
   new(ad);
   FOR j := 1 TO m+1 DO
      ad^[j] := a[j];
   FOR j := m DOWNTO 1 DO BEGIN
      x.r := 0.0;
      x.i := 0.0;
      laguer(ad^,j,x,eps,false);
      IF abs(x.i) <= 2.0*sqr(eps)*abs(x.r) THEN x.i := 0.0;
      roots[j] := x;
      b := ad^[j+1];
      FOR jj := j DOWNTO 1 DO BEGIN
         c := ad^[jj];
         ad^[jj] := b;
         dum := b.r;
         b.r := b.r*x.r-b.i*x.i+c.r;
         b.i := dum*x.i+b.i*x.r+c.i
      END
   END;
   IF polish THEN BEGIN
      FOR j := 1 TO m DO
         laguer(a,m,roots[j],eps,true);
   END;
   FOR j := 2 TO m DO BEGIN
      x := roots[j];
      FOR i := j-1 DOWNTO 1 DO BEGIN
         IF roots[i].r <= x.r THEN GOTO 10;
         roots[i+1] := roots[i];
      END;
      i := 0;
10:   roots[i+1] := x;
   END;
   dispose(ad)
END;
