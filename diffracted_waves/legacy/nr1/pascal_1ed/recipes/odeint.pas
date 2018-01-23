(* BEGINENVIRON
CONST
   nvar =
   nstepp = 200
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
VAR
   OdeintKmax,OdeintKount: integer;
   OdeintDxsav: real;
   OdeintXp: ARRAY [1..nstepp] OF real;
   OdeintYp: ARRAY [1..nvar,1..nstepp] OF real;
PROCEDURE derivs(x: real;
        VAR y,dydx: RealArrayNVAR);
ENDENVIRON *)
PROCEDURE odeint(VAR ystart: RealArrayNVAR;
                          n: integer;
          x1,x2,eps,h1,hmin: real;
               VAR nok,nbad: integer);
LABEL 99;
CONST
   maxstp = 10000;
   tiny = 1.0e-30;
VAR
   nstp,i: integer;
   xsav,x,hnext,hdid,h: real;
   yscal,y,dydx: ^RealArrayNVAR;
BEGIN
   new(yscal);
   new(y);
   new(dydx);
   x := x1;
   IF x2 >= x1 THEN h := abs(h1) ELSE h := -abs(h1);
   nok := 0;
   nbad := 0;
   OdeintKount := 0;
   FOR i := 1 TO n DO y^[i] := ystart[i];
   IF OdeintKmax > 0 THEN
      xsav := x-2.0*OdeintDxsav;
   FOR nstp := 1 TO maxstp DO BEGIN
      derivs(x,y^,dydx^);
      FOR i := 1 TO n DO
         yscal^[i] := abs(y^[i])+abs(dydx^[i]*h)+tiny;
      IF OdeintKmax > 0 THEN
         IF abs(x-xsav) > abs(OdeintDxsav) THEN
            IF OdeintKount < OdeintKmax-1 THEN BEGIN
               OdeintKount := OdeintKount+1;
               OdeintXp[OdeintKount] := x;
               FOR i := 1 TO n DO
                  OdeintYp[i,OdeintKount] := y^[i];
               xsav := x
            END;
      IF (x+h-x2)*(x+h-x1) > 0.0 THEN
         h := x2-x;
      rkqc(y^,dydx^,n,x,h,eps,yscal^,hdid,hnext);
      IF hdid = h THEN
         nok := nok+1
      ELSE
         nbad := nbad+1;
      IF (x-x2)*(x2-x1) >= 0.0 THEN BEGIN
         FOR i := 1 TO n DO ystart[i] := y^[i];
         IF OdeintKmax <> 0 THEN BEGIN
            OdeintKount := OdeintKount+1;
            OdeintXp[OdeintKount] := x;
            FOR i := 1 TO n DO
               OdeintYp[i,OdeintKount] := y^[i]
         END;
         GOTO 99
      END;
      IF abs(hnext) < hmin THEN BEGIN
         writeln('pause in routine ODEINT');
         writeln('stepsize too small');
         readln
      END;
      h := hnext;
   END;
   writeln('pause in routine ODEINT - too many steps');
   readln;
99:
   dispose(dydx);
   dispose(y);
   dispose(yscal)
END;
