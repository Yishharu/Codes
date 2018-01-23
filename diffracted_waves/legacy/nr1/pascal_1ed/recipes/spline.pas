(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
ENDENVIRON *)
PROCEDURE spline(VAR x,y: RealArrayNP;
                       n: integer;
                 yp1,ypn: real;
                  VAR y2: RealArrayNP);
VAR
   i,k: integer;
   p,qn,sig,un: real;
   u: ^RealArrayNP;
BEGIN
   new(u);
   IF yp1 > 0.99e30 THEN BEGIN
      y2[1] := 0.0;
      u^[1] := 0.0
   END
   ELSE BEGIN
      y2[1] := -0.5;
      u^[1] := (3.0/(x[2]-x[1]))*((y[2]-y[1])/(x[2]-x[1])-yp1)
   END;
   FOR i := 2 TO n-1 DO BEGIN
      sig := (x[i]-x[i-1])/(x[i+1]-x[i-1]);
      p := sig*y2[i-1]+2.0;
      y2[i] := (sig-1.0)/p;
      u^[i] := (y[i+1]-y[i])/(x[i+1]-x[i])-(y[i]-y[i-1])/(x[i]-x[i-1]);
      u^[i] := (6.0*u^[i]/(x[i+1]-x[i-1])-sig*u^[i-1])/p
   END;
   IF ypn > 0.99e30 THEN BEGIN
      qn := 0.0;
      un := 0.0
   END
   ELSE BEGIN
      qn := 0.5;
      un := (3.0/(x[n]-x[n-1]))*(ypn-(y[n]-y[n-1])/(x[n]-x[n-1]))
   END;
   y2[n] := (un-qn*u^[n-1])/(qn*y2[n-1]+1.0);
   FOR k := n-1 DOWNTO 1 DO
      y2[k] := y2[k]*y2[k+1]+u^[k];
   dispose(u)
END;
