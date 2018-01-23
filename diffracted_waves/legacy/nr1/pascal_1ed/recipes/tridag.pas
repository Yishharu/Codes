(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE tridag(VAR a,b,c,r,u: RealArrayNP;
                             n: integer);
VAR
   j: integer;
   bet: real;
   gam: ^RealArrayNP;
BEGIN
   new(gam);
   IF b[1] = 0.0 THEN BEGIN
      writeln('pause 1 in TRIDAG');
      readln
   END;
   bet := b[1];
   u[1] := r[1]/bet;
   FOR j := 2 TO n DO BEGIN
      gam^[j] := c[j-1]/bet;
      bet := b[j]-a[j]*gam^[j];
      IF bet = 0.0 THEN BEGIN
         writeln('pause 2 in TRIDAG');
         readln
      END;
      u[j] := (r[j]-a[j]*u[j-1])/bet
   END;
   FOR j := n-1 DOWNTO 1 DO
      u[j] := u[j]-gam^[j+1]*u[j+1];
   dispose(gam)
END;
