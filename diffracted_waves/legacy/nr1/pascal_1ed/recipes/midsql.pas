(* BEGINENVIRON
VAR
   MidsqlIt: integer;
FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE midsql(aa,bb: real;
                 VAR s: real;
                     n: integer);
VAR
   j: integer;
   x,tnm,sum,del,ddel,b,a: real;

FUNCTION funk(x: real): real;
BEGIN
   funk := 2.0*x*func(aa+sqr(x))
END;

BEGIN
   b := sqrt(bb-aa);
   a := 0.0;
   IF n = 1 THEN BEGIN
      s := (b-a)*funk(0.5*(a+b));
      MidsqlIt := 1
   END
   ELSE BEGIN
      tnm := MidsqlIt;
      del := (b-a)/(3.0*tnm);
      ddel := del+del;
      x := a+0.5*del;
      sum := 0.0;
      FOR j := 1 TO MidsqlIt DO BEGIN
         sum := sum+funk(x);
         x := x+ddel;
         sum := sum+funk(x);
         x := x+del
      END;
      s := (s+(b-a)*sum/tnm)/3.0;
      MidsqlIt := 3*MidsqlIt
   END
END;
