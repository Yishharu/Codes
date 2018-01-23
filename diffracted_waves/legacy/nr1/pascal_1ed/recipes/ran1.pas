(* BEGINENVIRON
VAR
   Ran1Ix1,Ran1Ix2,Ran1Ix3: longint;
   Ran1R: ARRAY [1..97] OF real;
ENDENVIRON *)
FUNCTION ran1(VAR idum: integer): real;
CONST
   m1 = 259200;
   ia1 = 7141;
   ic1 = 54773;
   rm1 = 3.8580247e-6;
   m2 = 134456;
   ia2 = 8121;
   ic2 = 28411;
   rm2 = 7.4373773e-6;
   m3 = 243000;
   ia3 = 4561;
   ic3 = 51349;
VAR
   j: integer;
BEGIN
   IF idum < 0 THEN BEGIN
      Ran1Ix1 := (ic1-idum) MOD m1;
      Ran1Ix1 := (ia1*Ran1Ix1+ic1) MOD m1;
      Ran1Ix2 := Ran1Ix1 MOD m2;
      Ran1Ix1 := (ia1*Ran1Ix1+ic1) MOD m1;
      Ran1Ix3 := Ran1Ix1 MOD m3;
      FOR j := 1 TO 97 DO BEGIN
         Ran1Ix1 := (ia1*Ran1Ix1+ic1) MOD m1;
         Ran1Ix2 := (ia2*Ran1Ix2+ic2) MOD m2;
         Ran1R[j] := (Ran1Ix1+Ran1Ix2*rm2)*rm1
      END;
      idum := 1
   END;
   Ran1Ix1 := (ia1*Ran1Ix1+ic1) MOD m1;
   Ran1Ix2 := (ia2*Ran1Ix2+ic2) MOD m2;
   Ran1Ix3 := (ia3*Ran1Ix3+ic3) MOD m3;
   j := 1 + (97*Ran1Ix3) DIV m3;
   IF (j > 97) OR (j < 1) THEN BEGIN
      writeln('pause in routine RAN1');
      readln
   END;
   ran1 := Ran1R[j];
   Ran1R[j] := (Ran1Ix1+Ran1Ix2*rm2)*rm1
END;
