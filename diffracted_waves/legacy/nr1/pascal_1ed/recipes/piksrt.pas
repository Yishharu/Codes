(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE piksrt(n: integer;
           VAR arr: RealArrayNP);
LABEL 10;
VAR
   j,i: integer;
   a: real;
BEGIN
   FOR j := 2 TO n DO BEGIN
      a := arr[j];
      FOR i := j-1 DOWNTO 1 DO BEGIN
         IF arr[i] <= a THEN GOTO 10;
         arr[i+1] := arr[i]
      END;
      i := 0;
10:   arr[i+1] := a
   END
END;
