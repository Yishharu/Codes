(* BEGINENVIRON
CONST
   n2p =
   nvar =
TYPE
   RealArrayN2 = ARRAY [1..n2p] OF real;
   RealArrayNVAR = ARRAY [1..nvar] OF real;
   RealArrayN2byN2 = ARRAY [1..n2p,1..n2p] OF real;
   RealArrayNP = RealArrayN2;
   IntegerArrayNP = ARRAY [1..n2p] OF integer;
   RealArrayNPbyNP = RealArrayN2byN2;
PROCEDURE load(x1: real;
            VAR v: RealArrayN2;
            VAR y: RealArrayNVAR);
PROCEDURE score(x2: real;
             VAR y: RealArrayNVAR;
             VAR f: RealArrayN2);
BEGIN
   OdeintKmax := 0;
ENDENVIRON *)
PROCEDURE shoot(n: integer;
       VAR v,delv: RealArrayN2;
               n2: integer;
x1,x2,eps,h1,hmin: real;
         VAR f,dv: RealArrayN2);
VAR
   nok,nbad,iv,i: integer;
   sav,det: real;
   y: ^RealArrayNVAR;
   dfdv: ^RealArrayN2byN2;
   indx: ^IntegerArrayNP;
BEGIN
   new(y);
   new(dfdv);
   new(indx);
   load(x1,v,y^);
   odeint(y^,n,x1,x2,eps,h1,hmin,nok,nbad);
   score(x2,y^,f);
   FOR iv := 1 TO n2 DO BEGIN
      sav := v[iv];
      v[iv] := v[iv]+delv[iv];
      load(x1,v,y^);
      odeint(y^,n,x1,x2,eps,h1,hmin,nok,nbad);
      score(x2,y^,dv);
      FOR i := 1 TO n2 DO
         dfdv^[i,iv] := (dv[i]-f[i])/delv[iv];
      v[iv] := sav
   END;
   FOR iv := 1 TO n2 DO dv[iv] := -f[iv];
   ludcmp(dfdv^,n2,indx^,det);
   lubksb(dfdv^,n2,indx^,dv);
   FOR iv := 1 TO n2 DO
      v[iv] := v[iv] + dv[iv];
   dispose(indx);
   dispose(dfdv);
   dispose(y)
END;
