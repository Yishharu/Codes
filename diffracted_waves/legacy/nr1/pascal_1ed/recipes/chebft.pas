(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
FUNCTION func(y: real): real;
ENDENVIRON *)
PROCEDURE chebft(a,b: real;
               VAR c: RealArrayNP;
                   n: integer);
CONST
   pi = 3.141592653589793;
VAR
   k,j: integer;
   y,fac,bpa,bma: real;
   sum: double;
   f: ^RealArrayNP;
BEGIN
   new(f);
   bma := 0.5*(b-a);
   bpa := 0.5*(b+a);
   FOR k := 1 TO n DO BEGIN
      y := cos(pi*(k-0.5)/n);
      f^[k] := func(y*bma+bpa)
   END;
   fac := 2.0/n;
   FOR j := 1 TO n DO BEGIN
      sum := 0.0;
      FOR k := 1 TO n DO
         sum := sum+f^[k]*cos(pi*(j-1)*(k-0.5)/n);
      c[j] := fac*sum
   END;
   dispose(f)
END;
