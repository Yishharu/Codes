(* BEGINENVIRON
VAR
   Quad3dX,Quad3dY: real;
FUNCTION func(x,y,z: real): real;
FUNCTION y1(x: real): real;
FUNCTION y2(x: real): real;
FUNCTION z1(x,y: real): real;
FUNCTION z2(x,y: real): real;
ENDENVIRON *)
PROCEDURE quad3d(x1,x2: real;
                VAR ss: real);

PROCEDURE qgaus3(a,b: real;
              VAR ss: real;
                   n: integer);
VAR
   j: integer;
   xr,xm,dx: real;
   w,x: ARRAY [1..5] OF real;

FUNCTION f(x: real;
           n: integer): real;
VAR
   ss: real;
BEGIN
   IF n = 1 THEN BEGIN
      Quad3dX := x;
      qgaus3(y1(Quad3dX),y2(Quad3dX),ss,2);
      f := ss
   END
   ELSE IF n = 2 THEN BEGIN
      Quad3dY := x;
      qgaus3(z1(Quad3dX,Quad3dY),z2(Quad3dX,Quad3dY),ss,3);
      f := ss
   END
   ELSE f := func(Quad3dX,Quad3dY,x)
END;

BEGIN
   x[1] := 0.1488743389;
   x[2] := 0.4333953941;
   x[3] := 0.6794095682;
   x[4] := 0.8650633666;
   x[5] := 0.9739065285;
   w[1] := 0.2955242247;
   w[2] := 0.2692667193;
   w[3] := 0.2190863625;
   w[4] := 0.1494513491;
   w[5] := 0.0666713443;
   xm := 0.5*(b+a);
   xr := 0.5*(b-a);
   ss := 0;
   FOR j := 1 TO 5 DO BEGIN
      dx := xr*x[j];
      ss := ss+w[j]*(f(xm+dx,n)+f(xm-dx,n))
   END;
   ss := xr*ss
END;

BEGIN
   qgaus3(x1,x2,ss,1)
END;
