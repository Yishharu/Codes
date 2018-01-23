(* BEGINENVIRON
CONST
   nbmax =
TYPE
   RealArrayNBMAX = ARRAY [1..nbmax] OF real;
FUNCTION fx(x: real): real;
ENDENVIRON *)
PROCEDURE zbrak(x1,x2: real;
                    n: integer;
          VAR xb1,xb2: RealArrayNBMAX;
               VAR nb: integer);
LABEL 99;
VAR
   nbb,i: integer;
   x,fp,fc,dx: real;
BEGIN
   nbb := nb;
   nb := 0;
   x := x1;
   dx := (x2-x1)/n;
   fp := fx(x);
   FOR i := 1 TO n DO BEGIN
      x := x+dx;
      fc := fx(x);
      IF fc*fp < 0.0 THEN BEGIN
         nb := nb+1;
         xb1[nb] := x-dx;
         xb2[nb] := x
      END;
      fp := fc;
      IF nbb = nb THEN GOTO 99;
   END;
99:
END;
