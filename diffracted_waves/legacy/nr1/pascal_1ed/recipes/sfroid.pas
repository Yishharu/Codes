PROGRAM sfroid(input,output);
LABEL 99;
CONST
   ne = 3;
   m = 41;
   nb = 1;
   nyj = ne;
   nyk = m;
   nci = ne;
   ncj = 3;
   nck = 42;
   nsi = ne;
   nsj = 7;
TYPE
   RealArrayNYJbyNYK = ARRAY [1..nyj,1..nyk] OF real;
   RealArrayNCIbyNCJbyNCK = ARRAY [1..nci,1..ncj,1..nck] OF real;
   RealArrayNSIbyNSJ = ARRAY [1..nsi,1..nsj] OF real;
   RealArrayNYJ = ARRAY [1..nyj] OF real;
   IntegerArrayNYJ = ARRAY [1..nyj] OF integer;
VAR
   mm,n,i,itmax,k: integer;
   h,c2,norm,conv,deriv,fac1,fac2,q1,slowc: real;
   scalv: RealArrayNYJ;
   indexv: IntegerArrayNYJ;
   y: RealArrayNYJbyNYK;
   c: RealArrayNCIbyNCJbyNCK;
   s: RealArrayNSIbyNSJ;
   x: ARRAY [1..m] OF real;

PROCEDURE difeq(k,k1,k2,jsf,is1,isf: integer;
                         VAR indexv: IntegerArrayNYJ;
                                 ne: integer;
                              VAR s: RealArrayNSIbyNSJ;
                              VAR y: RealArrayNYJbyNYK);
VAR
   temp2,temp: real;
BEGIN
   IF k = k1 THEN BEGIN
      IF odd(n+mm) THEN BEGIN
         s[3,3+indexv[1]] := 1.0;
         s[3,3+indexv[2]] := 0.0;
         s[3,3+indexv[3]] := 0.0;
         s[3,jsf] := y[1,1]
      END
      ELSE BEGIN
         s[3,3+indexv[1]] := 0.0;
         s[3,3+indexv[2]] := 1.0;
         s[3,3+indexv[3]] := 0.0;
         s[3,jsf] := y[2,1]
      END
   END
   ELSE IF k > k2 THEN BEGIN
      s[1,3+indexv[1]] := -(y[3,m]-c2)/(2.0*(mm+1.0));
      s[1,3+indexv[2]] := 1.0;
      s[1,3+indexv[3]] := -y[1,m]/(2.0*(mm+1.0));
      s[1,jsf] := y[2,m]-(y[3,m]-c2)*y[1,m]/(2.0*(mm+1.0));
      s[2,3+indexv[1]] := 1.0;
      s[2,3+indexv[2]] := 0.0;
      s[2,3+indexv[3]] := 0.0;
      s[2,jsf] := y[1,m]-norm
   END
   ELSE BEGIN
      s[1,indexv[1]] := -1.0;
      s[1,indexv[2]] := -0.5*h;
      s[1,indexv[3]] := 0.0;
      s[1,3+indexv[1]] := 1.0;
      s[1,3+indexv[2]] := -0.5*h;
      s[1,3+indexv[3]] := 0.0;
      temp := h/(1.0-sqr(x[k]+x[k-1])*0.25);
      temp2 := 0.5*(y[3,k]+y[3,k-1])-c2*0.25*sqr(x[k]+x[k-1]);
      s[2,indexv[1]] := temp*temp2*0.5;
      s[2,indexv[2]] := -1.0-0.5*temp*(mm+1.0)*(x[k]+x[k-1]);
      s[2,indexv[3]] := 0.25*temp*(y[1,k]+y[1,k-1]);
      s[2,3+indexv[1]] := s[2,indexv[1]];
      s[2,3+indexv[2]] := 2.0+s[2,indexv[2]];
      s[2,3+indexv[3]] := s[2,indexv[3]];
      s[3,indexv[1]] := 0.0;
      s[3,indexv[2]] := 0.0;
      s[3,indexv[3]] := -1.0;
      s[3,3+indexv[1]] := 0.0;
      s[3,3+indexv[2]] := 0.0;
      s[3,3+indexv[3]] := 1.0;
      s[1,jsf] := y[1,k]-y[1,k-1]-0.5*h*(y[2,k]+y[2,k-1]);
      s[2,jsf] := y[2,k]-y[2,k-1]-temp*((x[k]+x[k-1])
         *0.5*(mm+1.0)*(y[2,k]+y[2,k-1])-temp2*0.5*(y[1,k]+y[1,k-1]));
      s[3,jsf] := y[3,k]-y[3,k-1]
   END
END;

(*$I PLGNDR.PAS *)

(*$I SOLVDE.PAS *)

BEGIN
   itmax := 100;
   c2 := 0.0;
   conv := 5.0e-6;
   slowc := 1.0;
   h := 1.0/(m-1);
   writeln('Enter m n');
   readln(mm,n);
   IF odd(n+mm) THEN BEGIN
      indexv[1] := 1;
      indexv[2] := 2;
      indexv[3] := 3
   END
   ELSE BEGIN
      indexv[1] := 2;
      indexv[2] := 1;
      indexv[3] := 3
   END;
   norm := 1.0;
   IF mm <> 0 THEN BEGIN
      q1 := n;
      FOR i := 1 TO mm DO BEGIN
         norm := -0.5*norm*(n+i)*(q1/i);
         q1 := q1-1.0
      END
   END;
   FOR k := 1 TO m-1 DO BEGIN
      x[k] := (k-1)*h;
      fac1 := 1.0-sqr(x[k]);
      fac2 := exp((-mm/2.0)*ln(fac1));
      y[1,k] := plgndr(n,mm,x[k])*fac2;
      deriv := -((n-mm+1)*plgndr(n+1,mm,x[k])-(n+1)*x[k]
                  *plgndr(n,mm,x[k]))/fac1;
      y[2,k] := mm*x[k]*y[1,k]/fac1+deriv*fac2;
      y[3,k] := n*(n+1)-mm*(mm+1)
   END;
   x[m] := 1.0;
   y[1,m] := norm;
   y[3,m] := n*(n+1)-mm*(mm+1);
   y[2,m] := (y[3,m]-c2)*y[1,m]/(2.0*(mm+1.0));
   scalv[1] := abs(norm);
   IF y[2,m] > abs(norm) THEN
      scalv[2] := y[2,m]
   ELSE
      scalv[2] := abs(norm);
   IF y[3,m] > 1.0 THEN
      scalv[3] := y[3,m]
   ELSE
      scalv[3] := 1.0;
   WHILE true DO BEGIN
      writeln('Enter c**2 or 999 to end.');
      readln(c2);
      IF c2 = 999 THEN GOTO 99;
      solvde(itmax,conv,slowc,scalv,indexv,ne,nb,m,y,c,s);
      writeln;
      writeln('m = ',mm:2,' n = ',n:2,' c**2 = ',c2:7:3,
         ' lam = ',y[3,1]+mm*(mm+1):10:6);
   END;
99:
END.
