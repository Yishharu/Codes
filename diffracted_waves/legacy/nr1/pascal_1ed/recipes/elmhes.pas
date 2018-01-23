(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE elmhes(VAR a: RealArrayNPbyNP;
                     n: integer);
VAR
   m,j,i: integer;
   y,x: real;
BEGIN
   FOR m := 2 TO n-1 DO BEGIN
      x := 0.0;
      i := m;
      FOR j := m TO n DO BEGIN
         IF abs(a[j,m-1]) > abs(x) THEN BEGIN
            x := a[j,m-1];
            i := j
         END
      END;
      IF i <> m THEN BEGIN
         FOR j := m-1 TO n DO BEGIN
            y := a[i,j];
            a[i,j] := a[m,j];
            a[m,j] := y
         END;
         FOR j := 1 TO n DO BEGIN
            y := a[j,i];
            a[j,i] := a[j,m];
            a[j,m] := y
         END
      END;
      IF x <> 0.0 THEN BEGIN
         FOR i := m+1 TO n DO BEGIN
            y := a[i,m-1];
            IF y <> 0.0 THEN BEGIN
               y := y/x;
               a[i,m-1] := y;
               FOR j := m TO n DO
                  a[i,j] := a[i,j]-y*a[m,j];
               FOR j := 1 TO n DO
                  a[j,m] := a[j,m]+y*a[j,i]
            END
         END
      END
   END
END;
