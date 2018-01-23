(* BEGINENVIRON
CONST
   nvar =
   nstepp = 200
TYPE
   RealArrayNVAR = ARRAY [1..nvar] OF real;
VAR
   RkdumbX: ARRAY [1..nstepp] OF real;
   RkdumbY: ARRAY [1..nvar,1..nstepp] OF real;
PROCEDURE derivs(x: real;
        VAR v,dvdx: RealArrayNVAR);
ENDENVIRON *)
PROCEDURE rkdumb(VAR vstart: RealArrayNVAR;
                          n: integer;
                      x1,x2: real;
                      nstep: integer);
VAR
   k,i: integer;
   x,h: real;
   v,vout,dv: ^RealArrayNVAR;
BEGIN
   new(v);
   new(vout);
   new(dv);
   FOR i := 1 TO n DO BEGIN
      v^[i] := vstart[i];
      RkdumbY[i,1] := v^[i]
   END;
   RkdumbX[1] := x1;
   x := x1;
   h := (x2-x1)/nstep;
   FOR k := 1 TO nstep DO BEGIN
      derivs(x,v^,dv^);
      rk4(v^,dv^,n,x,h,vout^);
      IF x+h = x THEN BEGIN
         writeln('pause in routine RKDUMB');
         writeln('stepsize to small');
         readln
      END;
      x := x+h;
      RkdumbX[k+1] := x;
      FOR i := 1 TO n DO BEGIN
         v^[i] := vout^[i];
         RkdumbY[i,k+1] := v^[i]
      END
   END;
   dispose(dv);
   dispose(vout);
   dispose(v)
END;
