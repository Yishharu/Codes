(* BEGINENVIRON
VAR
   GasdevIset: integer;
   GasdevGset: real;
BEGIN
   GasdevIset := 0;
ENDENVIRON *)
FUNCTION gasdev(VAR idum: integer): real;
VAR
   fac,r,v1,v2: real;
BEGIN
   IF GasdevIset = 0 THEN BEGIN
      REPEAT
         v1 := 2.0*ran3(idum)-1.0;
         v2 := 2.0*ran3(idum)-1.0;
         r := sqr(v1)+sqr(v2);
      UNTIL (r < 1.0) AND (r > 0.0);
      fac := sqrt(-2.0*ln(r)/r);
      GasdevGset := v1*fac;
      gasdev := v2*fac;
      GasdevIset := 1
   END
   ELSE BEGIN
      GasdevIset := 0;
      gasdev := GasdevGset;
   END
END;
