(* BEGINENVIRON
VAR
   PoidevOldm,PoidevSq,PoidevAlxm,PoidevG: real;
BEGIN
   PoidevOldm := -1.0;
ENDENVIRON *)
FUNCTION poidev(xm: real;
          VAR idum: integer): real;
CONST
   pi = 3.141592654;
VAR
   em,t,y: real;
BEGIN
   IF xm < 12.0 THEN BEGIN
      IF xm <> PoidevOldm THEN BEGIN
         PoidevOldm := xm;
         PoidevG := exp(-xm)
      END;
      em := -1;
      t := 1.0;
      REPEAT
         em := em+1.0;
         t := t*ran3(idum);
      UNTIL t <= PoidevG
   END
   ELSE BEGIN
      IF xm <> PoidevOldm THEN BEGIN
         PoidevOldm := xm;
         PoidevSq := sqrt(2.0*xm);
         PoidevAlxm := ln(xm);
         PoidevG := xm*PoidevAlxm
            -gammln(xm+1.0)
      END;
      REPEAT
         REPEAT
            y := pi*ran3(idum);
            y := sin(y)/cos(y);
            em := PoidevSq*y+xm;
         UNTIL em >= 0.0;
         em := trunc(em);
         t := 0.9*(1.0+sqr(y))*exp(em*PoidevAlxm-gammln(em+1.0)-PoidevG);
      UNTIL ran3(idum) <= t
   END;
   poidev := em
END;
