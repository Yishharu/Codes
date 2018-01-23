(* BEGINENVIRON
VAR
   TrapzdIt: integer;
FUNCTION func(x: real): real;
ENDENVIRON *)
PROCEDURE trapzd(a,b: real;
               VAR s: real;
                   n: integer);
VAR
   j: integer;
   x,tnm,sum,del: real;
BEGIN
   IF n = 1 THEN BEGIN
      s := 0.5*(b-a)*(func(a)+func(b));
      TrapzdIt := 1
   END
   ELSE BEGIN
      tnm := TrapzdIt;
      del := (b-a)/tnm;
      x := a+0.5*del;
      sum := 0.0;
      FOR j := 1 TO TrapzdIt DO BEGIN
         sum := sum+func(x);
         x := x+del
      END;
      s := 0.5*(s+(b-a)*sum/tnm);
      TrapzdIt := 2*TrapzdIt
   END
END;
