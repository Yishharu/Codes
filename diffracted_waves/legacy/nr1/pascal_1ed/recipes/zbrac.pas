(* BEGINENVIRON

FUNCTION fx(x: real): real;
ENDENVIRON *)
PROCEDURE zbrac(VAR x1,x2: real;
               VAR succes: boolean);
LABEL 99;
CONST
   factor = 1.6;
   ntry = 50;
VAR
   j: integer;
   f2,f1: real;
BEGIN
   IF x1 = x2 THEN BEGIN
      writeln('pause in routine ZBRAC');
      writeln('you have to guess an initial range');
      readln
   END;
   f1 := fx(x1);
   f2 := fx(x2);
   succes := true;
   FOR j := 1 TO ntry DO BEGIN
      IF f1*f2 < 0.0 THEN GOTO 99;
      IF abs(f1) < abs(f2) THEN BEGIN
         x1 := x1+factor*(x1-x2);
         f1 := fx(x1)
      END
      ELSE BEGIN
         x2 := x2+factor*(x2-x1);
         f2 := fx(x2)
      END
   END;
   succes := false;
99:
END;
