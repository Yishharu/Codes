(* BEGINENVIRON
VAR
   Ran3Inext,Ran3Inextp: integer;
   Ran3Ma: ARRAY [1..55] OF real;
ENDENVIRON *)
FUNCTION ran3(VAR idum: integer): real;
(* CONST
      mbig = 1000000000;  mseed=161803398;  mz=0;  fac=1.0e-9;
VAR
      i,ii,k,mj,mk: longint; *)
CONST
   mbig = 4.0e6;
   mseed = 1618033.0;
   mz = 0.0;
   fac = 2.5e-7;
VAR
   i,ii,k: integer;
   mj,mk: real;
BEGIN
   IF idum < 0 THEN BEGIN
      mj := mseed+idum;
      IF mj >= 0.0 THEN
         mj := mj-mbig*trunc(mj/mbig)
      ELSE
         mj := mbig-abs(mj)+mbig*trunc(abs(mj)/mbig);
(*    mj := mj MOD mbig; *)
      Ran3Ma[55] := mj;
      mk := 1;
      FOR i := 1 TO 54 DO BEGIN
         ii := 21*i MOD 55;
         Ran3Ma[ii] := mk;
         mk := mj-mk;
         IF mk < mz THEN mk := mk+mbig;
         mj := Ran3Ma[ii]
      END;
      FOR k := 1 TO 4 DO BEGIN
         FOR i := 1 TO 55 DO BEGIN
            Ran3Ma[i] := Ran3Ma[i]-Ran3Ma[1+((i+30) MOD 55)];
            IF Ran3Ma[i] < mz THEN Ran3Ma[i] := Ran3Ma[i]+mbig
         END
      END;
      Ran3Inext := 0;
      Ran3Inextp := 31;
      idum := 1
   END;
   Ran3Inext := Ran3Inext+1;
   IF Ran3Inext = 56 THEN
      Ran3Inext := 1;
   Ran3Inextp := Ran3Inextp+1;
   IF Ran3Inextp = 56 THEN Ran3Inextp := 1;
   mj := Ran3Ma[Ran3Inext]
            -Ran3Ma[Ran3Inextp];
   IF mj < mz THEN mj := mj+mbig;
   Ran3Ma[Ran3Inext] := mj;
   ran3 := mj*fac
END;
