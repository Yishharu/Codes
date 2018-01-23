(* BEGINENVIRON
CONST
   np =
TYPE
   DoubleArrayNP = ARRAY [1..np] OF double;
ENDENVIRON *)
PROCEDURE gauleg(x1,x2: double;
               VAR x,w: DoubleArrayNP;
                     n: integer);
CONST
   eps = 3.0e-11;
VAR
   m,j,i: integer;
   z1,z,xm,xl,pp,p3,p2,p1: double;
BEGIN
   m := (n+1) DIV 2;
   xm := 0.5*(x2+x1);
   xl := 0.5*(x2-x1);
   FOR i := 1 TO m DO BEGIN
      z := cos(3.141592654*(i-0.25)/(n+0.5));
      REPEAT
         p1 := 1.0;
         p2 := 0.0;
         FOR j := 1 TO n DO BEGIN
            p3 := p2;
            p2 := p1;
            p1 := ((2.0*j-1.0)*z*p2-(j-1.0)*p3)/j
         END;
         pp := n*(z*p1-p2)/(z*z-1.0);
         z1 := z;
         z := z1-p1/pp;
      UNTIL abs(z-z1) <= eps;
      x[i] := xm-xl*z;
      x[n+1-i] := xm+xl*z;
      w[i] := 2.0*xl/((1.0-z*z)*pp*pp);
      w[n+1-i] := w[i]
   END
END;
