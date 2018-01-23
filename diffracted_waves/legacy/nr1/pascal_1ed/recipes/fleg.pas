(* BEGINENVIRON
CONST
   nlp =
TYPE
   RealArrayNL = ARRAY [1..nlp] OF real;
ENDENVIRON *)
PROCEDURE fleg(x: real;
          VAR pl: RealArrayNL;
              nl: integer);
VAR
   j: integer;
   twox,f2,f1,d: real;
BEGIN
   pl[1] := 1.0;
   pl[2] := x;
   IF nl > 2 THEN BEGIN
      twox := 2.0*x;
      f2 := x;
      d := 1.0;
      FOR j := 3 TO nl DO BEGIN
         f1 := d;
         f2 := f2+twox;
         d := d+1.0;
         pl[j] := (f2*pl[j-1]-f1*pl[j-2])/d
      END
   END
END;
