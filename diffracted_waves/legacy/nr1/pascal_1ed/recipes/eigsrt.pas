(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
ENDENVIRON *)
PROCEDURE eigsrt(VAR d: RealArrayNP;
                 VAR v: RealArrayNPbyNP;
                     n: integer);
VAR
   k,j,i: integer;
   p: real;
BEGIN
   FOR i := 1 TO n-1 DO BEGIN
      k := i;
      p := d[i];
      FOR j := i+1 TO n DO BEGIN
         IF d[j] >= p THEN BEGIN
            k := j;
            p := d[j]
         END
      END;
      IF k <> i THEN BEGIN
         d[k] := d[i];
         d[i] := p;
         FOR j := 1 TO n DO BEGIN
            p := v[j,i];
            v[j,i] := v[j,k];
            v[j,k] := p
         END
      END
   END
END;
