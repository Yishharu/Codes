(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
FUNCTION fnc(VAR p: RealArrayNP):real;
PROCEDURE dfnc(VAR p,g: RealArrayNP);
ENDENVIRON *)
PROCEDURE frprmn(VAR p: RealArrayNP;
                     n: integer;
                  ftol: real;
              VAR iter: integer;
              VAR fret: real);
LABEL 99;
CONST
   itmax = 200;
   eps = 1.0e-10;
VAR
   j,its: integer;
   gg,gam,fp,dgg: real;
   g,h,xi: ^RealArrayNP;
BEGIN
   new(g);
   new(h);
   new(xi);
   fp := fnc(p);
   dfnc(p,xi^);
   FOR j := 1 TO n DO BEGIN
      g^[j] := -xi^[j];
      h^[j] := g^[j];
      xi^[j] := h^[j]
   END;
   FOR its := 1 TO itmax DO BEGIN
      iter := its;
      linmin(p,xi^,n,fret);
      IF 2.0*abs(fret-fp) <= ftol*(abs(fret)+abs(fp)+eps) THEN GOTO 99;
      fp := fnc(p);
      dfnc(p,xi^);
      gg := 0.0;
      dgg := 0.0;
      FOR j := 1 TO n DO BEGIN
         gg := gg+sqr(g^[j]);
(*       dgg := dgg+sqr(xi^[j])  *)
         dgg := dgg+(xi^[j]+g^[j])*xi^[j]
      END;
      IF gg = 0.0 THEN GOTO 99;
      gam := dgg/gg;
      FOR j := 1 TO n DO BEGIN
         g^[j] := -xi^[j];
         h^[j] := g^[j]+gam*h^[j];
         xi^[j] := h^[j]
      END
   END;
   writeln('pause in routine FRPRMN');
   writeln('too many iterations');
   readln;
99:
   dispose(xi);
   dispose(h);
   dispose(g)
END;
