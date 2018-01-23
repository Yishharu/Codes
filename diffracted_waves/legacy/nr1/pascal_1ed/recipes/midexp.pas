(* BEGINENVIRON
VAR
   MidexpIt: integer;
FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE midexp(aa,bb: real;
                 VAR s: real;
                     n: integer);
VAR
   j: integer;
   x,tnm,sum,del,ddel,b,a: real;

FUNCTION funk(x: real): real;
BEGIN
   funk := func(-log(x))/x
END;

BEGIN
   b := exp(-aa);
   a := 0.0
   IF n = 1 THEN BEGIN
      s := (b-a)*funk(0.5*(a+b));
      MidexpIt := 1
   END
   ELSE BEGIN
      tnm := MidexpIt;
      del := (b-a)/(3.0*tnm);
      ddel := del+del;
      x := a+0.5*del;
      sum := 0.0;
      FOR j := 1 TO MidexpIt DO BEGIN
         sum := sum+funk(x);
         x := x+ddel;
         sum := sum+funk(x);
         x := x+del
      END;
      s := (s+(b-a)*sum/tnm)/3.0;
      MidexpIt := 3*MidexpIt
   END
END;
