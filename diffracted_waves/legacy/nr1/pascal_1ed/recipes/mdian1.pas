(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE mdian1(VAR x: RealArrayNP;
                     n: integer;
              VAR xmed: real);
VAR
   n2: integer;
BEGIN
   sort(n,x);
   n2 := n DIV 2;
   IF odd(n) THEN
      xmed := x[n2+1]
   ELSE
      xmed := 0.5*(x[n2]+x[n2+1])
END;
