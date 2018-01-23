(* BEGINENVIRON
CONST
   np =
TYPE
   RealArrayNP = ARRAY [1..np] OF real;
   RealArrayNPbyNP = ARRAY [1..np,1..np] OF real;
FUNCTION fnc(VAR p: RealArrayNP):real;
PROCEDURE dfnc(VAR p,g: RealArrayNP);
ENDENVIRON *)
PROCEDURE dfpmin(VAR p: RealArrayNP;
                     n: integer;
                  ftol: real;
              VAR iter: integer;
              VAR fret: real);
LABEL 99;
CONST
   itmax = 200;
   eps = 1.0e-10;
VAR
   j,i,its: integer;
   fp,fae,fad,fac: real;
   xi,g,dg: ^RealArrayNP;
   hdg: ^RealArrayNP;
   hessin: ^RealArrayNPbyNP;
BEGIN
   new(xi);
   new(g);
   new(dg);
   new(hdg);
   new(hessin);
   fp := fnc(p);
   dfnc(p,g^);
   FOR i := 1 TO n DO BEGIN
      FOR j := 1 TO n DO hessin^[i,j] := 0.0;
      hessin^[i,i] := 1.0;
      xi^[i] := -g^[i]
   END;
   FOR its := 1 TO itmax DO BEGIN
      iter := its;
      linmin(p,xi^,n,fret);
      IF 2.0*abs(fret-fp) <= ftol*(abs(fret)+abs(fp)+eps) THEN GOTO 99;
      fp := fret;
      FOR i := 1 TO n DO dg^[i] := g^[i];
      fret := fnc(p);
      dfnc(p,g^);
      FOR i := 1 TO n DO
         dg^[i] := g^[i]-dg^[i];
      FOR i := 1 TO n DO BEGIN
         hdg^[i] := 0.0;
         FOR j := 1 TO n DO
            hdg^[i] := hdg^[i]+hessin^[i,j]*dg^[j]
      END;
      fac := 0.0;
      fae := 0.0;
      FOR i := 1 TO n DO BEGIN
         fac := fac+dg^[i]*xi^[i];
         fae := fae+dg^[i]*hdg^[i]
      END;
      fac := 1.0/fac;
      fad := 1.0/fae;
      FOR i := 1 TO n DO
         dg^[i] := fac*xi^[i]-fad*hdg^[i];
      FOR i := 1 TO n DO
         FOR j := 1 TO n DO
            hessin^[i,j] := hessin^[i,j]+fac*xi^[i]*xi^[j]
               -fad*hdg^[i]*hdg^[j]+fae*dg^[i]*dg^[j];
      FOR i := 1 TO n DO BEGIN
         xi^[i] := 0.0;
         FOR j := 1 TO n DO
            xi^[i] := xi^[i]-hessin^[i,j]*g^[j]
      END
   END;
   writeln('pause in routine DFPMIN');
   writeln('too many iterations');
   readln;
99:
   dispose(hessin);
   dispose(hdg);
   dispose(dg);
   dispose(g);
   dispose(xi)
END;
