(* BEGINENVIRON
CONST
   np =
TYPE
   IntegerArrayNP = ARRAY [1..np] OF integer;
FUNCTION equiv(i,j: integer): boolean;
ENDENVIRON *)
PROCEDURE eclazz(VAR nf: IntegerArrayNP;
                      n: integer);
VAR
   kk,jj: integer;
BEGIN
   nf[1] := 1;
   FOR jj := 2 TO n DO BEGIN
      nf[jj] := jj;
      FOR kk := 1 TO jj-1 DO BEGIN
         nf[kk] := nf[nf[kk]];
         IF equiv(jj,kk) THEN nf[nf[nf[kk]]] := jj
      END
   END;
   FOR jj := 1 TO n DO nf[jj] := nf[nf[jj]]
END;
