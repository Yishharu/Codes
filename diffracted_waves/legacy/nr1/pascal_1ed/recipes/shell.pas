(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE shell(n: integer;
          VAR arr: RealArrayNP);
LABEL 1;
CONST
   aln2i = 1.442695022;
   tiny = 1.0e-5;
VAR
   nn,m,lognb2,l,k,j,i: integer;
   t: real;
BEGIN
   lognb2 := trunc(ln(n)*aln2i+tiny);
   m := n;
   FOR nn := 1 TO lognb2 DO BEGIN
      m := m DIV 2;
      k := n-m;
      FOR j := 1 TO k DO BEGIN
         i := j;
1:       l := i+m;
         IF arr[l] < arr[i] THEN BEGIN
            t := arr[i];
            arr[i] := arr[l];
            arr[l] := t;
            i := i-m;
            IF i >= 1 THEN GOTO 1
         END
      END
   END
END;
