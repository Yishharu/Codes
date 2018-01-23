(* BEGINENVIRON
CONST
   n1p =
   n2p =
   nvar =
TYPE
   RealArrayN1 = ARRAY [1..n1p] OF real;
   RealArrayN2 = ARRAY [1..n2p] OF real;
   RealArrayNVAR = ARRAY [1..nvar] OF real;
   RealArrayNVARbyNVAR = ARRAY [1..nvar,1..nvar];
   RealArrayNP = RealArrayNVAR;
   IntegerArrayNP = ARRAY [1..nvar] OF integer;
   RealArrayNPbyNP = RealArrayNVARbyNVAR;
PROCEDURE load1(x1: real;
            VAR v1: RealArrayN2;
             VAR y: RealArrayNVAR);
PROCEDURE load2(x2: real;
            VAR v2: RealArrayN1;
             VAR y: RealArrayNVAR);
PROCEDURE score(xf: real;
           VAR y,f: RealArrayNVAR);
BEGIN
   OdeintKmax := 0;
ENDENVIRON *)
PROCEDURE shootf(n: integer;
            VAR v1: RealArrayN2;
            VAR v2: RealArrayN1;
         VAR delv1: RealArrayN2;
         VAR delv2: RealArrayN1;
             n1,n2: integer;
          x1,x2,xf: real;
       eps,h1,hmin: real;
             VAR f: RealArrayNVAR;
           VAR dv1: RealArrayN2;
           VAR dv2: RealArrayN1);
VAR
   nok,nbad,j,iv,i: integer;
   sav,det: real;
   y,f1,f2: ^RealArrayNVAR;
   dfdv: ^RealArrayNVARbyNVAR;
   indx: ^IntegerArrayNP;
BEGIN
   new(y);
   new(f1);
   new(f2);
   new(dfdv);
   new(indx);
   load1(x1,v1,y^);
   odeint(y^,n,x1,xf,eps,h1,hmin,nok,nbad);
   score(xf,y^,f1^);
   load2(x2,v2,y^);
   odeint(y^,n,x2,xf,eps,h1,hmin,nok,nbad);
   score(xf,y^,f2^);
   j := 0;
   FOR iv := 1 TO n2 DO BEGIN
      j := j+1;
      sav := v1[iv];
      v1[iv] := v1[iv]+delv1[iv];
      load1(x1,v1,y^);
      odeint(y^,n,x1,xf,eps,h1,hmin,nok,nbad);
      score(xf,y^,f);
      FOR i := 1 TO n DO
         dfdv^[i,j] := (f[i]-f1^[i])/delv1[iv];
      v1[iv] := sav
   END;
   FOR iv := 1 TO n1 DO BEGIN
      j := j+1;
      sav := v2[iv];
      v2[iv] := v2[iv]+delv2[iv];
      load2(x2,v2,y^);
      odeint(y^,n,x2,xf,eps,h1,hmin,nok,nbad);
      score(xf,y^,f);
      FOR i := 1 TO n DO
         dfdv^[i,j] := (f2^[i]-f[i])/delv2[iv];
      v2[iv] := sav
   END;
   FOR i := 1 TO n DO BEGIN
      f[i] := f1^[i]-f2^[i];
      f1^[i] := -f[i]
   END;
   ludcmp(dfdv^,n,indx^,det);
   lubksb(dfdv^,n,indx^,f1^);
   j := 0;
   FOR iv := 1 TO n2 DO BEGIN
      j := j+1;
      v1[iv] := v1[iv]+f1^[j];
      dv1[iv] := f1^[j]
   END;
   FOR iv := 1 TO n1 DO BEGIN
      j := j+1;
      v2[iv] := v2[iv]+f1^[j];
      dv2[iv] := f1^[j]
   END;
   dispose(indx);
   dispose(dfdv);
   dispose(f2);
   dispose(f1);
   dispose(y)
END;
