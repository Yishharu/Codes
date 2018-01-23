(* BEGINENVIRON
VAR
   MidpntIt: integer;
FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE midpnt(a,b: real;
               VAR s: real;
                   n: integer);
VAR
   j: integer;
   x,tnm,sum,del,ddel: real;
BEGIN
   IF n = 1 THEN BEGIN
      s := (b-a)*func(0.5*(a+b));
      MidpntIt := 1
   END
   ELSE BEGIN
      tnm := MidpntIt;
      del := (b-a)/(3.0*tnm);
      ddel := del+del;
      x := a+0.5*del;
      sum := 0.0;
      FOR j := 1 TO MidpntIt DO BEGIN
         sum := sum+func(x);
         x := x+ddel;
         sum := sum+func(x);
         x := x+del
      END;
      s := (s+(b-a)*sum/tnm)/3.0;
      MidpntIt := 3*MidpntIt
   END
END;
