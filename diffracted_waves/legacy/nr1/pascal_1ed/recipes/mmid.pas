(* BEGINENVIRON
CONST
   nvar =
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
PROCEDURE derivs(x: real;
        VAR y,dydx: RealArrayNVAR);
ENDENVIRON *)
PROCEDURE mmid(VAR y,dydx: RealArrayNVAR;
                        n: integer;
                  xs,htot: real;
                    nstep: integer;
                 VAR yout: RealArrayNVAR);
VAR
   step,i: integer;
   x,swap,h2,h: real;
   ym,yn: ^RealArrayNVAR;
BEGIN
   new(ym);
   new(yn);
   h := htot/nstep;
   FOR i := 1 TO n DO BEGIN
      ym^[i] := y[i];
      yn^[i] := y[i]+h*dydx[i]
   END;
   x := xs+h;
   derivs(x,yn^,yout);
   h2 := 2.0*h;
   FOR step := 2 TO nstep DO BEGIN
      FOR i := 1 TO n DO BEGIN
         swap := ym^[i]+h2*yout[i];
         ym^[i] := yn^[i];
         yn^[i] := swap
      END;
      x := x+h;
      derivs(x,yn^,yout)
   END;
   FOR i := 1 TO n DO
      yout[i] := 0.5*(ym^[i]+yn^[i]+h*yout[i]);
   dispose(yn);
   dispose(ym)
END;
