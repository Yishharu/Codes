(* BEGINENVIRON
VAR
   FactlnA: ARRAY [1..100] OF real;
BEGIN
   FOR i := 1 TO 100 DO FactlnA[i] := -1.0;
ENDENVIRON *)
FUNCTION factln(n: integer): real;
BEGIN
   IF n < 0 THEN BEGIN
      writeln ('pause in FACTLN - negative factorial');
      readln
   END
   ELSE IF n <= 99 THEN BEGIN
      IF FactlnA[n+1] < 0.0 THEN
         FactlnA[n+1] := gammln(n+1.0);
      factln := FactlnA[n+1]
   END
   ELSE factln := gammln(n+1.0)
END;
