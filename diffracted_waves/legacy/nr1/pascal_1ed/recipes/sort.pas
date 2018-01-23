(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE sort(n: integer;
          VAR ra: RealArrayNP);
LABEL 99;
VAR
   l,j,ir,i: integer;
   rra: real;
BEGIN
   l := (n DIV 2)+1;
   ir := n;
   WHILE true DO BEGIN
      IF l > 1 THEN BEGIN
         l := l-1;
         rra := ra[l]
      END
      ELSE BEGIN
         rra := ra[ir];
         ra[ir] := ra[1];
         ir := ir-1;
         IF ir = 1 THEN BEGIN
            ra[1] := rra;
            GOTO 99
         END
      END;
      i := l;
      j := l+l;
      WHILE j <= ir DO BEGIN
         IF j < ir THEN
         IF ra[j] < ra[j+1] THEN
            j := j+1;
         IF rra < ra[j] THEN BEGIN
            ra[i] := ra[j];
            i := j;
            j := j+j
         END
         ELSE
         j := ir+1
      END;
      ra[i] := rra
   END;
99:
END;
