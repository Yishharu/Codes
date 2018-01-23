(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE splint(VAR xa,ya,y2a: RealArrayNP;
                             n: integer;
                             x: real;
                         VAR y: real);
VAR
   klo,khi,k: integer;
   h,b,a: real;
BEGIN
   klo := 1;
   khi := n;
   WHILE khi-klo > 1 DO BEGIN
      k := (khi+klo) DIV 2;
      IF xa[k] > x THEN khi := k ELSE klo := k
   END;
   h := xa[khi]-xa[klo];
   IF h = 0.0 THEN BEGIN
      writeln ('pause in routine SPLINT');
      writeln (' ... bad XA input');
      readln
   END;
   a := (xa[khi]-x)/h;
   b := (x-xa[klo])/h;
   y := a*ya[klo]+b*ya[khi]+
         ((a*a*a-a)*y2a[klo]+(b*b*b-b)*y2a[khi])*(h*h)/6.0
END;
