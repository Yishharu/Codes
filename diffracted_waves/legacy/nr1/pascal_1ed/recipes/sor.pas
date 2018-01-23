(* BEGINENVIRON
CONST
   jmaxp =
TYPE
   DoubleArrayJMAXbyJMAX = ARRAY [1..jmaxp,1..jmaxp] OF double;
ENDENVIRON *)
PROCEDURE sor(VAR a,b,c,d,e,f,u: DoubleArrayJMAXbyJMAX;
                           jmax: integer;
                           rjac: double);
LABEL 99;
CONST
   maxits = 1000;
   eps = 1.0e-5;
VAR
   n,l,j: integer;
   resid,omega,anormf,anorm: double;
BEGIN
   anormf := 0.0;
   FOR j := 2 TO jmax-1 DO
      FOR l := 2 TO jmax-1 DO
         anormf := anormf+abs(f[j,l]);
   omega := 1.0;
   FOR n := 1 TO maxits DO BEGIN
      anorm := 0.0;
      FOR j := 2 TO jmax-1 DO
         FOR l := 2 TO jmax-1 DO
            IF odd(j+l) = odd(n) THEN BEGIN
               resid := a[j,l]*u[j+1,l]+b[j,l]*u[j-1,l]+c[j,l]*u[j,l+1]
                        +d[j,l]*u[j,l-1]+e[j,l]*u[j,l]-f[j,l];
               anorm := anorm+abs(resid);
               u[j,l] := u[j,l]-omega*resid/e[j,l]
            END;
      IF n = 1 THEN
         omega := 1.0/(1.0-0.5*sqr(rjac))
      ELSE
         omega := 1.0/(1.0-0.25*sqr(rjac)*omega);
      IF (n > 1) AND (anorm < eps*anormf) THEN GOTO 99
   END;
   writeln('pause in routine SOR');
   writeln('too many iterations');
   readln;
99:
END;
