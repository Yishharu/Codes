(* BEGINENVIRON
TYPE
   Immense = RECORD
                l,r: longint
             END;
   RealArray65 = ARRAY [1..65] OF real;
VAR
   Ran4Newkey: boolean;
   Ran4Inp,Ran4Key: Immense;
   Ran4Pow: RealArray65;
ENDENVIRON *)
FUNCTION ran4(VAR idum: integer): real;
CONST
   m = 11979;
   a = 430;
   c = 2531;
   nacc = 24;
   ib1 = 1;
   ib3 = 4;
   ib4 = 8;
   ib32 = $80000000;
   mask = ib1+ib3+ib4;
VAR
   isav,isav2: longint;
   j: integer;
   jot: ^Immense;
   r4: real;
BEGIN
   new(jot);
   IF idum < 0 THEN BEGIN
      idum := idum MOD m;
      IF idum < 0 THEN idum := idum+m;
      Ran4Pow[1] := 0.5;
      Ran4Key.l := 0;
      Ran4Key.r := 0;
      Ran4Inp.l := 0;
      Ran4Inp.r := 0;
      FOR j := 1 TO 64 DO BEGIN
         idum := (longint(idum)*a+c) MOD m;
         isav := 2*longint(idum) DIV m;
         IF isav = 1 THEN isav := ib32;
         isav2 := (4*longint(idum) DIV m) MOD 2;
         IF isav2 = 1 THEN isav2 := ib32;
         IF j <= 32 THEN BEGIN
            Ran4Key.r := (Ran4key.r SHR 1) OR isav;
            Ran4Inp.r := (Ran4Inp.r SHR 1) OR isav2;
         END ELSE
         BEGIN
            Ran4Key.l := (Ran4key.l SHR 1) OR isav;
            Ran4Inp.l := (Ran4Inp.l SHR 1) OR isav2
         END;
         Ran4Pow[j+1] := 0.5*Ran4Pow[j]
      END;
      Ran4Newkey := true
   END;
   isav := Ran4Inp.r AND ib32;
   IF isav <> 0 THEN isav := 1;
   IF Ran4Inp.l AND ib32 <> 0 THEN
      Ran4Inp.r := ((Ran4Inp.r XOR mask) SHL 1) OR ib1
   ELSE
      Ran4Inp.r := Ran4Inp.r SHL 1;
   Ran4Inp.l := (Ran4Inp.l SHL 1) OR isav;
   des(Ran4Inp,Ran4Key,Ran4Newkey,0,jot^);
   r4 := 0.0;
   FOR j := 1 TO nacc DO BEGIN
      IF jot^.r AND ib1 <> 0 THEN
         r4 := r4+Ran4Pow[j];
      jot^.r := jot^.r SHR 1
   END;
   ran4 := r4;
   dispose(jot)
END;
