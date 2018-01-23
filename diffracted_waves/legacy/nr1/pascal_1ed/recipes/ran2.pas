(* BEGINENVIRON
VAR
   Ran2Iy: longint;
   Ran2Ir: ARRAY [1..97] OF longint;
ENDENVIRON *)
FUNCTION ran2(VAR idum: longint): real;
CONST
   m = 714025;
   ia = 1366;
   ic = 150889;
   rm = 1.4005112e-6;
VAR
   j: integer;
BEGIN
   IF idum < 0 THEN BEGIN
      idum := (ic-idum) MOD m;
      FOR j := 1 TO 97 DO BEGIN
         idum := (ia*idum+ic) MOD m;
         Ran2Ir[j] := idum
      END;
      idum := (ia*idum+ic) MOD m;
      Ran2Iy := idum
   END;
   j := 1 + (97*Ran2Iy) DIV m;
   IF (j > 97) OR (j < 1) THEN BEGIN
      writeln('pause in routine RAN2');
      readln
   END;
   Ran2Iy := Ran2Ir[j];
   ran2 := Ran2Iy*rm;
   idum := (ia*idum+ic) MOD m;
   Ran2Ir[j] := idum
END;
