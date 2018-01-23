(* BEGINENVIRON
CONST
   nvar =
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
PROCEDURE derivs(x: real;
        VAR y,dydx: RealArrayNVAR);
ENDENVIRON *)
PROCEDURE rkqc(VAR y,dydx: RealArrayNVAR;
                        n: integer;
                    VAR x: real;
                 htry,eps: real;
                VAR yscal: RealArrayNVAR;
           VAR hdid,hnext: real);
LABEL 99;
CONST
   pgrow = -0.20;
   pshrnk = -0.25;
   fcor = 0.06666666;
   safety = 0.9;
   errcon = 6.0e-4;
VAR
   i: integer;
   xsav,hh,h,temp,errmax: real;
   dysav,ysav,ytemp: ^RealArrayNVAR;
BEGIN
   new(dysav);
   new(ysav);
   new(ytemp);
   xsav := x;
   FOR i := 1 TO n DO BEGIN
      ysav^[i] := y[i];
      dysav^[i] := dydx[i]
   END;
   h := htry;
   WHILE true DO BEGIN
      hh := 0.5*h;
      rk4(ysav^,dysav^,n,xsav,hh,ytemp^);
      x := xsav+hh;
      derivs(x,ytemp^,dydx);
      rk4(ytemp^,dydx,n,x,hh,y);
      x := xsav+h;
      IF x = xsav THEN BEGIN
         writeln('pause in routine RKQC');
         writeln('stepsize too small');
         readln
      END;
      rk4(ysav^,dysav^,n,xsav,h,ytemp^);
      errmax := 0.0;
      FOR i := 1 TO n DO BEGIN
         ytemp^[i] := y[i]-ytemp^[i];
         temp := abs(ytemp^[i]/yscal[i]);
         IF errmax < temp THEN errmax := temp
      END;
      errmax := errmax/eps;
      IF errmax <= 1.0 THEN BEGIN
         hdid := h;
         IF errmax > errcon THEN
            hnext := safety*h*exp(pgrow*ln(errmax))
         ELSE
            hnext := 4.0*h;
         GOTO 99
      END
      ELSE
         h := safety*h*exp(pshrnk*ln(errmax));
   END;
99:
   FOR i := 1 TO n DO
      y[i] := y[i]+ytemp^[i]*fcor;
   dispose(ytemp);
   dispose(ysav);
   dispose(dysav)
END;
