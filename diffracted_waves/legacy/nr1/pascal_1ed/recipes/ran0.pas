(* BEGINENVIRON
VAR
   Ran0Y: real;
   Ran0V: ARRAY [1..97] OF real;
ENDENVIRON *)
FUNCTION ran0(VAR idum: integer): real;
VAR
   dum: real;
   j: integer;

BEGIN
   IF idum < 0 THEN BEGIN
      RandSeed := -idum;
      idum := 1;
      FOR j := 1 to 97 DO
         dum := Random;
      FOR j := 1 to 97 DO
         Ran0V[j] := Random;
      Ran0Y := Random;
   END;
   j := 1+trunc(97.0*Ran0Y);
   IF (j > 97) OR (j < 1) THEN BEGIN
      writeln('pause in routine RAN0');
      readln
   END;
   Ran0Y := Ran0V[j];
   ran0 := Ran0Y;
   Ran0V[j] := Random
END;
