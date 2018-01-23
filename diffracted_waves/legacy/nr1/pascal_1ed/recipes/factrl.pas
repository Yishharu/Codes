(* BEGINENVIRON
VAR
   FactrlNtop: integer;
   FactrlA: ARRAY [1..33] OF real;
BEGIN
   FactrlNtop := 0;
   FactrlA[1] := 1.0;
ENDENVIRON *)
FUNCTION factrl(n: integer): real;
VAR
   j: integer;
BEGIN
   IF n < 0 THEN BEGIN
      writeln('pause in FACTRL - negative factorial');
      readln
   END
   ELSE IF n <= FactrlNtop THEN
      factrl := FactrlA[n+1]
   ELSE IF n <= 32 THEN BEGIN
      FOR j := FactrlNtop+1 TO n DO
         FactrlA[j+1] := j*FactrlA[j];
      FactrlNtop := n;
      factrl := FactrlA[n+1]
   END
   ELSE factrl := exp(gammln(n+1.0))
END;
