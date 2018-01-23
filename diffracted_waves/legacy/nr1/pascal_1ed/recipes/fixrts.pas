(* BEGINENVIRON
CONST
   npolesp =
   npolp1 =
TYPE
   RealArrayNPOLES = ARRAY [1..npolesp] OF real;
   Complex = RECORD
                r,i: real
             END;
   ComplexArrayMp1 = ARRAY [1..npolp1] OF Complex;
ENDENVIRON *)
PROCEDURE fixrts(VAR d: RealArrayNPOLES;
                npoles: integer);
VAR
   j,i: integer;
   size,dum: real;
   polish: boolean;
   a,roots: ComplexArrayMp1;
BEGIN
   a[npoles+1].r := 1.0;
   a[npoles+1].i := 0.0;
   FOR j := npoles DOWNTO 1 DO BEGIN
      a[j].r := -d[npoles+1-j];
      a[j].i := 0.0
   END;
   polish := true;
   zroots(a,npoles,roots,polish);
   FOR j := 1 TO npoles DO BEGIN
      size := sqr(roots[j].r)+sqr(roots[j].i);
      IF size > 1.0 THEN BEGIN
         roots[j].r := roots[j].r/size;
         roots[j].i := roots[j].i/size
      END
   END;
   a[1].r := -roots[1].r;
   a[1].i := -roots[1].i;
   a[2].r := 1.0;
   a[2].i := 0.0;
   FOR j := 2 TO npoles DO BEGIN
      a[j+1].r := 1.0;
      a[j+1].i := 0.0;
      FOR i := j DOWNTO 2 DO BEGIN
         dum := a[i].r;
         a[i].r := a[i-1].r-a[i].r*roots[j].r+a[i].i*roots[j].i;
         a[i].i := a[i-1].i-dum*roots[j].i-a[i].i*roots[j].r
      END;
      dum := a[1].r;
      a[1].r := -a[1].r*roots[j].r+a[1].i*roots[j].i;
      a[1].i := -dum*roots[j].i-a[1].i*roots[j].r
   END;
   FOR j := 1 TO npoles DO d[npoles+1-j] := -a[j].r
END;
