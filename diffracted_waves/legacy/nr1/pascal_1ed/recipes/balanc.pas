(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE balanc(VAR a: RealArrayNPbyNP;
                     n: integer);
CONST
   radix = 2.0;
VAR
   last,j,i: integer;
   s,r,g,f,c,sqrdx: real;
BEGIN
   sqrdx := sqr(radix);
   REPEAT
      last := 1;
      FOR i := 1 TO n DO BEGIN
         c := 0.0;
         r := 0.0;
         FOR j := 1 TO n DO
            IF j <> i THEN BEGIN
               c := c+abs(a[j,i]);
               r := r+abs(a[i,j])
            END;
         IF (c <> 0.0) AND (r <> 0.0) THEN BEGIN
            g := r/radix;
            f := 1.0;
            s := c+r;
            WHILE c < g DO BEGIN
               f := f*radix;
               c := c*sqrdx
            END;
            g := r*radix;
            WHILE c > g DO BEGIN
               f := f/radix;
               c := c/sqrdx
            END;
            IF (c+r)/f < 0.95*s THEN BEGIN
               last := 0;
               g := 1.0/f;
               FOR j := 1 TO n DO
                  a[i,j] := a[i,j]*g;
               FOR j := 1 TO n DO
                  a[j,i] := a[j,i]*f
            END
         END
      END;
   UNTIL last <> 0
END;
