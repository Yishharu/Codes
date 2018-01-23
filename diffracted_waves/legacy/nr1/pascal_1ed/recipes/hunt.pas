(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE hunt(VAR xx: RealArrayNP;
                    n: integer;
                    x: real;
              VAR jlo: integer);
LABEL 1,99;
VAR
   jm,jhi,inc: integer;
   ascnd: boolean;
BEGIN
   ascnd := xx[n] > xx[1];
   IF (jlo <= 0) OR (jlo > n) THEN BEGIN
      jlo := 0;
      jhi := n+1
   END
   ELSE BEGIN
      inc := 1;
      IF (x >= xx[jlo]) = ascnd  THEN BEGIN
         IF jlo = n THEN GOTO 99;
         jhi := jlo+1;
         WHILE (x >= xx[jhi]) = ascnd DO BEGIN
            jlo := jhi;
            inc := inc+inc;
            jhi := jlo+inc;
            IF jhi > n THEN BEGIN
               jhi := n+1;
               GOTO 1
            END
         END
      END
      ELSE BEGIN
         IF jlo = 1 THEN BEGIN
            jlo := 0;
            GOTO 99
         END;
         jhi := jlo;
         jlo := jhi-1;
         WHILE (x < xx[jlo]) = ascnd  DO BEGIN
            jhi := jlo;
            inc := inc+inc;
            jlo := jhi-inc;
            IF jlo < 1 THEN BEGIN
               jlo := 0;
               GOTO 1
            END
         END
      END
   END;
1: WHILE jhi-jlo <> 1 DO BEGIN
      jm := (jhi+jlo) DIV 2;
      IF (x > xx[jm]) = ascnd  THEN jlo := jm
      ELSE jhi := jm
   END;
99:
END;
