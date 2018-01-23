(* BEGINENVIRON
CONST
   nvar =
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
PROCEDURE derivs(x: real;
        VAR y,dydx: RealArrayNVAR);
ENDENVIRON *)
PROCEDURE rk4(VAR y,dydx: RealArrayNVAR;
                       n: integer;
                     x,h: real;
                VAR yout: RealArrayNVAR);
VAR
   i: integer;
   xh,hh,h6: real;
   dym,dyt,yt: ^RealArrayNVAR;
BEGIN
   new(dym);
   new(dyt);
   new(yt);
   hh := h*0.5;
   h6 := h/6.0;
   xh := x+hh;
   FOR i := 1 TO n DO
      yt^[i] := y[i]+hh*dydx[i];
   derivs(xh,yt^,dyt^);
   FOR i := 1 TO n DO
      yt^[i] := y[i]+hh*dyt^[i];
   derivs(xh,yt^,dym^);
   FOR i := 1 TO n DO BEGIN
      yt^[i] := y[i]+h*dym^[i];
      dym^[i] := dyt^[i]+dym^[i]
   END;
   derivs(x+h,yt^,dyt^);
   FOR i := 1 TO n DO
      yout[i] := y[i]+h6*(dydx[i]+dyt^[i]+2.0*dym^[i]);
   dispose(yt);
   dispose(dyt);
   dispose(dym)
END;
