(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   IntegerArrayNP = ARRAY [1..np] OF integer;
ENDENVIRON *)
PROCEDURE indexx(n: integer;
         VAR arrin: RealArrayNP;
          VAR indx: IntegerArrayNP);
LABEL 99;
VAR
   l,j,ir,indxt,i: integer;
   q: real;
BEGIN
   FOR j := 1 TO n DO
      indx[j] := j;
   IF n = 1 THEN GOTO 99;
   l := (n DIV 2) + 1;
   ir := n;
   WHILE true DO BEGIN
      IF l > 1 THEN BEGIN
         l := l-1;
         indxt := indx[l];
         q := arrin[indxt]
      END
      ELSE BEGIN
         indxt := indx[ir];
         q := arrin[indxt];
         indx[ir] := indx[1];
         ir := ir-1;
         IF ir = 1 THEN BEGIN
            indx[1] := indxt;
            GOTO 99
         END
      END;
      i := l;
      j := l+l;
      WHILE j <= ir DO BEGIN
         IF j < ir THEN
            IF arrin[indx[j]] < arrin[indx[j+1]] THEN j := j+1;
         IF q < arrin[indx[j]] THEN BEGIN
            indx[i] := indx[j];
            i := j;
            j := j+j
         END
         ELSE
         j := ir+1
      END;
      indx[i] := indxt
   END;
99:
END;
