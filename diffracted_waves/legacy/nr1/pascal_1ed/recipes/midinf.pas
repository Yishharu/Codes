(* BEGINENVIRON
VAR
   MidinfIt: integer;
FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE midinf(aa,bb: real;
                 VAR s: real;
                     n: integer);
VAR
   j: integer;
   x,tnm,sum,del,ddel,b,a: real;

FUNCTION funk(x: real): real;
BEGIN
   funk := func(1.0/x)/sqr(x)
END;

BEGIN
   b := 1.0/aa;
   a := 1.0/bb;
   IF n = 1 THEN BEGIN
      s := (b-a)*funk(0.5*(a+b));
      MidinfIt := 1
   END
   ELSE BEGIN
      tnm := MidinfIt;
      del := (b-a)/(3.0*tnm);
      ddel := del+del;
      x := a+0.5*del;
      sum := 0.0;
      FOR j := 1 TO MidinfIt DO BEGIN
         sum := sum+funk(x);
         x := x+ddel;
         sum := sum+funk(x);
         x := x+del
      END;
      s := (s+(b-a)*sum/tnm)/3.0;
      MidinfIt := 3*MidinfIt
   END
END;
