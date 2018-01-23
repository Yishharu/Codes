(* BEGINENVIRON
CONST
   np =
   mp =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
   RealArrayNPbyMP = ARRAY [1..np,1..mp] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
ENDENVIRON *)
PROCEDURE gaussj(VAR a: RealArrayNPbyNP;
                     n: integer;
                 VAR b: RealArrayNPbyMP;
                     m: integer);
VAR
   big,dum,pivinv: real;
   i,icol,irow,j,k,l,ll: integer;
   indxc,indxr,ipiv: ^IntegerArrayNP;
BEGIN
   new(indxc);
   new(indxr);
   new(ipiv);
   FOR j := 1 TO n DO ipiv^[j] := 0;
   FOR i := 1 TO n DO BEGIN
      big := 0.0;
      FOR j := 1 TO n DO
         IF ipiv^[j] <> 1 THEN
            FOR k := 1 TO n DO
               IF ipiv^[k] = 0 THEN
                  IF abs(a[j,k]) >= big THEN BEGIN
                     big := abs(a[j,k]);
                     irow := j;
                     icol := k
                  END
               ELSE IF ipiv^[k] > 1 THEN BEGIN
                  writeln('pause 1 in GAUSSJ - singular matrix');
                  readln
               END;
      ipiv^[icol] := ipiv^[icol]+1;
      IF irow <> icol THEN BEGIN
         FOR l := 1 TO n DO BEGIN
            dum := a[irow,l];
            a[irow,l] := a[icol,l];
            a[icol,l] := dum
         END;
         FOR l := 1 TO m DO BEGIN
            dum := b[irow,l];
            b[irow,l] := b[icol,l];
            b[icol,l] := dum
         END
      END;
      indxr^[i] := irow;
      indxc^[i] := icol;
      IF a[icol,icol] = 0.0 THEN BEGIN
         writeln('pause 2 in GAUSSJ - singular matrix');
         readln
      END;
      pivinv := 1.0/a[icol,icol];
      a[icol,icol] := 1.0;
      FOR l := 1 TO n DO
         a[icol,l] := a[icol,l]*pivinv;
      FOR l := 1 TO m DO
         b[icol,l] := b[icol,l]*pivinv;
      FOR ll := 1 TO n DO
         IF ll <> icol THEN BEGIN
            dum := a[ll,icol];
            a[ll,icol] := 0.0;
            FOR l := 1 TO n DO
               a[ll,l] := a[ll,l]-a[icol,l]*dum;
            FOR l := 1 TO m DO
               b[ll,l] := b[ll,l]-b[icol,l]*dum
         END
   END;
   FOR l := n DOWNTO 1 DO
      IF indxr^[l] <> indxc^[l] THEN
         FOR k := 1 TO n DO BEGIN
            dum := a[k,indxr^[l]];
            a[k,indxr^[l]] := a[k,indxc^[l]];
            a[k,indxc^[l]] := dum
         END;
   dispose(ipiv);
   dispose(indxr);
   dispose(indxc)
END;
